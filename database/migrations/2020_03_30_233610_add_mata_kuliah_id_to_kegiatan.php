<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddMataKuliahIdToKegiatan extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('kegiatan', function (Blueprint $table) {
            $table->unsignedInteger('mata_kuliah_id')->nullable()->index();
            $table->foreign('mata_kuliah_id')->references('id')->on('mata_kuliah');
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
            //
        });
    }
}
