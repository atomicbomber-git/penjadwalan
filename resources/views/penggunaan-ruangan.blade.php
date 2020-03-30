@extends("layouts.app")

@section("content")
    <h1>
        Penggunaan Ruangan
    </h1>

    <penggunaan-ruangan-filter
        filter-waktu-mulai="{{ $filter_waktu_mulai ?? null }}"
        filter-waktu-selesai="{{ $filter_waktu_selesai ?? null }}"
        :filter-ruangan-id='{{ $filter_ruangan_id ?? null }}'
        :ruangans='{{ json_encode($ruangans ?? null) }}'
    ></penggunaan-ruangan-filter>

    @foreach($jadwals AS $jadwal)
        <div class="card mt-3">
            <div class="card-title">
                <span class="text-primary d-block h5 font-weight-bold"> {{ \App\Helpers\Formatter::fancyDatetime($jadwal->waktu_mulai) }} - {{ \App\Helpers\Formatter::fancyDatetime($jadwal->waktu_selesai) }} </span>

            </div>

            <div class="card-body">

                <dl>
                    @foreach($jadwal->detail_penggunaans AS $detail_penggunaan)


                        <dt>
                            Mata Kuliah
                        </dt>

                        <dd>
                            {{ $detail_penggunaan->mata_kuliah->nama }}
                        </dd>

                        <dt> Program Studi / Kelas </dt>
                        <dd>
                            {{ $detail_penggunaan->program_studi->nama }} / {{ $detail_penggunaan->tipe }}
                        </dd>

                    @endforeach
                </dl>
            </div>
        </div>
    @endforeach

    <div class="d-flex justify-content-center mt-3">
        {{ $jadwals->appends(request()->all(["filter_ruangan_id", "filter_waktu_mulai", "filter_waktu_selesai"]))->links() }}
    </div>
@endsection
