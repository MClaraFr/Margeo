<?php

namespace Tests\Feature;

use App\Models\Plot;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PlotTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_only_list_own_plots(): void
    {
        $user = User::factory()->create([
            'whatsapp' => '41999990001',
        ]);

        $otherUser = User::factory()->create([
            'whatsapp' => '41999990002',
        ]);

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

        Plot::factory()->create([
            'user_id' => $otherUser->id,
            'name' => 'Outro Talhão',
            'area_ha' => 30,
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/plots');

        $response->assertOk()
            ->assertJsonCount(2)
            ->assertJsonFragment(['name' => 'Sede'])
            ->assertJsonFragment(['name' => 'Ilha'])
            ->assertJsonMissing(['name' => 'Outro Talhão']);
    }

    public function test_user_can_create_a_plot(): void
    {
        $user = User::factory()->create([
            'whatsapp' => '41999990003',
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/plots', [
                'name' => 'Talhão Novo',
                'area_ha' => 15,
            ]);

        $response->assertCreated()
            ->assertJsonFragment([
                'name' => 'Talhão Novo',
                'area_ha' => 15,
            ]);

        $this->assertDatabaseHas('plots', [
            'user_id' => $user->id,
            'name' => 'Talhão Novo',
            'area_ha' => 15,
        ]);
    }
}
