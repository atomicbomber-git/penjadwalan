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

    @include("layouts._messages")

    <div class="card">
        <div class="card-body">
            <form action="{{ route("kegiatan-belajar.update", $kegiatan_belajar) }}"
                  method="POST">
                @csrf
                @method("PUT")

                <div class="form-group">
                    <label for="tanggal_mulai"> Tanggal Mulai:</label>
                    <input
                        id="tanggal_mulai"
                        type="date"
                        placeholder="Tanggal Mulai"
                        class="form-control @error("tanggal_mulai") is-invalid @enderror"
                        name="tanggal_mulai"
                        value="{{ old("tanggal_mulai", $kegiatan_belajar->tanggal_mulai) }}"
                    />
                    @error("tanggal_mulai")
                    <span class="invalid-feedback">
                        {{ $message }}
                    </span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="tanggal_selesai"> Tanggal Selesai:</label>
                    <input
                        id="tanggal_selesai"
                        type="date"
                        placeholder="Tanggal Selesai"
                        class="form-control @error("tanggal_selesai") is-invalid @enderror"
                        name="tanggal_selesai"
                        value="{{ old("tanggal_selesai", $kegiatan_belajar->tanggal_selesai) }}"
                    />
                    @error("tanggal_selesai")
                    <span class="invalid-feedback">
                        {{ $message }}
                    </span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="waktu_mulai"> Waktu Mulai:</label>
                    <input
                        id="waktu_mulai"
                        type="time"
                        placeholder="Waktu Mulai"
                        class="form-control @error("waktu_mulai") is-invalid @enderror"
                        name="waktu_mulai"
                        value="{{ old("waktu_mulai", $kegiatan_belajar->waktu_mulai) }}"
                    />
                    @error("waktu_mulai")
                    <span class="invalid-feedback">
                        {{ $message }}
                    </span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="waktu_selesai"> Waktu Selesai:</label>
                    <input
                        id="waktu_selesai"
                        type="time"
                        placeholder="Waktu Selesai"
                        class="form-control @error("waktu_selesai") is-invalid @enderror"
                        name="waktu_selesai"
                        value="{{ old("waktu_selesai", $kegiatan_belajar->waktu_selesai) }}"
                    />
                    @error("waktu_selesai")
                    <span class="invalid-feedback">
                        {{ $message }}
                    </span>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="ruangan_id"> Ruangan:</label>
                    <select
                        class="form-control"
                        name="ruangan_id"
                        id="ruangan_id">
                        @foreach($ruangans AS $ruangan)
                            <option
                                {{ old("ruangan_id", $kegiatan_belajar->ruangan_id) === $ruangan->id ? "selected" : "" }}
                                value="{{ $ruangan->id }}">
                                {{ $ruangan->nama }}
                            </option>
                        @endforeach
                    </select>
                    @error("ruangan_id")
                    <span class="invalid-feedback">
                        {{ $message }}
                    </span>
                    @enderror
                </div>

                <div class="d-flex justify-content-end">
                    <button class="btn btn-primary">
                        Ubah
                    </button>
                </div>
            </form>
        </div>
    </div>
@endsection
