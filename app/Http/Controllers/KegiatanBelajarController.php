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
        $program_studis = ProgramStudi::query()->orderBy("nama")->get()->keyBy("id");
        $tahun_ajarans = TahunAjaran::query()->orderByDesc("tahun_mulai")->get()->keyBy("id");
        $tipe_semesters = TipeSemester::query()->orderBy("nama")->get()->keyBy("id");

        $program_studi = $program_studis->find($request->get("program_studi_id", $program_studis->first()->id));
        $tahun_ajaran = $tahun_ajarans->find($request->get("tahun_ajaran_id", $tahun_ajarans->first()->id));
        $tipe_semester = $tipe_semesters->find($request->get("tipe_semester_id", $tipe_semesters->first()->id));

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
            ->where("kelas_mata_kuliah.tahun_ajaran_id", "=", $tahun_ajaran->id)
            ->where("kelas_mata_kuliah.tipe_semester_id", "=", $tipe_semester->id)
            ->where("kelas_mata_kuliah.program_studi_id", "=", $program_studi->id)
            ->paginate();

        return view("kegiatan-belajar.index", compact(
            "program_studis",
            "tahun_ajarans",
            "tipe_semesters",
            "kegiatans",
            "program_studi",
            "tahun_ajaran",
            "tipe_semester",
        ));
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create(Request $request)
    {
        $data = $request->validate([
            "tahun_ajaran_id" => "required|exists:tahun_ajaran,id",
            "tipe_semester_id" => "required|exists:tipe_semester,id",
            "program_studi_id" => "required|exists:program_studi,id",
        ]);

        $tahun_ajaran = TahunAjaran::find($data["tahun_ajaran_id"]);
        $tipe_semester = TipeSemester::find($data["tipe_semester_id"]);
        $program_studi = ProgramStudi::find($data["program_studi_id"]);

        $kelas_mata_kuliahs = KelasMataKuliah::query()
            ->where([
                "kelas_mata_kuliah.tahun_ajaran_id" => $data["tahun_ajaran_id"],
                "kelas_mata_kuliah.tipe_semester_id" => $data["tipe_semester_id"],
                "kelas_mata_kuliah.program_studi_id" => $data["program_studi_id"],
            ])
            ->leftJoin("mata_kuliah", "mata_kuliah.id", "kelas_mata_kuliah.mata_kuliah_id")
            ->orderByRaw("mata_kuliah.nama, kelas_mata_kuliah.tipe")
            ->get();

        return response()->view("kegiatan-belajar.create", compact(
            "kelas_mata_kuliahs",
            "tahun_ajaran",
            "tipe_semester",
            "program_studi"
        ));
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
        $messages = [];

        try {
            $kegiatan_belajar->delete();
            $messages[] = [
                "state" => MessageState::STATE_SUCCESS,
                "content" => __("messages.delete.success")
            ];
        } catch (\Exception $exception) {
            $messages[] = [
                "state" => MessageState::STATE_DANGER,
                "content" => __("messages.delete.failure")
            ];
        }

        return redirect()->back()
            ->with("messages", $messages);
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
