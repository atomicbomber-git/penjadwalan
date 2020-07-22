<template>
    <div class="card my-3">
        <div class="card-body">
            <form @submit.prevent="onFormSubmit">
                <div class="form-group">
                    <label for="kelas_mata_kuliah_id">
                        Kelas Mata Kuliah:
                    </label>

                    <multiselect
                        id="kelas_mata_kuliah_id"
                        style=""
                        placeholder="Kelas Mata Kuliah"
                        selectLabel=""
                        selectedLabel=""
                        deselectLabel=""
                        track-by="id"
                        :custom-label="kelasMataKuliahSelectLabel"
                        :options="kelas_mata_kuliah_options"
                        v-model="kelas_mata_kuliah"
                    >
                    </multiselect>

                    <label class="error">
                        {{ get(this.error_data, 'kelas_mata_kuliah_id[0]', '') }}
                    </label>
                </div>

                <div class="form-group">
                    <table class="table table-sm table-striped">
                        <thead>
                        <tr>
                            <th> #</th>
                            <th> Mata Kuliah</th>
                            <th> Kode</th>
                            <th> Kelas</th>
                            <th class="text-center">
                                <i class="fas fa-cog"></i>
                            </th>
                        </tr>
                        </thead>

                        <tbody>
                        <tr v-for="(kelas_mata_kuliah, index) in picked_kelas_mata_kuliahs">
                            <td> {{ index + 1 }}</td>
                            <td> {{ kelas_mata_kuliah.nama }}</td>
                            <td> {{ kelas_mata_kuliah.kode }}</td>
                            <td> {{ kelas_mata_kuliah.tipe }}</td>
                            <td class="text-center">
                                <button
                                    @click="kelas_mata_kuliah.picked = false"
                                    type="button"
                                    class="btn btn-sm btn-danger">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        </tbody>

                    </table>

                </div>

                <div class="form-group d-flex justify-content-center">
                    <button class="btn btn-primary">
                        Submit
                    </button>
                </div>
            </form>

            <div class="form-group">
            </div>
        </div>
    </div>
</template>


<script>
    export default {
        props: {
            "ruangans": Array,
            "kelas_mata_kuliahs": Array,
        },

        components: {
            Multiselect: require("vue-multiselect").Multiselect,
            datetime: require("vue-datetime").Datetime,
        },

        data() {
            return {
                kelas_mata_kuliah: null,

                m_kelas_mata_kuliahs: this.kelas_mata_kuliahs.map(kmk => ({
                    ...kmk,
                    picked: false
                }))
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
            onFormSubmit() {
            },

            kelasMataKuliahSelectLabel(kelas_mata_kuliah) {
                return `${kelas_mata_kuliah.tipe} (${kelas_mata_kuliah.nama} / ${kelas_mata_kuliah.kode})`;
            }
        },

        computed: {
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
