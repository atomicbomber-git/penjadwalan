<?php

namespace App\Providers;

use App\Support\ExtendedPostgresGrammar;
use Barryvdh\Debugbar\LaravelDebugbar;
use DebugBar\DebugBar;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Routing\Router;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        DB::connection()->setSchemaGrammar(
            new ExtendedPostgresGrammar()
        );
    }
}
