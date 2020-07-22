@extends("layouts.app")

@section("content")
    <nav class="breadcrumb">
        <a class="breadcrumb-item"
           href="{{ \App\Providers\RouteServiceProvider::defaultHomeRoute(auth()->user()) }}">
            {{ config("app.name")  }}
        </a>
        <span class="breadcrumb-item active">
            Penggunaan Ruangan
        </span>
    </nav>

    <h1 class="feature-title"> Tambah Kegiatan Belajar </h1>

    <div class="card">
        <div class="card-body">
            <div class="font-weight-bolder text-uppercase">
                Tahun Ajaran <span class="text-primary"> {{ $tahun_ajaran->tahun_mulai }} / {{ $tahun_ajaran->tahun_selesai }} </span> <br>
                Semester <span class="text-primary"> {{ $tipe_semester->nama }} </span> <br>
                Program Studi <span class="text-primary"> {{ $program_studi->nama }} </span> <br>
            </div>
        </div>
    </div>

    <kegiatan-belajar-create
        :kelas_mata_kuliahs='{{ json_encode($kelas_mata_kuliahs) }}'
    ></kegiatan-belajar-create>
@endsection
