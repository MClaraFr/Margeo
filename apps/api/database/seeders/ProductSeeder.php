<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::first();

        Product::factory()->create([
            'user_id' => $user->id,
            'name' => 'Miravis Pro',
            'unit' => 'L',
            'price_per_unit' => 250.00,
        ]);

        Product::factory()->create([
            'user_id' => $user->id,
            'name' => 'Acquamax',
            'unit' => 'L',
            'price_per_unit' => 80.00,
        ]);
    }
}
