<?php


namespace App\ExcelImports;


use App\Constants\Interval;
use App\ExcelImports\Contracts\DataRowExtractor;
use App\ExcelImports\DataRowExtractors\LongRowExtractor;
use App\ExcelImports\DataRowExtractors\ShortRowExtractor;
use App\Kegiatan;
use App\KelasMataKuliah;
use App\MataKuliah;
use App\PolaPerulangan;
use App\Ruangan;
use Exception;
use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;

class KegiatanImport implements ToCollection
{
    const MODE_SEEKING_TABLE_HEADER = 0;
    const MODE_READING_TABLE_BODY = 1;
    const MODE_SKIP_THE_REST = 2;

    const DATE_MAP = [
        "2018/2019" => [
            "GASAL" => ["07-01-2018", "12-31-2019"],
            "GENAP" => ["01-01-2019", "06-30-2019"],
        ],

        "2019/2020" => [
            "GASAL" => ["07-01-2019", "12-31-2020"],
            "GENAP" => ["01-01-2020", "06-30-2020"],
        ],
    ];

    private $start_date = null;
    private $end_date = null;

    const ROW_TYPE_LONG = 0;
    const ROW_TYPE_SHORT = 1;

    const ROW_TYPE_LENGTH_MAP = [
        11 => self::ROW_TYPE_LONG,
        10 => self::ROW_TYPE_SHORT,
    ];

    private $savedRow  = null;
    private $currentDay = null;

    public static function getNotNullCount(array $row): int
    {
        $not_null_count = 0;
        foreach ($row as $column) {
            $not_null_count += ($column === null) ? 0 : 1;
        }
        return $not_null_count;
    }

    public function getNullCount(Collection $row): int
    {
        $null_count = 0;
        foreach ($row as $column) {
            $null_count += ($column === null) ? 1 : 0;
        }
        return $null_count;
    }

    /**
     * @param Collection $row
     * @return int
     * @throws Exception
     */
    public static function getRowType(Collection $row): int
    {
        if (!isset(self::ROW_TYPE_LENGTH_MAP[$row->count()])) {
            throw new Exception("Unknown row type.");
        }

        return self::ROW_TYPE_LENGTH_MAP[$row->count()];
    }

    /**
     * @param Collection $row
     * @return DataRowExtractor
     * @throws Exception
     */
    public function getDataRowExtractor(Collection $row): DataRowExtractor
    {
        switch (self::getRowType($row)) {
            case static::ROW_TYPE_LONG:
                return new LongRowExtractor($row);
            case static::ROW_TYPE_SHORT:
                return new ShortRowExtractor($row);
            default:
                throw new Exception("Unknown row type.");
        }
    }

    /**
     * @param Collection $row
     * @throws Exception
     */
    public function processDataRow(Collection $row): void
    {
        $primaryRow = null;
        $currentRowDataExtractor = $this->getDataRowExtractor($row);

        if ((static::getNotNullCount($row->toArray()) < 10) && ($currentRowDataExtractor->getClassCode() !== null)) {
            /** Continuation row, use similar data as the 'current row' except for the class code */
            $primaryRow = $row->replace($this->savedRow);
        }
        else {
            $primaryRow = $row;
            $this->savedRow = $row;
        }

        $primaryRowDataExtractor = $this->getDataRowExtractor($primaryRow);
        if ($primaryRowDataExtractor->getDay() !== null) {
            $this->currentDay = $primaryRowDataExtractor->getDay();
        }

        $ruangan = Ruangan::query()->firstOrCreate([
            "nama" => $primaryRowDataExtractor->getRoom(),
            "deskripsi" => $primaryRowDataExtractor->getRoom(),
        ]);

        $mata_kuliah = MataKuliah::query()->firstOrCreate([
            "kode" => $primaryRowDataExtractor->getClassCode(),
        ], [
            "nama" => $primaryRowDataExtractor->getClassName(),
            "semester" => $primaryRowDataExtractor->getSemester(),
            "jumlah_sks" => $primaryRowDataExtractor->getSKS(),
        ]);

        $kelas_mata_kuliah = KelasMataKuliah::query()->create([
            "mata_kuliah_id" => $mata_kuliah->id,
            "tipe" => $primaryRowDataExtractor->getType(),
        ]);

        list($start_time, $end_time) = $primaryRowDataExtractor->getTime();

        $kegiatan = Kegiatan::query()->firstOrCreate([
            "kelas_mata_kuliah_id" => $kelas_mata_kuliah->id,
            "ruangan_id" => $ruangan->id,
        ], [
            "tanggal_mulai" => $this->start_date,
            "tanggal_selesai" => $this->end_date,
            "waktu_mulai" => $start_time,
            "waktu_selesai" => $end_time,
            "berulang" => true,
        ]);

        PolaPerulangan::query()->create([
            "kegiatan_id" => $kegiatan->id,
            "interval" => "1 " . Interval::WEEK,
            "hari_dalam_minggu" => $primaryRowDataExtractor->getDay(),
            "minggu_dalam_bulan" => null,
            "hari_dalam_bulan" => null,
            "bulan_dalam_tahun" => null,
        ]);
    }

    /**
     * @param string $term
     * @param string $semester_type
     * @return array
     * @throws Exception
     */
    public function getStartAndEndDate(string $term, string $semester_type): array
    {
        if (isset(self::DATE_MAP[$term][$semester_type])) {
            return self::DATE_MAP[$term][$semester_type];
        }

        if ($semester_type === "GASAL") {
            return ["07-01-2018", "12-31-2019"];
        }

        if ($semester_type === "GENAP") {
            return  ["01-01-2019", "06-30-2019"];
        }

        throw new Exception("Unknown data.");
    }

    public function extractStartAndEndDates(string $info_text)
    {
        $split_parts = explode(" ", $info_text);
        $semester = null;
        $tahun_ajaran = null;

        foreach ($split_parts as $index => $split_part) {
            if ($split_part === "SEMESTER") {
                $semester = $split_parts[$index + 1];
                continue;
            }

            if ($split_part === "AKADEMIK" || $split_part === "TA.") {
                $tahun_ajaran = $split_parts[$index + 1];
                continue;
            }
        }

        list($this->start_date, $this->end_date) = $this->getStartAndEndDate($tahun_ajaran, $semester);
    }

    /**
     * @param Collection $rows
     * @throws Exception
     */
    public function collection(Collection $rows)
    {
        $current_mode = self::MODE_SEEKING_TABLE_HEADER;

        $this->extractStartAndEndDates($rows->first()->first());

        foreach ($rows as $index => $row) {
            switch ($current_mode) {
                case self::MODE_SEEKING_TABLE_HEADER:
                    if (self::getNotNullCount($row->toArray()) >= 7) {
                        $current_mode = self::MODE_READING_TABLE_BODY;
                    }
                    break;
                case self::MODE_READING_TABLE_BODY:
                    if ($this->getNullCount($row) === $row->count()) {
                        $current_mode = self::MODE_SKIP_THE_REST;
                        break;
                    }
                    $this->processDataRow($row);
                    break;
                case self::MODE_SKIP_THE_REST:
                    break;
            }
        }
    }
}
