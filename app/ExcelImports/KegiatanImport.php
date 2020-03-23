<?php


namespace App\ExcelImports;


use App\ExcelImports\Contracts\DataRowExtractor;
use App\ExcelImports\DataRowExtractors\LongRowExtractor;
use App\ExcelImports\DataRowExtractors\ShortRowExtractor;
use App\Kegiatan;
use App\Ruangan;
use Exception;
use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\ToCollection;

class KegiatanImport implements ToCollection
{
    const MODE_SEEKING_TABLE_HEADER = 0;
    const MODE_READING_TABLE_BODY = 1;
    const MODE_SKIP_THE_REST = 2;

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

        if ((static::getNotNullCount($row->toArray()) <= 4) && ($currentRowDataExtractor->getClassCode() !== null)) {
            /** Continuation row, use similar data as the 'current row' except for the class code */
            $primaryRow = $this->savedRow;
        }
        else {
            $primaryRow = $row;
            $this->savedRow = $row;
        }

        $primaryRowDataExtractor = $this->getDataRowExtractor($primaryRow);
        if ($primaryRowDataExtractor->getDay() !== null) {
            $this->currentDay = $primaryRowDataExtractor->getDay();
        }

        Ruangan::query()->firstOrCreate([
            "nama" => $primaryRowDataExtractor->getRoom(),
            "deskripsi" => $primaryRowDataExtractor->getRoom(),
        ]);

        Kegiatan::query()->create([
            "nama" =>
        ]);

    }

    /**
     * @param Collection $rows
     * @throws Exception
     */
    public function collection(Collection $rows)
    {
        $current_mode = self::MODE_SEEKING_TABLE_HEADER;

        foreach ($rows as $row) {
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
