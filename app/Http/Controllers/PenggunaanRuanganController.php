<?php

namespace App\Http\Controllers;

use App\Casts\JsonCast;
use App\Jadwal;
use App\KelasMataKuliah;
use App\Ruangan;
use Illuminate\Contracts\Routing\ResponseFactory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Date;

class PenggunaanRuanganController extends Controller
{
    private $responseFactory;

    public function __construct(ResponseFactory $responseFactory)
    {
        $this->responseFactory = $responseFactory;
    }

    /**
     * Handle the incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Contracts\View\Factory|\Illuminate\Http\Response|\Illuminate\View\View
     */
    public function __invoke(Request $request)
    {
        return view("penggunaan-ruangan");
    }

    /**
     * @return \Illuminate\Database\Eloquent\Builder
     */
    private function getKegiatanKelasQuery(): \Illuminate\Database\Eloquent\Builder
    {
        return KelasMataKuliah::query()
            ->select("kegiatan_id")
            ->selectRaw("
                json_agg(
                    json_build_object(
                        'tipe', tipe,
                        'program_studi', json_build_object('id', program_studi.id, 'nama', program_studi.nama)
                        )
                    ORDER BY program_studi.nama, tipe
                    ) AS kegiatan_kelas
            ")
            ->selectRaw("
                CASE
                    WHEN mata_kuliah.id IS NOT NULL THEN
                        json_build_object('id', mata_kuliah.id, 'nama', mata_kuliah.nama)
                    ELSE NULL
                END AS mata_kuliah
            ")
            ->leftJoin("mata_kuliah", "mata_kuliah.id", "kelas_mata_kuliah.mata_kuliah_id")
            ->leftJoin("program_studi", "program_studi.id", "kelas_mata_kuliah.program_studi_id")
            ->groupBy("kegiatan_id", "mata_kuliah.id");
    }

    /**
     * @param $filter_ruangan_id
     * @param $filter_waktu_mulai
     * @param $filter_waktu_selesai
     * @return mixed
     */
    private function getJadwal($filter_ruangan_id, $filter_waktu_mulai, $filter_waktu_selesai)
    {
        return Jadwal::query()
            ->selectRaw("LOWER(rentang_waktu) AS waktu_mulai")
            ->selectRaw("UPPER(rentang_waktu) AS waktu_selesai")
            ->selectRaw("ruangan.nama AS nama_ruangan")
            ->selectRaw("kegiatan_kelas")
            ->selectRaw("mata_kuliah")
            ->leftJoin("kegiatan", "kegiatan.id", "jadwal.kegiatan_id")
            ->leftJoin("mata_kuliah", "mata_kuliah.id", "kegiatan.mata_kuliah_id")
            ->leftJoin("ruangan", "ruangan.id", "kegiatan.ruangan_id")
            ->leftJoinSub($this->getKegiatanKelasQuery(), "kegiatan_kelas", "kegiatan_kelas.kegiatan_id", "kegiatan.id")
            ->where("ruangan.id", $filter_ruangan_id)
            ->whereRaw("LOWER(rentang_waktu) >= ?", [$filter_waktu_mulai])
            ->whereRaw("UPPER(rentang_waktu) <= ?", [$filter_waktu_selesai])
            ->orderBy("rentang_waktu")
            ->withCasts([
                "kegiatan_kelas" => JsonCast::class,
                "mata_kuliah" => JsonCast::class,
            ])
            ->paginate();
    }
}
