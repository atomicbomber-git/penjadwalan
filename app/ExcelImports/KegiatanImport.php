<?php


namespace App\ExcelImports;


use Maatwebsite\Excel\Concerns\ToCollection;

class KegiatanImport implements ToCollection
{
    const MODE_SEEKING_TABLE_HEADER = 1;
    const MODE_READING_TABLE_BODY = 2;
    const MODE_SKIP_THE_REST = 3;

    public static function isDataRow(array $row, $threshold = 7)
    {
        return self::getNotNullCount($row) >= $threshold;
    }

    public static function getNotNullCount(array $row): int
    {
        $not_null_count = 0;
        foreach ($row as $column) {
            $not_null_count += ($column === null) ? 0 : 1;
        }
        return $not_null_count;
    }

    public function collection(\Illuminate\Support\Collection $rows)
    {
        $current_mode = self::MODE_SEEKING_TABLE_HEADER;
        $nonDataRowCount = 0;

        foreach ($rows as $row) {
            dump($row->toArray());

//            switch ($current_mode) {

//                case self::MODE_SEEKING_TABLE_HEADER:
//                    if (self::getNotNullCount($row->toArray()) >= 7) {
//                        $current_mode = self::MODE_READING_TABLE_BODY;
//                    }
//                    break;
//                case self::MODE_READING_TABLE_BODY:
//                    if ($nonDataRowCount >= 2) {
//                        $current_mode = self::MODE_SKIP_THE_REST;
//                        break;
//                    }
//
//                    if (!self::isDataRow($row->toArray())) {
//                        $nonDataRowCount++;
//                        break;
//                    }
//
//                    dump($row);
//
//                    break;
//                case self::MODE_SKIP_THE_REST:
//                    break;
//            }
        }
    }
}
