<?php

/** @var \Illuminate\Database\Eloquent\Factory $factory */

use App\Ruangan;
use Faker\Generator as Faker;

$factory->define(Ruangan::class, function (Faker $faker) {
    return [
        "nama" => "{$faker->word}-{$faker->buildingNumber}",
        "deskripsi" => rand(0, 1) ? $faker->realText(1000) : null,
    ];
});
