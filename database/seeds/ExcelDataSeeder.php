<?php

use App\ExcelImports\KegiatanImport;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Maatwebsite\Excel\Concerns\WithMultipleSheets;
use Maatwebsite\Excel\Facades\Excel;

class ExcelDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $filenames = array_filter(Storage::disk("seed")->allFiles(), function ($filename) {
            return !Str::startsWith($filename, ".~lock.");
        });

        if (count($filenames) === 0) {
            $this->command->info("No file found.");
            return;
        }

        foreach ($filenames as $filename) {
            $this->command->info("Importing data from {$filename}...");

//            DB::beginTransaction();

            Excel::import(
                (new class implements WithMultipleSheets {
                    public function sheets(): array
                    {
                        return [0 => new KegiatanImport()];
                    }
                }),
                $filename,
                "seed"
            );

//            DB::commit();
        }
    }
}
