<?php

namespace App\Http\Controllers;

use App\Constants\MessageState;
use App\Kegiatan;
use App\KelasMataKuliah;
use App\MataKuliah;
use App\ProgramStudi;
use App\Ruangan;
use App\TahunAjaran;
use App\TipeSemester;
use Exception;
use Illuminate\Contracts\View\Factory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class KegiatanBelajarController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Factory|Response|View
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
     * @return Response
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

        $mata_kuliahs = MataKuliah::query()
            ->when($tipe_semester->nama == "GASAL", function (Builder $builder) {
                $builder->whereRaw("semester % 2 = 1");
            })
            ->when($tipe_semester->nama == "GENAP", function (Builder $builder) {
                $builder->whereRaw("semester % 2 = 0");
            })
            ->where(function (Builder $builder) use ($program_studi) {
                $builder
                    ->where("program_studi_id", $program_studi->id)
                    ->orWhereNull("program_studi_id");
            })
            ->orderBy("nama")
            ->get();

        $ruangans = Ruangan::query()
            ->orderBy("nama")
            ->get();

        return response()->view("kegiatan-belajar.create", compact(
            "kelas_mata_kuliahs",
            "tahun_ajaran",
            "tipe_semester",
            "program_studi",
            "ruangans",
            "mata_kuliahs"
        ));
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param Request $request
     * @return Response
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            "tipes.*.name" => ["required"],
            "mata_kuliah_id" => ["required", Rule::exists(MataKuliah::class, "id")],
            "tanggal_mulai" => ["required", "date_format:Y-m-d"],
            "tanggal_selesai" => ["required", "date_format:Y-m-d"],
            "waktu_mulai" => ["required", "date_format:H:i:s"],
            "waktu_selesai" => ["required", "date_format:H:i:s"],
            "ruangan_id" => ["required", Rule::exists(Ruangan::class, "id")],
            "tipe_semester_id" => ["required"],
            "tahun_ajaran_id" => ["required"],
            "program_studi_id" => ["required"],
        ]);

        DB::beginTransaction();

        $kegiatan = Kegiatan::query()->create(array_merge(Arr::only($data, [
            "tanggal_mulai",
            "tanggal_selesai",
            "waktu_mulai",
            "waktu_selesai",
            "ruangan_id",
        ]), [
            "berulang" => 0,
        ]));

        foreach ($data["tipes"] as $tipe) {
            KelasMataKuliah::query()->create([
                "kegiatan_id" => $kegiatan->id,
                "tipe" => $tipe["name"],
                "mata_kuliah_id" => $data["mata_kuliah_id"],
                "tipe_semester_id" => $data["tipe_semester_id"],
                "tahun_ajaran_id" => $data["tahun_ajaran_id"],
                "program_studi_id" => $data["program_studi_id"],
            ]);
        }

        DB::commit();
    }

    /**
     * Display the specified resource.
     *
     * @param Kegiatan $kegiatan
     * @return Response
     */
    public function show(Kegiatan $kegiatan)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param Kegiatan $kegiatan
     * @return Response
     * @throws ValidationException
     */
    public function edit(Kegiatan $kegiatan_belajar, Request $request)
    {
        $ruangans = Ruangan::query()
            ->orderBy("nama")
            ->get();

        return response()->view("kegiatan-belajar.edit", compact(
            "kegiatan_belajar",
            "ruangans"
        ));
    }

    /**
     * Update the specified resource in storage.
     *
     * @param Request $request
     * @param Kegiatan $kegiatan_belajar
     * @return RedirectResponse
     */
    public function update(Request $request, Kegiatan $kegiatan_belajar)
    {
        $data = $request->validate([
            "tanggal_mulai" => ["required", "date_format:Y-m-d"],
            "tanggal_selesai" => ["required", "date_format:Y-m-d"],
            "waktu_mulai" => ["required", "date_format:H:i:s"],
            "waktu_selesai" => ["required", "date_format:H:i:s"],
            "ruangan_id" => ["required", Rule::exists(Ruangan::class, "id")],
        ]);

        $kegiatan_belajar->update($data);

        return redirect()->back()
            ->with("messages", [
                [
                    "state" => MessageState::STATE_SUCCESS,
                    "content" => __("messages.update.success")
                ]
            ]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param Kegiatan $kegiatan
     * @return RedirectResponse|Response
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
        } catch (Exception $exception) {
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
     * @return Builder
     */
    private function getKelasKegiatanQuery(): Builder
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
