<?php

namespace App\Http\Livewire;

use App\Ruangan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Livewire\Component;
use App\ProgramStudi;
use App\TahunAjaran;
use App\TipeSemester;
use App\Kegiatan;
use App\KelasMataKuliah;
use Illuminate\Database\Eloquent\Builder;
use Livewire\WithPagination;

class KegiatanBelajarIndex extends Component
{
    use WithPagination;
    protected $paginationTheme = 'bootstrap';

    public $tahun_ajaran_id;
    public $program_studi_id;
    public $tipe_semester_id;
    public $ruangan_id;

    protected $queryString = [
        "tahun_ajaran_id" => ["except" => ""],
        "program_studi_id" => ["except" => ""],
        "tipe_semester_id" => ["except" => ""],
        "ruangan_id" => ["except" => ""],
    ];

    public function mount(Request $request)
    {
        $this->tahun_ajaran_id = $request->get("tahun_ajaran_id", TahunAjaran::query()->value("id"));
        $this->program_studi_id = $request->get("program_studi_id", ProgramStudi::query()->value("id"));
        $this->tipe_semester_id = $request->get("tipe_semester_id", TipeSemester::query()->value("id"));
        $this->ruangan_id = $request->get("ruangan_id", null);
    }

    public function updating($attributes)
    {
        if (in_array($attributes, ["tahun_ajaran_id", "program_studi_id", "tipe_semester_id",])) {
            $this->resetPage();
        }
    }

    public function render(Request $request)
    {
        $program_studis = ProgramStudi::query()->orderBy("nama")->get();
        $tahun_ajarans = TahunAjaran::query()->orderByDesc("tahun_mulai")->get();
        $tipe_semesters = TipeSemester::query()->orderBy("nama")->get();
        $ruangans = Ruangan::query()->orderBy("nama")->get();

        $program_studi = ProgramStudi::query()->find($this->program_studi_id);
        $tahun_ajaran = TahunAjaran::query()->find($this->tahun_ajaran_id);
        $tipe_semester = TipeSemester::query()->find($this->tipe_semester_id);

        $ruangan = Ruangan::query()->find($this->ruangan_id ?: null);

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
            ->when($this->ruangan_id, function (Builder $builder) {
                $builder->where("ruangan_id", $this->ruangan_id);
            })
            ->paginate();

        return view('livewire.kegiatan-belajar-index', compact(
            "program_studis",
            "tahun_ajarans",
            "tipe_semesters",
            "kegiatans",
            "program_studi",
            "tahun_ajaran",
            "tipe_semester",
            "ruangans",
            "ruangan",
        ));
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
