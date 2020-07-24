<template>
    <div class="card my-3">
        <div class="card-body">
            <form @submit.prevent="onFormSubmit">
                <table class="table table-sm table-striped table-bordered">
                    <thead>
                    <tr>
                        <td> #</td>
                        <td> Tipe Kelas</td>
                        <td class="text-center"> Kendali</td>
                    </tr>
                    </thead>

                    <tbody>
                    <tr v-for="(tipe, index) in tipes"
                        :key="index">
                        <td> {{ index + 1 }}</td>
                        <td>
                            <label :for="`tipe_${index}`">
                                <input
                                    :id="`tipe_${index}`"
                                    class="form-control form-control-sm"
                                    :class="{'error': get(error_data, ['errors', `tipes.${index}.nama`, 0], false)}"
                                    v-model="tipe.name"
                                    placeholder="Tipe"
                                />
                            </label>

                            <label class="error">
                                {{ get(error_data, ['errors', `tipes.${index}.tipe`, 0], '') }}
                            </label>
                        </td>
                        <td class="text-center">
                            <button @click="removeTipe(tipe)"
                                    type="button"
                                    class="btn btn-danger btn-sm">
                                <i class="fas fa-trash "></i>
                            </button>
                        </td>
                    </tr>
                    </tbody>
                </table>

                <div class="d-flex justify-content-end">
                    <button type="button"
                            @click="addTipe"
                            class="btn btn-primary btn-sm">
                        Tambah Tipe Kelas
                    </button>
                </div>

                <div class="form-group">
                    <label for="hari_dalam_minggu">
                        Hari dalam Minggu:
                    </label>

                    <select
                        class="form-control"
                        name="hari_dalam_minggu"
                        id="hari_dalam_minggu"
                        v-model.number="day"
                    >
                        <option
                            v-for="(day, index) in m_days"
                            :key="index"
                            :value="day.id">
                            {{ day.name }}
                        </option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="tanggal_mulai">
                        Tanggal Mulai:
                    </label>

                    <input
                        id="tanggal_mulai"
                        v-model="tanggal_mulai"
                        placeholder="Tanggal Mulai"
                        class="form-control"
                        :class="{ 'is-invalid': get(this.error_data, 'tanggal_mulai[0]', false) }"
                        type="date"
                    />
                    <label class="invalid-feedback">
                        {{ get(this.error_data, 'tanggal_mulai[0]', '') }}
                    </label>
                </div>

                <div class="form-group">
                    <label for="tanggal_selesai">
                        Tanggal Selesai:
                    </label>

                    <input
                        id="tanggal_selesai"
                        v-model="tanggal_selesai"
                        placeholder="Tanggal Selesai"
                        class="form-control"
                        :class="{ 'is-invalid': get(this.error_data, 'tanggal_selesai[0]', false) }"
                        type="date"
                    />
                    <label class="invalid-feedback">
                        {{ get(this.error_data, 'tanggal_selesai[0]', '') }}
                    </label>
                </div>

                <div class="form-group">
                    <label for="waktu_mulai">
                        Waktu Mulai:
                    </label>

                    <input
                        id="waktu_mulai"
                        v-model="waktu_mulai"
                        placeholder="Waktu Mulai"
                        class="form-control"
                        :class="{ 'is-invalid': get(this.error_data, 'waktu_mulai[0]', false) }"
                        type="time"
                    />
                    <label class="invalid-feedback">
                        {{ get(this.error_data, 'waktu_mulai[0]', '') }}
                    </label>
                </div>

                <div class="form-group">
                    <label for="waktu_selesai">
                        Waktu Selesai:
                    </label>

                    <input
                        id="waktu_selesai"
                        v-model="waktu_selesai"
                        placeholder="Waktu Selesai"
                        class="form-control"
                        :class="{ 'is-invalid': get(this.error_data, 'waktu_selesai[0]', false) }"
                        type="time"
                    />
                    <label class="invalid-feedback">
                        {{ get(this.error_data, 'waktu_selesai[0]', '') }}
                    </label>
                </div>

                <div class="form-group">
                    <label for="ruangan_id">
                        Ruangan:
                    </label>

                    <multiselect
                        id="ruangan_id"
                        style=""
                        placeholder="Ruangan"
                        selectLabel=""
                        selectedLabel=""
                        deselectLabel=""
                        track-by="id"
                        :custom-label="ruanganLabel"
                        :options="ruangans"
                        v-model="ruangan"
                    >
                    </multiselect>
                </div>

                <div class="form-group d-flex justify-content-end">
                    <button class="btn btn-primary">
                        Tambah
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>


<script>
    import moment from "moment"

    let tipeIdCounter = 0

    export default {
        props: {
            "kegiatan_belajar": Object,
            "ruangans": Array,
            "kelas_mata_kuliahs": Array,
            "submit_url": String,
            "redirect_url": String,
            "tipe_semester_id": Number,
            "tahun_ajaran_id": Number,
            "program_studi_id": Number,
            "days": Object,
        },

        components: {
            Multiselect: require("vue-multiselect").Multiselect,
            datetime: require("vue-datetime").Datetime,
        },

        data() {
            return {
                tipes: this.kelas_mata_kuliahs.map(kmk => ({
                    id: kmk.id,
                    name: kmk.tipe,
                })),
                m_days: Object.keys(this.days).map(index => {
                    return {
                        id: index,
                        name: this.days[index],
                    }
                }),

                tanggal_mulai: this.kegiatan_belajar.tanggal_mulai,
                tanggal_selesai: this.kegiatan_belajar.tanggal_selesai,
                waktu_mulai: this.kegiatan_belajar.waktu_mulai,
                waktu_selesai: this.kegiatan_belajar.waktu_selesai,
                ruangan: this.ruangans.find(r => r.id === this.kegiatan_belajar.ruangan_id),
                day: this.kegiatan_belajar.pola_perulangan.hari_dalam_minggu,
            }
        },

        methods: {
            addTipe() {
                this.tipes = [
                    ...this.tipes,
                    {
                        id: ++tipeIdCounter,
                        name: "",
                    }
                ]
            },

            removeTipe(tipe) {
                this.tipes = this.tipes.filter(t => t.id !== tipe.id)
            },

            onFormSubmit() {
                axios.put(this.submit_url, this.form_data)
                    .then(response => {
                        window.location.replace(this.redirect_url)
                    })
                    .catch(error => {
                        this.error_data = error.response.data
                    })
            },

            ruanganLabel(ruangan) {
                return ruangan.nama
            }
        },

        computed: {
            form_data() {
                return {
                    tipes: this.tipes,
                    tanggal_mulai: this.tanggal_mulai,
                    tanggal_selesai: this.tanggal_selesai,
                    waktu_mulai: moment(moment().format("YYYY-MM-DD") + " " + this.waktu_mulai).format("HH:mm:ss"),
                    waktu_selesai: moment(moment().format("YYYY-MM-DD") + " " + this.waktu_selesai).format("HH:mm:ss"),
                    ruangan_id: this.get(this.ruangan, "id"),
                    tipe_semester_id: this.tipe_semester_id,
                    tahun_ajaran_id: this.tahun_ajaran_id,
                    program_studi_id: this.program_studi_id,
                    hari_dalam_minggu: this.day,
                }
            },
        }
    }
</script>
