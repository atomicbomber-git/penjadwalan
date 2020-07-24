@extends("layouts.app")


@section("content")
    @auth
    <nav class="breadcrumb">
        <a class="breadcrumb-item"
           href="{{ \App\Providers\RouteServiceProvider::defaultHomeRoute(auth()->user()) }}">
            {{ config("app.name")  }}
        </a>
        <span class="breadcrumb-item active">
            Kegiatan Belajar
        </span>
    </nav>
    @endauth

    <h1 class="feature-title">
        Kegiatan Belajar
    </h1>

    <div class="card">
        <div class="card-header">
            Filter
        </div>

        <div class="card-body">
            <form>
                <div class="form-group form-group-sm">
                    <label for="tahun_ajaran_id"> Tahun Ajaran</label>
                    <select class="form-control form-control-sm"
                            name="tahun_ajaran_id"
                            id="tahun_ajaran_id">
                        @foreach($tahun_ajarans AS $tahun_ajaran)
                            <option value="{{ $tahun_ajaran->id }}" {{ $tahun_ajaran->id == old("tahun_ajaran_id", $tahun_ajaran->id) ? "selected" : ""}}>
                                {{ $tahun_ajaran->tahun_mulai }} - {{ $tahun_ajaran->tahun_selesai }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="form-group form-group-sm">
                    <label for="tipe_semester_id"> Tipe Semester</label>
                    <select class="form-control form-control-sm"
                            name="tipe_semester_id"
                            id="tipe_semester_id">
                        @foreach($tipe_semesters AS $tipe_semester)
                            <option value="{{ $tipe_semester->id }}" {{ $tipe_semester->id == old("tipe_semester_id", $tipe_semester->id) ? "selected" : ""}}>
                                {{ $tipe_semester->nama }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="form-group form-group-sm">
                    <label for="program_studi_id"> Program Studi</label>
                    <select class="form-control form-control-sm"
                            name="program_studi_id"
                            id="program_studi_id">
                        @foreach($program_studis AS $program_studi)
                            <option value="{{ $program_studi->id }}" {{ $program_studi->id == old("program_studi_id", $program_studi->id) ? "selected" : ""}}>
                                {{ $program_studi->nama }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="d-flex justify-content-end">
                    <button class="btn btn-primary btn-sm">
                        Filter
                        <i class="fas fa-filter"></i>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <div class="my-3">
        <div class="d-flex justify-content-end">
            <a
                href="{{ route("kegiatan-belajar.create", [
                        "tipe_semester_id" => $tipe_semester->id,
                        "tahun_ajaran_id" => $tahun_ajaran->id,
                        "program_studi_id" => $program_studi->id,
                        ]) }}"
                class="btn btn-dark btn-sm">
                Tambah Kegiatan Belajar
                <i class="fas fa-plus"></i>
            </a>
        </div>

        @include("layouts._messages")
    </div>

    <div class="alert alert-info">
        Menampilkan kegiatan belajar untuk Program Studi <strong> {{ $program_studis[$program_studi->id]->nama }} </strong>
        Tahun Ajaran <strong> {{ $tahun_ajaran->tahun_mulai }} - {{ $tahun_ajaran->tahun_selesai }} </strong>
        Semester <strong> {{ $tipe_semester->nama }} </strong>
    </div>

    <div class="card my-3">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                    <tr>
                        <th> No</th>
                        <th style="width: 10rem"> Mata Kuliah / Kelas</th>
                        <th> Hari</th>
                        <th> W. Mulai - Selesai</th>
                        <th> Ruangan</th>
                        @auth
                            <th class="text-center">
                                <i class="fas fa-cog  "></i>
                            </th>
                        @endauth
                    </tr>
                    </thead>

                    <tbody>
                    @foreach($kegiatans AS $kegiatan)
                        <tr>
                            <td> {{ $kegiatans->firstItem() + $loop->index }} </td>
                            <td>
                                {{ $kegiatan->nama_mata_kuliah }}
                                /
                                <span class="text-primary font-weight-bolder">  {{ $kegiatan->tipe_kelas }} </span>
                            </td>
                            <td> {{ ucfirst(\App\Constants\IndonesianDays::getName($kegiatan->hari_dalam_minggu)) }} </td>
                            <td> {{ $kegiatan->waktu_mulai }} - {{ $kegiatan->waktu_selesai }} </td>
                            <td> {{ $kegiatan->nama_ruangan }} </td>
                            @auth
                                <td class="d-flex justify-content-center">
                                    <a href="{{ route("kegiatan-belajar.edit", [
                                                "kegiatan_belajar" => $kegiatan->id,
                                                "tipe_semester_id" => $tipe_semester->id,
                                                "tahun_ajaran_id" => $tahun_ajaran->id,
                                                "program_studi_id" => $program_studi->id,
                                                "page" => request("page") ?? 1,
                                         ]) }}"
                                       class="btn btn-sm btn-info mr-2">
                                        Ubah
                                        <i class="fas fa-pencil-alt  "></i>
                                    </a>

                                    <form method="POST"
                                          action="{{ route("kegiatan-belajar.destroy", $kegiatan) }}">
                                        @method("DELETE")
                                        @csrf

                                        <button
                                            class="btn btn-danger btn-sm ml-2"
                                        >
                                            Hapus
                                            <i class="fas fa-trash-alt"></i>
                                        </button>
                                    </form>
                                </td>
                            @endauth
                        </tr>
                    @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="d-flex justify-content-center">
        {{ $kegiatans->appends(request()->all())->links()  }}
    </div>
@endsection
