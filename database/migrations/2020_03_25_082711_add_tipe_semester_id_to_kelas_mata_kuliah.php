<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddTipeSemesterIdToKelasMataKuliah extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('kelas_mata_kuliah', function (Blueprint $table) {
            $table->unsignedInteger('tipe_semester_id')->after('tipe')->index();
            $table->foreign('tipe_semester_id')->references('id')->on('tipe_semester');
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
            $table->dropForeign(['tipe_semester_id']);
            $table->dropColumn('tipe_semester_id');
        });
    }
}
