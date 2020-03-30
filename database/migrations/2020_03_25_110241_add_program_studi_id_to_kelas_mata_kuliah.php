<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddProgramStudiIdToKelasMataKuliah extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('kelas_mata_kuliah', function (Blueprint $table) {
            $table->unsignedInteger('program_studi_id')->index();
            $table->foreign('program_studi_id')->references('id')->on('program_studi');

//            $table->unique(['kegiatan_id', 'program_studi_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('kelas_mata_kuliah', function (Blueprint $table) {
//            $table->dropUnique(['kegiatan_id', 'tipe']);

            $table->dropForeign(['program_studi_id']);
            $table->dropColumn('program_studi_id');
        });
    }
}
