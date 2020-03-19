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

            $table->string("tipe_perulangan")->comment(
                "Dapat bernilai HARIAN, MINGGUAN, BULANAN, atau TAHUNAN"
            );
            $table->integer("jumlah_unit_pemisah")->comment(
                "
                    Berapa lama rentang waktu perulangan setelah kegiatan dilakukan.
                    Jika tipe perulangan adalah HARIAN dan jumlah unit pemisah adalah 2,
                    maka kegiatan akan berulang 2 hari setelah kegiatan serupa dilakukan.
                "
            );
            $table->integer("hari_dalam_minggu");
            $table->integer("minggu_dalam_bulan");
            $table->integer("hari_dalam_bulan");
            $table->integer("bulan_dalam_tahun");
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
        Schema::dropIfExists('pola_perulangan');
    }
}
