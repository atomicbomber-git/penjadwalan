<template>
    <div class="card my-3">
        <div class="card-body">
            <form @submit.prevent="onFormSubmit">
                <div class="form-group">
                    <label for="mata_kuliah_id">
                        Mata Kuliah:
                    </label>

                    <multiselect
                        id="mata_kuliah_id"
                        style=""
                        placeholder="Mata Kuliah"
                        selectLabel=""
                        selectedLabel=""
                        deselectLabel=""
                        track-by="id"
                        :custom-label="({ nama, kode }) => `${nama} (${kode})`"
                        :options="mata_kuliahs"
                        v-model="mata_kuliah"
                    >
                    </multiselect>

                    <label class="invalid-feedback">
                        {{ get(this.error_data, 'mata_kuliah_id[0]', '') }}
                    </label>
                </div>

                <table class="table table-sm table-striped table-bordered">
                    <thead>
                    <tr>
                        <td> # </td>
                        <td> Tipe Kelas </td>
                        <td class="text-center"> Kendali </td>
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
                            <button @click="removeTipe(tipe)" type="button" class="btn btn-danger btn-sm">
                                <i class="fas fa-trash "></i>
                            </button>
                        </td>
                    </tr>
                    </tbody>
                </table>

                <div class="d-flex justify-content-end">
                    <button type="button" @click="addTipe"
                            class="btn btn-primary btn-sm">
                        Tambah Tipe Kelas
                    </button>
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
            "ruangans": Array,
            "kelas_mata_kuliahs": Array,
            "mata_kuliahs": Array,
            "submit_url": String,
            "redirect_url": String,
            "tipe_semester_id": Number,
            "tahun_ajaran_id": Number,
            "program_studi_id": Number,
        },

        components: {
            Multiselect: require("vue-multiselect").Multiselect,
            datetime: require("vue-datetime").Datetime,
        },

        data() {
            return {
                kelas_mata_kuliah: null,
                mata_kuliah: null,
                tipes: [],

                m_kelas_mata_kuliahs: this.kelas_mata_kuliahs.map(kmk => ({
                    ...kmk,
                    picked: false
                })),

                tanggal_mulai: null,
                tanggal_selesai: null,
                waktu_mulai: null,
                waktu_selesai: null,
                ruangan: null,
            }
        },

        watch: {
            kelas_mata_kuliah(new_kelas_mata_kuliah) {
                if (new_kelas_mata_kuliah === null) {
                    return
                }

                new_kelas_mata_kuliah.picked = true
                this.kelas_mata_kuliah = null
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
                axios.post(this.submit_url, this.form_data)
                    .then(response => {
                        window.location.replace(this.redirect_url)
                    })
                    .catch(error => {
                        this.error_data = error.response.data
                    })
            },

            kelasMataKuliahSelectLabel(kelas_mata_kuliah) {
                return `${kelas_mata_kuliah.tipe} (${kelas_mata_kuliah.nama} / ${kelas_mata_kuliah.kode})`;
            },

            ruanganLabel(ruangan) {
                return ruangan.nama
            }
        },

        computed: {
            form_data() {
                return {
                    tipes: this.tipes,
                    mata_kuliah_id: this.get(this.mata_kuliah, 'id', null),
                    tanggal_mulai: this.tanggal_mulai,
                    tanggal_selesai: this.tanggal_selesai,
                    waktu_mulai: moment(moment().format("YYYY-MM-DD") + " " + this.waktu_mulai).format("HH:mm:ss"),
                    waktu_selesai: moment(moment().format("YYYY-MM-DD") + " " + this.waktu_selesai).format("HH:mm:ss"),
                    ruangan_id: this.get(this.ruangan, "id"),
                    tipe_semester_id: this.tipe_semester_id,
                    tahun_ajaran_id: this.tahun_ajaran_id,
                    program_studi_id: this.program_studi_id,
                }
            },

            kelas_mata_kuliah_options() {
                if (this.picked_kelas_mata_kuliahs.length === 0) {
                    return this.m_kelas_mata_kuliahs.filter(kmk => !kmk.picked)
                }

                return this.m_kelas_mata_kuliahs
                    .filter(kmk => !kmk.picked)
                    .filter(kmk => kmk.mata_kuliah_id === this.picked_kelas_mata_kuliahs[0].mata_kuliah_id)
            },

            picked_kelas_mata_kuliahs() {
                return this.m_kelas_mata_kuliahs.filter(kmk => kmk.picked)
            },
        }
    }
</script>
