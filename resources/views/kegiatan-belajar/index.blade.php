@extends("layouts.app")


@section("content")
    <h1>
        Kegiatan Belajar
    </h1>

    <div class="card">
        <div class="card-header">
            Filter
        </div>

        <div class="card-body">
            <form>
                <div class="form-group">
                    <label for="tahun_ajaran_id"> Tahun Ajaran</label>
                    <select class="form-control"
                            name="tahun_ajaran_id"
                            id="tahun_ajaran_id">
                        @foreach($tahun_ajarans AS $tahun_ajaran)
                            <option value="{{ $tahun_ajaran->id }}" {{ $tahun_ajaran->id == old("tahun_ajaran_id", $tahun_ajaran_id) ? "selected" : ""}}>
                                {{ $tahun_ajaran->tahun_mulai }} - {{ $tahun_ajaran->tahun_selesai }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="form-group">
                    <label for="tipe_semester_id"> Tipe Semester</label>
                    <select class="form-control"
                            name="tipe_semester_id"
                            id="tipe_semester_id">
                        @foreach($tipe_semesters AS $tipe_semester)
                            <option value="{{ $tipe_semester->id }}" {{ $tipe_semester->id == old("tipe_semester_id", $tipe_semester_id) ? "selected" : ""}}>
                                {{ $tipe_semester->nama }}
                            </option>
                        @endforeach
                    </select>
                </div>

                <div class="form-group">
                    <label for="program_studi_id"> Program Studi</label>
                    <select class="form-control"
                            name="program_studi_id"
                            id="program_studi_id">
                        @foreach($program_studis AS $program_studi)
                            <option value="{{ $program_studi->id }}" {{ $program_studi->id == old("program_studi_id", $program_studi_id) ? "selected" : ""}}>
                                {{ $program_studi->nama }}
                            </option>
                        @endforeach
                    </select>
                </div>


                <div class="d-flex justify-content-end">
                    <button class="btn btn-primary">
                        Filter
                    </button>
                </div>
            </form>
        </div>
    </div>

    <div class="my-3">
        @include("layouts._messages")
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
                        <th class="text-center">
                            <i class="fas fa-cog  "></i>
                        </th>
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
                            <th> {{ $kegiatan->nama_ruangan }} </th>
                            <td class="d-flex justify-content-center">
                                <a href="{{ route("kegiatan-belajar.edit", ["kegiatan_belajar" => $kegiatan->id, "tipe_semester_id" => $tipe_semester_id, "tahun_ajaran_id" => $tahun_ajaran_id, "program_studi_id" => $program_studi_id]) }}"
                                   class="btn btn-sm btn-info mr-2">
                                    Ubah
                                    <i class="fas fa-pencil-alt  "></i>
                                </a>

                                <form method="POST" action="{{ route("kegiatan-belajar.destroy", $kegiatan) }}">
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
