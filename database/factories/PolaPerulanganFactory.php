<?php

/** @var Factory $factory */

use App\Constants\TipePerulangan;
use App\PolaPerulangan;
use Carbon\Carbon;
use Faker\Generator as Faker;
use Illuminate\Database\Eloquent\Factory;

$factory->define(PolaPerulangan::class, function (Faker $faker) {
    return [
        "tipe_perulangan" => TipePerulangan::MINGGUAN,
        "jumlah_unit_pemisah" => 0,
        "hari_dalam_minggu" => Carbon::MONDAY,
        "minggu_dalam_bulan" => null,
        "hari_dalam_bulan" => null,
        "bulan_dalam_tahun" => null,
    ];
});
