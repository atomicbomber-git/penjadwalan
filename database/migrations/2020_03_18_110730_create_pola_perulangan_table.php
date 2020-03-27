<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePolaPerulanganTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('pola_perulangan', function (Blueprint $table) {
            $table->increments("id");
            $table->integer('interval_perulangan');
            $table->integer('hari_dalam_minggu')->nullable();
            $table->integer('minggu_dalam_bulan')->nullable();
            $table->integer('hari_dalam_bulan')->nullable();
            $table->integer('bulan_dalam_tahun')->nullable();
            $table->timestamps();

            $table->unsignedInteger('kegiatan_id')->index();
            $table->foreign('kegiatan_id')->references('id')->on('kegiatan')->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('pola_perulangan');
    }
}
