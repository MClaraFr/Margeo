<?php

namespace App\Repositories;

use App\Models\Plot;
use Illuminate\Database\Eloquent\Collection;

class PlotRepository
{
    public function allByUser(int $userId): Collection
    {
        return Plot::where('user_id', $userId)->orderBy('name')->get();
    }

    public function findByUser(int $userId, int $id): Plot
    {
        return Plot::where('user_id', $userId)->findOrFail($id);
    }

    public function nameExists(int $userId, string $name, ?int $ignoreId = null): bool
    {
        return Plot::where('user_id', $userId)
            ->whereRaw('LOWER(name) = ?', [mb_strtolower($name)])
            ->when($ignoreId, fn ($q) => $q->where('id', '!=', $ignoreId))
            ->exists();
    }

    public function create(int $userId, array $data): Plot
    {
        $plot = new Plot($data);
        $plot->user_id = $userId;
        $plot->save();

        return $plot;
    }

    public function update(Plot $plot, array $data): Plot
    {
        $plot->update($data);

        return $plot;
    }

    public function delete(Plot $plot): void
    {
        $plot->delete();
    }
}
