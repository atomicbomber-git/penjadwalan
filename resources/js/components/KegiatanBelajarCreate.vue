<template>
  <div class="card my-3">
    <div class="card-body">
      <form @submit.prevent="onFormSubmit">
        <div class="form-group">
          <label for="mata_kuliah_id">
            Mata Kuliah:
          </label>

          <div id="mata_kuliah_id_container">
            <multiselect
                id="mata_kuliah_id"
                v-model="mata_kuliah"
                :custom-label="({ nama, kode }) => `${nama} (${kode})`"
                :options="mata_kuliahs"
                deselectLabel=""
                placeholder="Mata Kuliah"
                selectLabel=""
                selectedLabel=""
                style=""
                track-by="id"
            >
            </multiselect>
          </div>


          <label class="invalid-feedback">
            {{ get(this.error_data, 'mata_kuliah_id[0]', '') }}
          </label>
        </div>

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
              :key="index"
          >
            <td> {{ index + 1 }}</td>
            <td>
              <label :for="`tipe_${index}`">
                <input
                    :id="`tipe_${index}`"
                    v-model="tipe.name"
                    :class="{'error': get(error_data, ['errors', `tipes.${index}.nama`, 0], false)}"
                    class="form-control form-control-sm"
                    placeholder="Tipe"
                />
              </label>

              <label class="error">
                {{ get(error_data, ['errors', `tipes.${index}.tipe`, 0], '') }}
              </label>
            </td>
            <td class="text-center">
              <button class="btn btn-danger btn-sm"
                      type="button"
                      @click="removeTipe(tipe)"
              >
                <i class="fas fa-trash "></i>
              </button>
            </td>
          </tr>
          </tbody>
        </table>

        <div class="d-flex justify-content-end">
          <button
              class="btn btn-primary btn-sm cypress-add-tipe-kelas"
              type="button"
              @click="addTipe"
          >
            Tambah Tipe Kelas
          </button>
        </div>

        <div class="form-group">
          <label for="hari_dalam_minggu">
            Hari dalam Minggu:
          </label>

          <select
              id="hari_dalam_minggu"
              v-model.number="day"
              class="form-control"
              name="hari_dalam_minggu"
          >
            <option
                v-for="(day, index) in m_days"
                :key="index"
                :value="day.id"
            >
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
              :class="{ 'is-invalid': get(this.error_data, 'tanggal_mulai[0]', false) }"
              class="form-control"
              placeholder="Tanggal Mulai"
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
              :class="{ 'is-invalid': get(this.error_data, 'tanggal_selesai[0]', false) }"
              class="form-control"
              placeholder="Tanggal Selesai"
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
              :class="{ 'is-invalid': get(this.error_data, 'waktu_mulai[0]', false) }"
              class="form-control"
              placeholder="Waktu Mulai"
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
              :class="{ 'is-invalid': get(this.error_data, 'waktu_selesai[0]', false) }"
              class="form-control"
              placeholder="Waktu Selesai"
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

          <div class="cypress-ruangan-id-container">
            <multiselect
                id="ruangan_id"
                v-model="ruangan"
                :custom-label="ruanganLabel"
                :options="ruangans"
                deselectLabel=""
                placeholder="Ruangan"
                selectLabel=""
                selectedLabel=""
                style=""
                track-by="id"
            >
            </multiselect>
          </div>
        </div>

        <div class="form-group d-flex justify-content-end">
          <button class="btn btn-primary cypress-kegiatan-belajar-create-submit">
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
    "mata_kuliahs": Array,
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
      kelas_mata_kuliah: null,
      mata_kuliah: null,
      tipes: [],
      m_days: Object.keys(this.days).map(index => {
        return {
          id: index,
          name: this.days[index],
        }
      }),

      tanggal_mulai: null,
      tanggal_selesai: null,
      waktu_mulai: null,
      waktu_selesai: null,
      ruangan: null,
      day: 1,
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
        hari_dalam_minggu: this.day,
      }
    },
  }
}
</script>
