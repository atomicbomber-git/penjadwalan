<div>
    @auth
        <nav class="breadcrumb">
            <a class="breadcrumb-item"
               href="{{ \App\Providers\RouteServiceProvider::defaultHomeRoute(auth()->user()) }}"
            >
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
            <form class="filter-form">
                <div class="form-row">
                    <div class="col">
                        <div class="form-group form-group-sm">
                            <label for="tahun_ajaran_id"> Tahun Ajaran </label>
                            <select class="form-control form-control-sm"
                                    wire:model.lazy="tahun_ajaran_id"
                                    id="tahun_ajaran_id"
                            >
                                @foreach($tahun_ajarans AS $ta)
                                    <option value="{{ $ta->id }}">
                                        {{ $ta->tahun_mulai }} - {{ $ta->tahun_selesai }}
                                    </option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                    <div class="col">
                        <div class="form-group form-group-sm">
                            <label for="tipe_semester_id"> Tipe Semester</label>
                            <select class="form-control form-control-sm"
                                    wire:model.lazy="tipe_semester_id"
                                    id="tipe_semester_id"
                            >
                                @foreach($tipe_semesters AS $tipe)
                                    <option value="{{ $tipe->id }}">
                                        {{ $tipe->nama }}
                                    </option>
                                @endforeach
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="col">
                        <div class="form-group form-group-sm">
                            <label for="program_studi_id"> Program Studi</label>
                            <select class="form-control form-control-sm"
                                    wire:model.lazy="program_studi_id"
                                    id="program_studi_id"
                            >
                                @foreach($program_studis AS $program_studi_item)
                                    <option value="{{ $program_studi_item->id }}">
                                        {{ $program_studi_item->nama }}
                                    </option>
                                @endforeach
                            </select>
                        </div>
                    </div>

                    <div class="col">
                        <div class="form-group">
                            <label for="ruangan_id"> Ruangan: </label>
                            <select
                                    wire:model.lazy="ruangan_id"
                                    id="ruangan_id"
                                    type="text"
                                    class="form-control form-control-sm @error("ruangan_id") is-invalid @enderror"
                            >
                                <option value="">
                                    ----------
                                </option>

                                @foreach ($ruangans as $ruangan_item)
                                    <option value="{{ $ruangan_item->id }}">
                                        {{ $ruangan_item->nama }}
                                    </option>
                                @endforeach
                            </select>
                            @error("ruangan_id")
                            <span class="invalid-feedback">
                                {{ $message }}
                            </span>
                            @enderror
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="my-3">
        @can(\App\Providers\AuthServiceProvider::MANAGE_KEGIATAN_BELAJAR)
            <div class="d-flex justify-content-end">
                <a
                        href="{{ route("kegiatan-belajar.create", [
                        "tipe_semester_id" => $tipe_semester->id,
                        "tahun_ajaran_id" => $tahun_ajaran->id,
                        "program_studi_id" => $program_studi->id,
                        ]) }}"
                        class="btn btn-dark btn-sm"
                >
                    Tambah Kegiatan Belajar
                    <i class="fas fa-plus"></i>
                </a>
            </div>
        @endcan

        @include("layouts._messages")
    </div>

    <div class="alert alert-info">
        Menampilkan kegiatan belajar untuk Program Studi
        <strong> {{ $program_studi->nama }} </strong>
        Tahun Ajaran <strong> {{ $tahun_ajaran->tahun_mulai }} - {{ $tahun_ajaran->tahun_selesai }} </strong>
        Semester <strong> {{ $tipe_semester->nama }} </strong>
        @if($ruangan !== null)
            Ruangan <strong> {{ $ruangan->nama }} </strong>
        @endif
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
                                       class="btn btn-sm btn-info mr-2 cypress-edit-button"
                                    >
                                        Ubah
                                        <i class="fas fa-pencil-alt  "></i>
                                    </a>

                                    <form method="POST"
                                          class="cypress-delete-button"
                                          action="{{ route("kegiatan-belajar.destroy", $kegiatan) }}"
                                    >
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
        {{ $kegiatans->links()  }}
    </div>
</div>
