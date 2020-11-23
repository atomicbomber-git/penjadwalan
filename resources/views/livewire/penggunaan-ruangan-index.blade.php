<div>
    <nav class="breadcrumb">
        <a class="breadcrumb-item"
           href="{{ \App\Providers\RouteServiceProvider::defaultHomeRoute(auth()->user()) }}"
        >
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

        <div class="card">
            <div class="card-header">
                Filter
            </div>

            <div class="card-body">
                <div class="form-group">
                    <label for="ruangan_id"
                           wire:key="ruangan_id_label"
                    > Ruangan: </label>
                    <div wire:ignore
                         wire:key="ruangan_id_select"
                    >
                        <select
                                id="ruangan_id"
                                type="text"
                                class="form-control @error("ruangan_id") is-invalid @enderror"
                        >
                            @foreach ($ruangans as $ruangan_item)
                                <option
                                        value="{{ $ruangan_item->id }}"
                                        @if($ruangan_item->id == request("ruangan_id")) selected @endif >
                                    {{ $ruangan_item->nama }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    @error("ruangan_id")
                    <span class="invalid-feedback"
                          wire:key="ruangan_id_feedback"
                    >
                            {{ $message }}
                        </span>
                    @enderror

                    @push("scripts")
                        <script type="application/javascript">
                            function setupSelectRuanganId() {
                                $("#ruangan_id").select2({
                                    theme: "bootstrap4",
                                    allowClear: true,
                                    placeholder: "Ruangan",
                                }).change(event => {
                                    Livewire.emit('updateRuanganId', event.target.value)
                                })
                            }
                            jQuery(function () {
                                setupSelectRuanganId()
                            })
                        </script>
                    @endpush
                </div>

                <div class="form-row">
                    <div class="col">
                        <div class="form-group">
                            <label for="tanggal_mulai"> Tanggal Mulai: </label>
                            <input
                                    id="tanggal_mulai"
                                    type="date"
                                    placeholder="Tanggal Mulai"
                                    class="form-control @error("tanggal_mulai") is-invalid @enderror"
                                    wire:model.lazy="tanggal_mulai"
                                    value="{{ old("tanggal_mulai") }}"
                            />
                            @error("tanggal_mulai")
                            <span class="invalid-feedback">
                                {{ $message }}
                            </span>
                            @enderror
                        </div>
                    </div>
                    <div class="col">
                        <div class="form-group">
                            <label for="tanggal_selesai"> Tanggal Selesai: </label>
                            <input
                                    id="tanggal_selesai"
                                    type="date"
                                    placeholder="Tanggal Selesai"
                                    class="form-control @error("tanggal_selesai") is-invalid @enderror"
                                    wire:model.lazy="tanggal_selesai"
                                    value="{{ old("tanggal_selesai") }}"
                            />
                            @error("tanggal_selesai")
                            <span class="invalid-feedback">
                                {{ $message }}
                            </span>
                            @enderror
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="alert alert-info my-3">
        Menampilkan penggunaan
        @if($ruangan)
            ruangan <strong> {{ $ruangan->nama }} </strong>
        @endif

        dalam rentang waktu
        <strong>
            {{ \App\Helpers\Formatter::fancyDate($tanggal_mulai) }} -
            {{ \App\Helpers\Formatter::fancyDate($tanggal_selesai) }}
        </strong>
    </div>

    <div class="alert alert-primary my-3">
        Total ruangan yang digunakan adalah <strong> {{ $used_ruangan_count }} </strong> dari
        <strong> {{ $ruangans->count() }} </strong> ruangan yang ada.
    </div>

    <div class="alert alert-primary my-3 d-flex justify-content-between align-self-center">
        <div>
            Terdapat <strong> {{ $unused_ruangans->count() }} </strong> ruangan yang tidak digunakan. <a> </a>
        </div>

        <button
                wire:click="toggleShowUnusedRuangans"
                class="btn {{ $this->show_unused_ruangans ? "btn-danger" : "btn-light" }} btn-sm">
            {{ $this->show_unused_ruangans ? "Sembunyikan" : "Tampilkan" }}
            <i class="fas {{ $this->show_unused_ruangans ? "fa-eye-slash" : "fa-eye" }}  "></i>
        </button>


    </div>

    @if($this->show_unused_ruangans)
        <div class="card">
            <div class="card-header"> Daftar Ruangan yang tidak Digunakan </div>

            <div class="card-body">
                <table class="table table-sm">
                    @foreach ($unused_ruangans->chunk(6) as $unused_ruangan_chunk)
                        <tr>
                            @foreach ($unused_ruangan_chunk as $unused_ruangan)
                                <td> {{ $unused_ruangan->nama }} </td>
                            @endforeach
                        </tr>
                    @endforeach
                </table>
            </div>
        </div>
    @endif

    @foreach($jadwals AS $jadwal)
        <div class="card my-3">
            <div class="card-body">
                <div class="card-title d-block h5">
                    <span class="h4 d-block font-weight-bold">
                        @switch(true)
                            @case($jadwal->mata_kuliah)
                            <span class="text-primary"> ({{ $jadwal->nama_ruangan }})  </span>
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
                        <dt> Program Studi / Kelas</dt>
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
        {{ $jadwals->links() }}
    </div>
</div>
