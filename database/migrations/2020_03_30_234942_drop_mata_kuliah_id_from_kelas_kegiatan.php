<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class DropMataKuliahIdFromKelasKegiatan extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('kelas_kegiatan', function (Blueprint $table) {
            $table->dropForeign('kelas_mata_kuliah_mata_kuliah_id_foreign');
            $table->dropColumn('mata_kuliah_id');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('kelas_kegiatan', function (Blueprint $table) {
            $table->unsignedInteger('mata_kuliah_id')->index();
            $table->foreign('mata_kuliah_id')->references('id')->on('mata_kuliah');
        });
    }
}
