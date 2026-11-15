<?php

namespace App\Repositories;

use App\Models\Application;
use Illuminate\Database\Eloquent\Collection;

class ApplicationRepository
{
    public function allByUser(int $userId): Collection
    {
        return Application::with(['plot', 'products'])
            ->where('user_id', $userId)
            ->orderByDesc('application_date')
            ->get();
    }

    public function findByUser(int $userId, int $id): Application
    {
        return Application::with(['plot', 'products'])
            ->where('user_id', $userId)
            ->findOrFail($id);
    }

    public function create(int $userId, array $data, array $products): Application
    {
        $application = Application::create([
            'user_id' => $userId,
            'plot_id' => $data['plot_id'],
            'application_date' => $data['application_date'],
            'area_ha' => $data['area_ha'],
        ]);

        $application->products()->attach($products);

        return $application->load(['plot', 'products']);
    }

    public function update(Application $application, array $data, array $products): Application
    {
        $application->update([
            'plot_id' => $data['plot_id'],
            'application_date' => $data['application_date'],
            'area_ha' => $data['area_ha'],
        ]);

        $application->products()->sync($products);

        return $application->load(['plot', 'products']);
    }

    public function delete(Application $application): void
    {
        $application->delete();
    }
}
