<?php

namespace Database\Seeders;

use App\Models\Plot;
use App\Models\User;
use Illuminate\Database\Seeder;

class PlotSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::first();

        Plot::factory()->create([
            'user_id' => $user->id,
            'name' => 'Sede',
            'area_ha' => 24,
        ]);

        Plot::factory()->create([
            'user_id' => $user->id,
            'name' => 'Ilha',
            'area_ha' => 12,
        ]);
    }
}
