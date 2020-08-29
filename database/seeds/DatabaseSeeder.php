<?php

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Spatie\DbSnapshots\SnapshotRepository;

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
        /** @var SnapshotRepository $snapshotRepository */
        $snapshotRepository = app(SnapshotRepository::class);

        if ($snapshotRepository->findByName(self::SEED_SNAPSHOT_NAME)) {
            Artisan::call("db:wipe --drop-types --drop-views");
            DB::unprepared("DROP FUNCTION IF exists last_day");
            DB::unprepared("DROP FUNCTION IF exists tsrange_gaps");
            DB::unprepared("DROP FUNCTION IF exists week_of_month");
            Artisan::call("snapshot:load " . self::SEED_SNAPSHOT_NAME);
            return;
        }

        $this->call(AdminUserSeeder::class);
        $this->call(ExcelDataSeeder::class);

        Artisan::call("snapshot:create " . self::SEED_SNAPSHOT_NAME);
    }
}
