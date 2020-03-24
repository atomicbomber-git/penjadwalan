<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateKegiatanTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('kegiatan', function (Blueprint $table) {
            $table->increments("id");
            $table->date("tanggal_mulai");
            $table->date("tanggal_selesai");
            $table->time("waktu_mulai")->nullable();
            $table->time("waktu_selesai")->nullable();
            $table->boolean("berulang");

            $table->unsignedInteger('kegiatan_sumber_id')->nullable()->index();
            $table->foreign('kegiatan_sumber_id')->references('id')->on('kegiatan');

            $table->unsignedInteger('ruangan_id')->index();
            $table->foreign('ruangan_id')->references('id')->on('ruangan');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('kegiatan');
    }
}
