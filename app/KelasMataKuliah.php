<?php

namespace App;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class KelasMataKuliah extends Model
{
    protected $table = "kelas_mata_kuliah";
    protected $guarded = [];

    public function mata_kuliah(): BelongsTo
    {
        return $this->belongsTo(MataKuliah::class);
    }
}
