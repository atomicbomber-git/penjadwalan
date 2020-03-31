@extends("layouts.app")


@section("content")
    <h1> Kegiatan </h1>

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
                    <label for="program_studi_id"> Program Studi </label>
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

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                    <tr>
                        <th> No</th>
                        <th> Mata Kuliah</th>
                        <th> Hari </th>
                    </tr>
                    </thead>

                    <tbody>
                    @foreach($kegiatans AS $kegiatan)
                        <tr>
                            <td> {{ $loop->iteration }} </td>
                            <td> {{ $kegiatan->nama_mata_kuliah }} </td>
                            <td> {{ \App\Constants\IndonesianDays::getName($kegiatan->hari_dalam_minggu) }} </td>
                        </tr>
                    @endforeach
                    </tbody>
                </table>

            </div>

        </div>
    </div>
@endsection
