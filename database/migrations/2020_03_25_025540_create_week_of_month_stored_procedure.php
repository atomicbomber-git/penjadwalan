<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

class CreateWeekOfMonthStoredProcedure extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        DB::statement("
            CREATE OR REPLACE FUNCTION week_of_month(
              p_date        DATE,
              p_direction   INT -- DEFAULT 1 -- for 8.4 and above
            ) RETURNS INT AS
            $$
              SELECT CASE WHEN $2 >= 0 THEN
                CEIL(EXTRACT(DAY FROM $1) / 7)::INT
              ELSE
                0 - CEIL(
                  (EXTRACT(DAY FROM last_day($1)) - EXTRACT(DAY FROM $1) + 1) / 7
                )::INT
              END
            $$ LANGUAGE 'sql' IMMUTABLE;
        ");
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement("DROP FUNCTION week_of_month");
    }
}
