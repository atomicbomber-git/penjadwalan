<?php

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Artisan;

class DatabaseSeeder extends Seeder
{
    const SEED_SNAPSHOT_NAME = "seed";

    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        $this->call(AdminUserSeeder::class);
        $this->call(ExcelDataSeeder::class);

        Artisan::call("snapshot:create " . self::SEED_SNAPSHOT_NAME);
    }
}
