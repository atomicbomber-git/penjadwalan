<?php


namespace App\Helpers;


use Jenssegers\Date\Date;

class Formatter
{
    /**
     * @param $datetime
     * @return string
     * @throws \Exception
     */
    public static function fancyDatetime($datetime)
    {
        return (new \Jenssegers\Date\Date($datetime))->format("l, d F Y H:i:s");
    }
}
