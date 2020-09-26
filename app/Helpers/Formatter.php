<?php


namespace App\Helpers;


use Jenssegers\Date\Date;

class Formatter
{
    public static function fancyDate($datetime)
    {
        return (new Date($datetime))->format("l, d F Y");
    }

    /**
     * @param $datetime
     * @return string
     * @throws \Exception
     */
    public static function fancyDatetime($datetime)
    {
        return (new Date($datetime))->format("l, d F Y H:i:s");
    }
}
