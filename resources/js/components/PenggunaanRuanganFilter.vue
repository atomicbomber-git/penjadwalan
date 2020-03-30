<template>
    <div class="card">
        <div class="card-header">
            Filter
        </div>

        <div class="card-body">
            <form method="get">
                <div class="form-group">
                    <label for="filter_ruangan_id"> Ruangan </label>

                    <input
                        type="hidden"
                        name="filter_ruangan_id"
                        :value="ruangan.id || null">

                    <multiselect
                        id="filter_ruangan_id"
                        style=""
                        placeholder="Ruangan"
                        selectLabel=""
                        selectedLabel=""
                        deselectLabel=""
                        track-by="id"
                        label="nama"
                        :options="ruangans"
                        v-model="ruangan"
                    >
                    </multiselect>
                </div>

                <div class="form-group">
                    <label for="filter_waktu_mulai"> Filter Waktu Mulai </label>

                    <input
                        type="hidden"
                        name="filter_waktu_mulai"
                        :value="normalizeDatetime(waktu_mulai)">

                    <datetime
                        type="datetime"
                        input-class="form-control"
                        placeholder="Waktu mulai"
                        id="filter_waktu_mulai"
                        v-model="waktu_mulai"
                    ></datetime>
                </div>

                <div class="form-group">
                    <label for="filter_waktu_selesai"> Filter Waktu Selesai </label>

                    <input
                        type="hidden"
                        name="filter_waktu_selesai"
                        :value="normalizeDatetime(waktu_selesai)">

                    <datetime
                        type="datetime"
                        input-class="form-control"
                        placeholder="Waktu selesai"
                        id="filter_waktu_selesai"
                        v-model="waktu_selesai"
                    ></datetime>
                </div>

                <div class="form-group d-flex justify-content-end">
                    <button type="submit" class="btn btn-primary">
                        Periksa Ketersediaan Ruangan
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>

<script>
    import moment from "moment";

    export default {
        props: {
            'filter-waktu-mulai': String,
            'filter-waktu-selesai': String,
            'ruangans': Array,
            'filter-ruangan-id': Number,
        },

        components: {
            Multiselect: require("vue-multiselect").Multiselect,
            datetime: require("vue-datetime").Datetime,
        },

        data() {
            return {
                ruangan: this.ruangans.find(ruangan_source => ruangan_source.id === this.filterRuanganId) || null,
                waktu_mulai: moment(this.filterWaktuMulai).toISOString(),
                waktu_selesai: moment(this.filterWaktuSelesai).toISOString(),
            }
        },
    }
</script>
