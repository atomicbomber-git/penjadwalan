<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateKelasMataKuliahTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('kelas_mata_kuliah', function (Blueprint $table) {
            $table->increments('id');
            $table->unsignedInteger('kegiatan_id')->nullable()->index();
            $table->unsignedInteger('mata_kuliah_id')->index();
            $table->string('tipe')->comment("Kelas A, kelas B");
            $table->timestamps();

            $table->foreign('mata_kuliah_id')->references('id')->on('mata_kuliah');
            $table->foreign('kegiatan_id')->references('id')->on('kegiatan')->onDelete("SET NULL");
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('kelas_mata_kuliahs');
    }
}
