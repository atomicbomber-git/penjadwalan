@extends("layouts.app")

@section("content")
    <nav class="breadcrumb">
        <a class="breadcrumb-item"
           href="{{ \App\Providers\RouteServiceProvider::defaultHomeRoute(auth()->user()) }}">
            {{ config("app.name")  }}
        </a>
        <a class="breadcrumb-item"
           href="{{ route("kegiatan-belajar.index", request()->query()) }}">
            Kegiatan Belajar
        </a>
        <span class="breadcrumb-item active">
            Ubah Kegiatan Belajar
        </span>
    </nav>

    <h1 class="feature-title">
        Ubah Kegiatan Belajar
    </h1>

    <div class="card">
        <div class="card-body">
            <div class="font-weight-bolder text-uppercase">
                Tahun Ajaran
                <span class="text-primary"> {{ $tahun_ajaran->tahun_mulai }} / {{ $tahun_ajaran->tahun_selesai }} </span>
                <br>
                Semester
                <span class="text-primary"> {{ $tipe_semester->nama }} </span>
                <br>
                Program Studi
                <span class="text-primary"> {{ $program_studi->nama }} </span>
                <br>
                Mata Kuliah
                <span class="text-primary"> {{ $kelas_mata_kuliahs->first()->mata_kuliah->nama }} </span>
                <br>
            </div>
        </div>
    </div>

    @include("layouts._messages")

    <kegiatan-belajar-edit
        :kegiatan_belajar='{{ json_encode($kegiatan_belajar) }}'
        submit_url="{{ route("kegiatan-belajar.update", $kegiatan_belajar->id) }}"
        redirect_url="{{ route("kegiatan-belajar.edit", array_merge([
    "kegiatan_belajar" => $kegiatan_belajar->id,
], request()->query())) }}"
        :kelas_mata_kuliahs='{{ json_encode($kelas_mata_kuliahs) }}'
        :ruangans='{{ json_encode($ruangans) }}'
        :tipe_semester_id="{{ request("tipe_semester_id") }}"
        :tahun_ajaran_id="{{ request("tahun_ajaran_id") }}"
        :program_studi_id="{{ request("program_studi_id") }}"
        :days='{{ json_encode($days) }}'
    ></kegiatan-belajar-edit>
@endsection
