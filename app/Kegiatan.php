<?php

namespace App;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Kegiatan extends Model
{
    protected $table = "kegiatan";
    protected $guarded = [];

    public function pola_perulangan(): HasOne
    {
        return $this->hasOne(PolaPerulangan::class);
    }
}
