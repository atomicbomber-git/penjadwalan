<?php


namespace App\Support;


use Illuminate\Database\Schema\Grammars\PostgresGrammar;
use Illuminate\Support\Fluent;

class ExtendedPostgresGrammar extends PostgresGrammar
{
    protected function typeInterval(Fluent $column) {
        return "interval";
    }
}
