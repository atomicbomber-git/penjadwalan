<?php


namespace App\Casts;


use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Spatie\Period\Boundaries;
use Spatie\Period\Period;
use Spatie\Period\Precision;

class JsonCast implements CastsAttributes
{
    /**
     * @inheritDoc
     * @throws \Exception
     */
    public function get($model, string $key,  $value, array $attributes)
    {
        return json_decode($value);
    }

    /**
     * @inheritDoc
     * @throws \Exception
     */
    public function set($model, string $key, $value, array $attributes)
    {
    }
}
