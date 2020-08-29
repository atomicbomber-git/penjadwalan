<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;

class DatabaseResetCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'db:reset-seed';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Reset database to the latest seed snapshot.';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $this->info("Dropping custom functions...");

        Artisan::call("db:wipe --drop-types --drop-views");
        DB::unprepared("DROP FUNCTION IF exists last_day");
        DB::unprepared("DROP FUNCTION IF exists tsrange_gaps");
        DB::unprepared("DROP FUNCTION IF exists week_of_month");

        $this->info("Loading snapshot...");

        Artisan::call("snapshot:load seed");

        $this->info("DONE!");
        return 0;
    }
}
