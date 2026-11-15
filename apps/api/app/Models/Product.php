<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

#[Fillable(['user_id', 'name', 'unit', 'price_per_unit'])]
class Product extends Model
{
    use HasFactory;

    protected function casts(): array
    {
        return [
            'price_per_unit' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function applications(): BelongsToMany
    {
        return $this->belongsToMany(Application::class)
            ->withPivot('quantity_per_ha', 'unit_price_at_application')
            ->withTimestamps();
    }
}
