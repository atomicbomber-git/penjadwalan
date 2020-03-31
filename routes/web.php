<?php

use App\Http\Controllers\PenggunaanRuanganController;
use App\Http\Controllers\RuanganController;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

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

Route::get('/', function () {
    return redirect()->route("penggunaan-ruangan");
});

Auth::routes([
    "register" => false,
    "reset" => false,
    "confirm" => false,
    "verify" => false,
]);

Route::resource('ruangan', class_basename(RuanganController::class))->only(["index"]);
Route::get('/penggunaan-ruangan', class_basename(PenggunaanRuanganController::class))->name("penggunaan-ruangan");
