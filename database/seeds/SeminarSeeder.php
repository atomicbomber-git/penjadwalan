<?php

use App\Kegiatan;
use App\Ruangan;
use App\Seminar;
use Illuminate\Database\Seeder;
use Illuminate\Support\Collection;
use Jenssegers\Date\Date;

class SeminarSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $ruangan = Ruangan::query()->first();

        Collection::times(10, function ($number) use($ruangan) {
            $kegiatan = Kegiatan::query()->create([
                "tanggal_mulai" => Date::today(),
                "tanggal_selesai" => Date::tomorrow(),
                "waktu_mulai" => "07:00",
                "waktu_selesai" => "09:00",
                "berulang" => false,
                "kegiatan_sumber_id" => null,
                "ruangan_id" => $ruangan->id,
                "mata_kuliah_id" => null,
            ]);

            Seminar::query()->create([
                "kegiatan_id" => $kegiatan->id,
                "nama" => "Seminar {$number}",
            ]);
        });
    }
}
