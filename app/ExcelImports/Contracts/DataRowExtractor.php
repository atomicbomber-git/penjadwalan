<?php


namespace App\ExcelImports\Contracts;


interface DataRowExtractor
{
    public function getDay(): ?string;
    public function getTime(): array;
    public function getClassCode(): string;
    public function getClassName(): string;
    public function getType(): string;
    public function getSemester(): string;
    public function getSKS(): string;
    public function getKAP(): string;
    public function getPST(): string;
    public function getLecturer(): string;
    public function getRoom(): string;
}
