<?php


namespace App\Support;


use Jenssegers\Date\Date;

class LocalDayNames
{
    public static function get(): array
    {
        $days = [];
        for ($i = 1; $i < 7; ++$i) {
            $days[$i] = strtoupper(Date::create($i)->format("l"));
        }
        return $days;
    }
}
