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

    <h1 class="feature-title">
        Penggunaan Ruangan
    </h1>

    <div class="mb-3">
        <penggunaan-ruangan-filter
            filter-waktu-mulai="{{ $filter_waktu_mulai ?? null }}"
            filter-waktu-selesai="{{ $filter_waktu_selesai ?? null }}"
            :filter-ruangan-id='{{ $filter_ruangan_id ?? null }}'
            :ruangans='{{ json_encode($ruangans ?? null) }}'
        ></penggunaan-ruangan-filter>
    </div>

    <div class="alert alert-info my-3">
        Menampilkan penggunaan ruangan <strong> {{ $ruangan->nama }} </strong> dari
        <strong>
            {{ \App\Helpers\Formatter::fancyDatetime($filter_waktu_mulai) }} -
            {{ \App\Helpers\Formatter::fancyDatetime($filter_waktu_selesai) }}
        </strong>
    </div>

    @foreach($jadwals AS $jadwal)
        <div class="card my-3">
            <div class="card-body">
                <div class="card-title d-block h5">
                    <span class="h4 d-block font-weight-bold">
                        @switch(true)
                            @case($jadwal->mata_kuliah)
                                    {{ $jadwal->mata_kuliah->nama }}
                            @break
                            @case($jadwal->seminar)
                                {{ $jadwal->seminar->nama }}
                            @break
                        @endswitch
                    </span>

                    <span class="d-block text-primary">
                        {{ \App\Helpers\Formatter::fancyDatetime($jadwal->waktu_mulai) }} -
                        {{ \App\Helpers\Formatter::fancyDatetime($jadwal->waktu_selesai) }}
                    </span>
                </div>

                @if($jadwal->mata_kuliah)
                    <dl>
                        <dt> Program Studi / Kelas </dt>
                        <dd>
                            @foreach($jadwal->kegiatan_kelas ?? [] AS $kegiatan_kelas)
                                <span class="d-block">
                            {{ $kegiatan_kelas->program_studi->nama }} /
                            {{ $kegiatan_kelas->tipe }}
                        </span>
                            @endforeach
                        </dd>
                    </dl>
                @endif
            </div>
        </div>
    @endforeach

    <div class="d-flex justify-content-center mt-3">
        {{ $jadwals->appends(request()->all(["filter_ruangan_id", "filter_waktu_mulai", "filter_waktu_selesai"]))->links() }}
    </div>
@endsection
