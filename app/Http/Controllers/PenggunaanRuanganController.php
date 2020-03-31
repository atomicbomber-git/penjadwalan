<?php

namespace App\Http\Controllers;

use App\Casts\JsonCast;
use App\Jadwal;
use App\KelasKegiatan;
use App\Ruangan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Date;

class PenggunaanRuanganController extends Controller
{
    /**
     * Handle the incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Contracts\View\Factory|\Illuminate\Http\Response|\Illuminate\View\View
     */
    public function __invoke(Request $request)
    {
        $ruangans = Ruangan::query()
            ->select("id", "nama")
            ->get();

        $filter_ruangan_id = $request->get("filter_ruangan_id", $ruangans->first()->id);
        $filter_waktu_mulai = $request->get("filter_waktu_mulai", Date::today()->format("Y-m-d H:i:s"));
        $filter_waktu_selesai = $request->get("filter_waktu_selesai", Date::today()->addMonths(1)->format("Y-m-d H:i:s"));

        $detail_kegiatan_query = KelasKegiatan::query()
            ->select("kegiatan_id")
            ->selectRaw("
                json_agg(
                    json_build_object(
                        'tipe', tipe,
                        'program_studi', json_build_object('id', program_studi.id, 'nama', program_studi.nama)
                        )
                    ORDER BY program_studi.nama, tipe
                    ) AS detail_penggunaans
            ")
            ->leftJoin("program_studi", "program_studi.id", "kelas_kegiatan.program_studi_id")
            ->groupBy("kegiatan_id");

        $jadwals = Jadwal::query()
            ->selectRaw("LOWER(rentang_waktu) AS waktu_mulai")
            ->selectRaw("UPPER(rentang_waktu) AS waktu_selesai")
            ->selectRaw("ruangan.nama AS nama_ruangan")
            ->selectRaw("json_build_object('id', mata_kuliah.id, 'nama', mata_kuliah.nama) AS mata_kuliah")
            ->selectRaw("detail_penggunaans")
            ->leftJoin("kegiatan", "kegiatan.id", "jadwal.kegiatan_id")
            ->leftJoin("mata_kuliah", "mata_kuliah.id", "kegiatan.mata_kuliah_id")

            ->leftJoin("ruangan", "ruangan.id", "kegiatan.ruangan_id")
            ->leftJoinSub($detail_kegiatan_query, "detail_kegiatan", "detail_kegiatan.kegiatan_id", "kegiatan.id")
            ->where("ruangan.id", $filter_ruangan_id)
            ->whereRaw("LOWER(rentang_waktu) >= ?", [$filter_waktu_mulai])
            ->whereRaw("UPPER(rentang_waktu) <= ?", [$filter_waktu_selesai])
            ->orderBy("rentang_waktu")
            ->withCasts([
                "detail_penggunaans" => JsonCast::class,
                "mata_kuliah" => JsonCast::class,
            ])
            ->paginate();

        return view("penggunaan-ruangan", compact(
            "filter_waktu_mulai",
            "filter_waktu_selesai",
            "filter_ruangan_id",
            "ruangans",
            "jadwals"
        ));
    }
}
