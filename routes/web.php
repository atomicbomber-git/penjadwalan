<?php

use App\ExcelImports\KegiatanImport;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Maatwebsite\Excel\Facades\Excel;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get("/experiment", function () {
    $filenames = array_filter(Storage::disk("seed")->allFiles(), function ($filename) {
        return !Str::startsWith($filename, ".~lock.");
    });

    if (count($filenames) === 0) {
        return "No file found.";
    }

    // Import seluruh nama ruangan
    Excel::import(
        new KegiatanImport(),
        $filenames[array_key_first($filenames)],
        "seed"
    );

    return "Attempting to load some data here.";
});


Route::get('/', function () {
    return view('welcome');
});

Auth::routes();

Route::get('/home', 'HomeController@index')->name('home');
