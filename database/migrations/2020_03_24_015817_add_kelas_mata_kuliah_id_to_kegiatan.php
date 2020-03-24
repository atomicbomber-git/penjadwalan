<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddKelasMataKuliahIdToKegiatan extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('kegiatan', function (Blueprint $table) {
            $table->unsignedInteger('kelas_mata_kuliah_id')->nullable()->index();
            $table->foreign('kelas_mata_kuliah_id')->references('id')->on('kelas_mata_kuliah');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('kegiatan', function (Blueprint $table) {
            $table->unsignedInteger('kelas_mata_kuliah_id')->index();
            $table->foreign('kelas_mata_kuliah_id')->references('id')->on('kelas_mata_kuliahs');
        });
    }
}
