@extends("layouts.app")

@section("content")
    <div>
        <h1> Tambah Kegiatan Belajar </h1>

        <div class="font-weight-bolder text-uppercase">
            Tahun Ajaran <span class="text-primary"> {{ $tahun_ajaran->tahun_mulai }} / {{ $tahun_ajaran->tahun_selesai }} </span> <br>
            Semester <span class="text-primary"> {{ $tipe_semester->nama }} </span> <br>
            Program Studi <span class="text-primary"> {{ $program_studi->nama }} </span> <br>
        </div>

        <kegiatan-belajar-create
            :kelas_mata_kuliahs='{{ json_encode($kelas_mata_kuliahs) }}'
        ></kegiatan-belajar-create>
    </div>
@endsection
