<?php

use App\Kegiatan;
use App\Ruangan;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Date;
use Illuminate\Support\Facades\DB;

class KegiatanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $ruangan2 = Ruangan::query()
            ->select("id")
            ->get();

        $tanggal_mulai = Carbon::now()->toImmutable();
        $tanggal_selesai = $tanggal_mulai->addMonths(6);

        DB::beginTransaction();

        foreach ($ruangan2 as $ruangan) {
            for ($i = 8; $i <= 16; ++$i) {
                factory(Kegiatan::class)->create([
                    "tanggal_mulai" => $tanggal_mulai,
                    "tanggal_selesai" => $tanggal_selesai,
                    "waktu_mulai" => Date::createFromTimestampMs(0)->addHours($i - 1),
                    "waktu_selesai" => Date::createFromTimestampMs(0)->addHours($i),
                    "ruangan_id" => $ruangan->id,
                ]);
            }
        }

        DB::commit();
    }
}
