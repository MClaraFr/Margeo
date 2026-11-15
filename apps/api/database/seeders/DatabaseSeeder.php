<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::factory()->create([
            'name' => 'Maria Clara',
            'whatsapp' => '42927272727',
            'email' => 'teste@margeo.test',
            'password' => 'Mgeo50',
        ]);

        $this->call(PlotSeeder::class);
        $this->call(ProductSeeder::class);
    }
}
