<?php

namespace App\Http\Livewire;

use App\Casts\JsonCast;
use App\Jadwal;
use App\KelasMataKuliah;
use App\Ruangan;
use Illuminate\Contracts\View\Factory as ViewFactory;
use Illuminate\Database\Eloquent\Builder as EloquentBuilder;
use Illuminate\Http\Request;
use Livewire\Component;
use Livewire\WithPagination;

class PenggunaanRuanganIndex extends Component
{
    use WithPagination;
    protected $paginationTheme = 'bootstrap';

    public $ruangan_id;
    public $tanggal_mulai;
    public $tanggal_selesai;

    protected $queryString = [
        "ruangan_id" => ["except" => ""],
        "tanggal_mulai" => ["except" => ""],
        "tanggal_selesai" => ["except" => ""],
    ];

    protected $listeners = [
        "updateRuanganId" => "updateRuanganId",
    ];

    public function mount(Request $request)
    {
        $this->fill([
            "tanggal_mulai" => $request->query("tanggal_mulai", today()->format("Y-m-d")),
            "tanggal_selesai" => $request->query("tanggal_selesai", today()->format("Y-m-d")),
        ]);
    }

    public function updating($attributes)
    {
        if (in_array($attributes, ["ruangan_id", "tanggal_mulai", "tanggal_selesai",])) {
            $this->resetPage();
        }
    }

    public function updateRuanganId($ruangan_id)
    {
        $this->ruangan_id = $ruangan_id;
    }

    public function render(ViewFactory $viewFactory)
    {
        return $viewFactory->make("livewire.penggunaan-ruangan-index", [
            "jadwals" => $this->getJadwalQuery()->paginate(),
            "ruangan" => Ruangan::query()->find($this->ruangan_id ?: null),
            "ruangans" => $ruangans = Ruangan::query()
                ->select("id", "nama")
                ->orderBy("nama")
                ->get(),
            "unused_ruangans" => Ruangan::query()
                ->whereNotIn("id",
                    $this->getBaseJadwalQuery()
                        ->pluck("ruangan_id")
                )
                ->get(),
            "used_ruangan_count" => $this->getBaseJadwalQuery()
                ->selectRaw("COUNT(DISTINCT ruangan_id) AS ruangan_count")
                ->value("ruangan_count"),
            "tanggal_mulai" => $this->tanggal_mulai,
            "tanggal_selesai" => $this->tanggal_selesai,
        ]);
    }

    /**
     * @return EloquentBuilder
     */
    private function getKegiatanKelasQuery(): EloquentBuilder
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

    public function getBaseJadwalQuery()
    {
        return Jadwal::query()
            ->leftJoin("kegiatan", "kegiatan.id", "jadwal.kegiatan_id")
            ->leftJoin("mata_kuliah", "mata_kuliah.id", "kegiatan.mata_kuliah_id")
            ->leftJoin("ruangan", "ruangan.id", "kegiatan.ruangan_id")
            ->leftJoinSub($this->getKegiatanKelasQuery(), "kegiatan_kelas", "kegiatan_kelas.kegiatan_id", "kegiatan.id")
            ->when($this->ruangan_id, function (EloquentBuilder $builder) {
                $builder->where("ruangan.id", $this->ruangan_id);
            })
            ->when($this->tanggal_mulai, function (EloquentBuilder $builder) {
                $builder->whereRaw("LOWER(rentang_waktu)::date >= ?", [$this->tanggal_mulai]);
            })
            ->when($this->tanggal_selesai, function (EloquentBuilder $builder) {
                $builder->whereRaw("UPPER(rentang_waktu)::date <= ?", [$this->tanggal_selesai]);
            });
    }

    /**
     * @return \Illuminate\Database\Concerns\BuildsQueries|EloquentBuilder|mixed
     */
    private function getJadwalQuery()
    {
        return $this->getBaseJadwalQuery()
            ->selectRaw("LOWER(rentang_waktu) AS waktu_mulai")
            ->selectRaw("UPPER(rentang_waktu) AS waktu_selesai")
            ->selectRaw("ruangan.nama AS nama_ruangan")
            ->selectRaw("kegiatan_kelas")
            ->selectRaw("mata_kuliah")
            ->orderBy("rentang_waktu")
            ->withCasts([
                "kegiatan_kelas" => JsonCast::class,
                "mata_kuliah" => JsonCast::class,
            ]);
    }
}
