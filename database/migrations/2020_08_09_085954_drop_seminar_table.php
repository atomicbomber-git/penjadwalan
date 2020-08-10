<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class DropSeminarTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::dropIfExists("seminar");
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('seminar', function (Blueprint $table) {
            $table->increments("id");
            $table->unsignedInteger('kegiatan_id')->index();
            $table->text("nama");
            $table->timestamps();
            $table->foreign('kegiatan_id')->references('id')->on('kegiatan');
        });
    }
}
