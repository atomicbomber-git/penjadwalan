<?php


namespace App\ExcelImports\DataRowExtractors;


use App\ExcelImports\Contracts\DataRowExtractor;
use Illuminate\Support\Collection;

class ShortRowExtractor implements DataRowExtractor
{
    private Collection $row;

    const DAY_COL_INDEX = 0;
    const TIME_COL_INDEX = 1;
    const CLASS_CODE_COL_INDEX = 2;
    const CLASS_NAME_COL_INDEX = 3;
    const TYPE_COL_INDEX = 4;
    const SEMESTER_COL_INDEX = 5;
    const SKS_COL_INDEX = 6;
    const PST_COL_INDEX = 7;
    const LECTURER_COL_INDEX = 8;
    const ROOM_COL_INDEX = 9;

    public function __construct(Collection $row)
    {
        $this->row = $row;
    }

    public function getDay(): string
    {
        return isset($this->row[self::DAY_COL_INDEX]) ? trim($this->row[self::DAY_COL_INDEX]) : null;
    }

    public function getTime(): array
    {
        return explode("s/d", strtolower(trim($this->row[self::TIME_COL_INDEX]))) ;
    }

    public function getClassCode(): string
    {
        return trim($this->row[self::CLASS_CODE_COL_INDEX]);
    }

    public function getClassName(): string
    {
        return trim($this->row[self::CLASS_NAME_COL_INDEX]);
    }

    public function getType(): string
    {
        return trim($this->row[self::TYPE_COL_INDEX]);
    }

    public function getSemester(): string
    {
        return trim($this->row[self::SEMESTER_COL_INDEX]);
    }

    public function getSKS(): string
    {
        return trim($this->row[self::SKS_COL_INDEX]);
    }

    public function getKAP(): string
    {
        return null;
    }

    public function getPST(): string
    {
        return trim($this->row[self::PST_COL_INDEX]);
    }

    public function getLecturer(): string
    {
        return trim($this->row[self::LECTURER_COL_INDEX]);
    }

    public function getRoom(): string
    {
        return trim($this->row[self::ROOM_COL_INDEX]);
    }
}
