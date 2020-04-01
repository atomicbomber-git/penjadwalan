<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class AddConstraintToKelasMataKuliah extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::statement("
            CREATE EXTENSION IF NOT EXISTS btree_gist
        ");

        DB::statement("
            ALTER TABLE kelas_mata_kuliah
                ADD CONSTRAINT k_id_mk_id
                EXCLUDE USING gist (
                    kegiatan_id WITH =,
                    mata_kuliah_id WITH <>
                ),

                ADD CONSTRAINT k_id_ts_id
                EXCLUDE USING gist (
                    kegiatan_id WITH =,
                    tipe_semester_id WITH <>
                ),

                ADD CONSTRAINT k_id_ta_id
                EXCLUDE USING gist (
                    kegiatan_id WITH =,
                    tahun_ajaran_id WITH <>
                )
        ");

    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
    }
}
