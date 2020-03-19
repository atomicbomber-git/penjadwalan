<?php

/** @var Factory $factory */

use App\Kegiatan;
use App\Ruangan;
use Faker\Generator as Faker;
use Illuminate\Database\Eloquent\Factory;
use Illuminate\Support\Facades\Date;

$factory->define(Kegiatan::class, function (Faker $faker) {
    $tanggal_mulai = Date::now();

    return [
        "nama" => ucwords(implode(" ", $faker->words)),
        "deskripsi" => rand(0, 1) ? $faker->realText(1000) : null,
        "tanggal_mulai" => $tanggal_mulai,
        "tanggal_selesai" => $tanggal_mulai->addDays(rand(1, 100)),
        "waktu_mulai" => Date::create(),
        "waktu_selesai" => Date::create()->addMinutes(rand(1, 4) * 15),
        "berulang" => rand(0, 1) ? false : true,
        "kegiatan_sumber_id" => null,
        "ruangan_id" => Ruangan::query()->inRandomOrder()->value("id"),
    ];
});
