<?php

namespace App\Http\Controllers;

use App\Casts\JsonCast;
use App\Constants\MessageState;
use App\Kegiatan;
use App\KelasMataKuliah;
use App\MataKuliah;
use App\ProgramStudi;
use App\Ruangan;
use App\TahunAjaran;
use App\TipeSemester;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class KegiatanBelajarController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Contracts\View\Factory|\Illuminate\Http\Response|\Illuminate\View\View
     */
    public function index(Request $request)
    {
        $program_studis = ProgramStudi::query()->orderBy("nama")->get();
        $tahun_ajarans = TahunAjaran::query()->orderByDesc("tahun_mulai")->get();
        $tipe_semesters = TipeSemester::query()->orderBy("nama")->get();

        $program_studi_id = $request->get("program_studi_id", $program_studis->first()->id);
        $tahun_ajaran_id = $request->get("tahun_ajaran_id", $tahun_ajarans->first()->id);
        $tipe_semester_id = $request->get("tipe_semester_id", $tipe_semesters->first()->id);

        $kegiatans = Kegiatan::query()
            ->select(
                "kegiatan.id",
                "hari_dalam_minggu",
                "tanggal_mulai",
                "tanggal_selesai",
                "waktu_mulai",
                "waktu_selesai",
                "berulang",
                "mata_kuliah.nama AS nama_mata_kuliah",
                "kelas_mata_kuliah.tipe_kelas",
                "ruangan.nama AS nama_ruangan"
            )
            ->orderByRaw("hari_dalam_minggu, waktu_mulai")
            ->leftJoin("ruangan", "ruangan.id", "kegiatan.ruangan_id")
            ->leftJoin("pola_perulangan", "pola_perulangan.kegiatan_id", "kegiatan.id")
            ->leftJoinSub(
                $this->getKelasKegiatanQuery()
                , "kelas_mata_kuliah", "kelas_mata_kuliah.kegiatan_id", "kegiatan.id")
            ->leftJoin("mata_kuliah", "mata_kuliah.id", "kelas_mata_kuliah.mata_kuliah_id")
            ->where("kelas_mata_kuliah.tahun_ajaran_id", "=", $tahun_ajaran_id)
            ->where("kelas_mata_kuliah.tipe_semester_id", "=", $tipe_semester_id)
            ->where("kelas_mata_kuliah.program_studi_id", "=", $program_studi_id)
            ->paginate();

        return view("kegiatan-belajar.index", compact(
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
     * @param \App\Kegiatan $kegiatan
     * @return \Illuminate\Contracts\View\Factory|\Illuminate\View\View
     * @throws \Illuminate\Validation\ValidationException
     */
    public function edit(Kegiatan $kegiatan_belajar, Request $request)
    {
        $data = $request->validate([
            "tahun_ajaran_id" => "required|exists:tahun_ajaran,id",
            "tipe_semester_id" => "required|exists:tipe_semester,id",
            "program_studi_id" => "required|exists:program_studi,id",
        ]);

        $kegiatan = Kegiatan::query()
            ->select(
                "kegiatan.id",
                "hari_dalam_minggu",
                "tanggal_mulai",
                "tanggal_selesai",
                "waktu_mulai",
                "waktu_selesai",
                "berulang",
                "mata_kuliah.nama AS nama_mata_kuliah",
                "kelas_mata_kuliah.tipe_kelas",
                "ruangan.nama AS nama_ruangan"
            )
            ->leftJoin("ruangan", "ruangan.id", "kegiatan.ruangan_id")
            ->leftJoin("pola_perulangan", "pola_perulangan.kegiatan_id", "kegiatan.id")
            ->leftJoin("mata_kuliah", "mata_kuliah.id", "kegiatan_kelas.mata_kuliah_id")
            ->where("kegiatan.id", $kegiatan_belajar->id)
            ->leftJoinSub($this->getKelasKegiatanQuery(), "kegiatan_kelas", "kegiatan_kelas.kegiatan_id", "kegiatan.id")
            ->get();

        $ruangans = Ruangan::query()->get();
        $mata_kuliahs = MataKuliah::query()
            ->where(function (Builder $query) use($data) {
                $query
                    ->where("program_studi_id", $data["program_studi_id"])
                    ->orWhere("program_studi_id", null);
            })
            ->get();

        return view("kegiatan-belajar.edit", array_merge([
            compact("ruangans", "mata_kuliahs", "kegiatan_belajar"),
            $data
        ]));
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
     * @return \Illuminate\Http\RedirectResponse|\Illuminate\Http\Response
     */
    public function destroy(Kegiatan $kegiatan_belajar)
    {
        $kegiatan_belajar->delete();

        return redirect()->back()
            ->with("messages", [
                [
                    "state" => MessageState::STATE_SUCCESS,
                    "content" => __("messages.delete.success")
                ]
            ]);
    }

    /**
     * @param int $program_studi_id
     * @return \Illuminate\Database\Eloquent\Builder
     */
    private function getKelasKegiatanQuery(): \Illuminate\Database\Eloquent\Builder
    {
        return KelasMataKuliah::query()
            ->select(
                "kegiatan_id",
                "mata_kuliah_id",
                "tahun_ajaran_id",
                "tipe_semester_id",
                "program_studi.id AS program_studi_id",
                DB::raw("string_agg(tipe, ',') AS tipe_kelas")
            )
            ->leftJoin("program_studi", "program_studi.id", "kelas_mata_kuliah.program_studi_id")
            ->groupBy("kegiatan_id", "mata_kuliah_id", "tahun_ajaran_id", "tipe_semester_id", "program_studi.id");
    }
}
