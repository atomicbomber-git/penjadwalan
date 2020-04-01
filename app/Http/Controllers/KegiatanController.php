<?php

namespace App\Http\Controllers;

use App\Kegiatan;
use App\KelasMataKuliah;
use App\ProgramStudi;
use App\TahunAjaran;
use App\TipeSemester;
use Illuminate\Http\Request;

class KegiatanController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Contracts\View\Factory|\Illuminate\Http\Response|\Illuminate\View\View
     */
    public function index(Request $request)
    {
        $program_studis = ProgramStudi::query()->orderBy("nama")->get();
        $tahun_ajarans = TahunAjaran::query()->orderBy("tahun_mulai")->get();
        $tipe_semesters = TipeSemester::query()->orderBy("nama")->get();

        $program_studi_id = $request->get("program_studi_id", $program_studis->first()->id);
        $tahun_ajaran_id = $request->get("tahun_ajaran_id", $tahun_ajarans->first()->id);
        $tipe_semester_id = $request->get("tipe_semester_id", $tipe_semesters->first()->id);

        $kegiatans = Kegiatan::query()
            ->select(
                "kegiatan.id",
                "hari_dalam_minggu",
            )
            ->orderByRaw("pola_perulangan.hari_dalam_minggu")
            ->leftJoin("pola_perulangan", "pola_perulangan.kegiatan_id", "kegiatan.id")
            ->leftJoinSub($this->getKelasKegiatanQuery(), "kelas_mata_kuliah", "kelas_mata_kuliah.kegiatan_id", "kegiatan.id")
            ->where("kelas_mata_kuliah.program_studi_id", "=", $program_studi_id)
            ->where("kelas_mata_kuliah.tahun_ajaran_id", "=", $tahun_ajaran_id)
            ->where("kelas_mata_kuliah.tipe_semester_id", "=", $tipe_semester_id)
            ->paginate();

        return $kegiatans;

        return view("kegiatan.index", compact(
            "program_studis",
            "tahun_ajarans",
            "tipe_semesters",
            "kegiatans",
            "program_studi_id",
            "tahun_ajaran_id",
            "tipe_semester_id",
        ));
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Kegiatan  $kegiatan
     * @return \Illuminate\Http\Response
     */
    public function show(Kegiatan $kegiatan)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Kegiatan  $kegiatan
     * @return \Illuminate\Http\Response
     */
    public function edit(Kegiatan $kegiatan)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Kegiatan  $kegiatan
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Kegiatan $kegiatan)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Kegiatan  $kegiatan
     * @return \Illuminate\Http\Response
     */
    public function destroy(Kegiatan $kegiatan)
    {
        //
    }

    /**
     * @return \Illuminate\Database\Eloquent\Builder
     */
    private function getKelasKegiatanQuery(): \Illuminate\Database\Eloquent\Builder
    {
        return KelasMataKuliah::query()
            ->select("kegiatan_id", "kelas_mata_kuliah.program_studi_id", "tahun_ajaran_id", "tipe_semester_id", "mata_kuliah.nama AS nama_mata_kuliah")
            ->selectRaw("
                json_agg(
                    json_build_object(
                        'tipe', tipe,
                        'program_studi', json_build_object('id', program_studi.id, 'nama', program_studi.nama)
                        )
                    ORDER BY program_studi.nama, tipe
                    ) AS kegiatan_kelas
            ")

            ->leftJoin("program_studi", "program_studi.id", "kelas_mata_kuliah.program_studi_id")
            ->leftJoin("mata_kuliah", "mata_kuliah.id", "kelas_mata_kuliah.mata_kuliah_id")
            ->groupBy("kegiatan_id", "kelas_mata_kuliah.program_studi_id", "tahun_ajaran_id", "tipe_semester_id", "mata_kuliah.nama");
    }
}
