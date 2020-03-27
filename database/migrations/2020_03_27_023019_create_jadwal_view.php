<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class CreateJadwalView extends Migration
{
    private $view_name = "jadwal";

    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::statement("
           CREATE OR REPLACE VIEW $this->view_name AS SELECT prefiltered_events.kegiatan_id, rentang_waktu
                FROM (
                         SELECT (row_number() OVER (PARTITION BY
                             id_kegiatan ORDER BY date) - 1) % interval_perulangan = 0 AS included
                              , *
                         FROM (SELECT extract(isodow FROM date)                         AS day_of_week
                                    , extract(day FROM date)                            AS day_of_month
                                    , extract(month FROM date)                          AS month_of_year
                                    , week_of_month(date::date, 1)                      AS week_of_month
                                    , CASE
                                          WHEN berulang THEN
                                            tsrange(date + waktu_mulai, date + waktu_selesai)
                                          ELSE
                                            tsrange(tanggal_mulai + waktu_mulai, tanggal_selesai + waktu_selesai)
                                          END
                                            AS rentang_waktu
                                    , *
                               FROM (
                                        SELECT generate_series(
                                                tanggal_mulai::timestamp,
                                                CASE
                                                    WHEN berulang = TRUE
                                                        THEN tanggal_selesai::timestamp
                                                    ELSE tanggal_mulai::timestamp
                                                    END,
                                                '1 day') AS date
                                             , *
                                        from (
                                                 SELECT kegiatan.id AS id_kegiatan
                                                      , *
                                                 FROM kegiatan
                                                          LEFT JOIN pola_perulangan pp on kegiatan.id = pp.kegiatan_id
                                             ) AS kegiatan_list
                                    ) AS schedule
                              ) AS scheduled_events
                         WHERE TRUE
                           AND CASE WHEN hari_dalam_minggu IS NULL THEN TRUE ELSE hari_dalam_minggu = day_of_week END
                           AND CASE WHEN minggu_dalam_bulan IS NULL THEN TRUE ELSE minggu_dalam_bulan = week_of_month END
                           AND CASE WHEN hari_dalam_bulan IS NULL THEN TRUE ELSE hari_dalam_bulan = day_of_month END
                           AND CASE WHEN bulan_dalam_tahun IS NULL THEN TRUE ELSE bulan_dalam_tahun = month_of_year END
                     ) AS prefiltered_events
                         WHERE prefiltered_events.included = TRUE
        ");

    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement("DROP view $this->view_name");
    }
}
