<?php


namespace App\Constants;


class IndonesianDays
{
    public static function getIndex(string $name): int {
        return self::MAP[$name];
    }

    public static function getName(int $index): string
    {
        return array_flip(self::MAP)[$index];
    }

    const MAP = [
        "senin" => 1,
        "selasa" => 2,
        "rabu" => 3,
        "kamis" => 4,
        "jum'at" => 5,
        "jumat" => 5,
        "sabtu" => 6,
        "minggu" => 7,
    ];
}
