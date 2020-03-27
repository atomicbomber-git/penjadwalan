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
use App\ProgramStudi;
use App\Ruangan;
use App\TahunAjaran;
use App\TipeSemester;
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

    private ProgramStudi $program_studi;
    private TahunAjaran $tahun_ajaran;
    private TipeSemester $tipe_semester;

    private $start_date = null;
    private $end_date = null;

    const ROW_TYPE_LONG = 0;
    const ROW_TYPE_SHORT = 1;

    const ROW_TYPE_LENGTH_MAP = [
        11 => self::ROW_TYPE_LONG,
        10 => self::ROW_TYPE_SHORT,
    ];

    private $savedRow = null;
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

    public function cleanName(string $name): string
    {
        $result = $name;

        // Remove unwanted characters
        foreach ([".", "-", " "] as $to_be_deleted) {
            $result = str_replace($to_be_deleted, "", $result);
        }

        $result = strtoupper($result);

        return $result;
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

        if ((static::getNotNullCount($row->toArray()) < 8) && ($currentRowDataExtractor->getClassCode() !== null)) {
            /** Continuation row, use similar data as the 'current row' except for the class code */
            $primaryRow = $row->replace($this->savedRow);
        } else {
            $primaryRow = $row;
            $this->savedRow = $row;
        }

        $primaryRowDataExtractor = $this->getDataRowExtractor($primaryRow);

        if ($primaryRowDataExtractor->getDay() !== null) {
            $this->currentDay = $primaryRowDataExtractor->getDay();
        }

        $ruangan = Ruangan::query()->firstOrCreate([
            "nama" => $this->cleanName($primaryRowDataExtractor->getRoom()),
        ], [
            "deskripsi" => $this->cleanName($primaryRowDataExtractor->getRoom())
        ]);

        $mata_kuliah_umum = false;
        foreach (["MKWU", "UMG", "UT"] as $marker) {
            if (strpos($primaryRowDataExtractor->getClassCode(), $marker) !== false) {
                $mata_kuliah_umum = true;
                break;
            }
        }

        $mata_kuliah = MataKuliah::query()->firstOrCreate([
            "kode" => $primaryRowDataExtractor->getClassCode(),
        ], [
            "program_studi_id" => $mata_kuliah_umum ? null : $this->program_studi->id,
            "nama" =>  $primaryRowDataExtractor->getClassName(),
            "semester" => $primaryRowDataExtractor->getSemester(),
            "jumlah_sks" => $primaryRowDataExtractor->getSKS(),
        ]);

        $kelas_mata_kuliah = KelasMataKuliah::query()->create([
            "mata_kuliah_id" => $mata_kuliah->id,
            "tipe" => $primaryRowDataExtractor->getType(),
            "tipe_semester_id" => $this->tipe_semester->id,
            "tahun_ajaran_id" => $this->tahun_ajaran->id,
            "program_studi_id" => $this->program_studi->id,
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
            "interval_perulangan" => 1,
            "hari_dalam_minggu" => $this->currentDay,
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
        if ($semester_type === "GASAL") {
            return ["07-01-{$this->tahun_ajaran->tahun_mulai}", "12-31-{$this->tahun_ajaran->tahun_mulai}"];
        }

        if ($semester_type === "GENAP") {
            return ["01-01-{$this->tahun_ajaran->tahun_selesai}", "06-30-{$this->tahun_ajaran->tahun_selesai}"];
        }

        throw new Exception("Unknown data.");
    }

    /**
     * @param Collection $rows
     * @throws Exception
     */
    public function collection(Collection $rows)
    {
        $current_mode = self::MODE_SEEKING_TABLE_HEADER;

        $this->extractTahunAjaran($rows->shift()->first());
        $this->extractProgramStudi($rows->shift()->first());

        foreach ($rows as $index => $row) {
            switch ($current_mode) {
                case self::MODE_SEEKING_TABLE_HEADER:
                    if (self::getNotNullCount($row->toArray()) >= 7) {
                        $current_mode = self::MODE_READING_TABLE_BODY;
                    }
                    break;
                case self::MODE_READING_TABLE_BODY:
                    if (((static::getNotNullCount($row->toArray())) < 4) || empty($row[1])) {
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

    /**
     * @param $first_row_text
     * @throws Exception
     */
    private function extractTahunAjaran($first_row_text): void
    {
        $split_text_parts = explode(" ", $first_row_text);
        $year_text_parts = null;

        foreach ($split_text_parts as $index => $split_text_part) {
            if (in_array(trim($split_text_part), ["SEMESTER"])) {
                $tipe_semester = trim($split_text_parts[$index + 1]);
                continue;
            }

            if (in_array(trim($split_text_part), ["TA.", "AKADEMIK"])) {
                $year_text_parts = array_splice($split_text_parts, $index + 1);
                continue;
            }
        }

        $this->tipe_semester = TipeSemester::query()->firstOrCreate([
            "nama" => $tipe_semester
        ]);

        list($tahun_mulai, $tahun_selesai) = explode("/", implode("", $year_text_parts));

        $this->tahun_ajaran = TahunAjaran::query()->firstOrCreate([
            "tahun_mulai" => $tahun_mulai,
            "tahun_selesai" => $tahun_selesai,
        ]);

        list($this->start_date, $this->end_date) = $this->getStartAndEndDate("{$tahun_mulai}/{$tahun_selesai}", $tipe_semester);
    }

    /**
     * @param $second_row_text
     */
    private function extractProgramStudi($second_row_text): void
    {
        foreach (["PROGRAM STUDI SARJANA S1", "PROGRAM STUDI"] AS $marker) {
            if (($pos = strpos($second_row_text, $marker)) !== false) {
                $this->program_studi = ProgramStudi::query()->firstOrCreate([
                    "nama" => trim(substr($second_row_text, $pos + strlen($marker)))
                ]);
                break;
            }
        }
    }
}
