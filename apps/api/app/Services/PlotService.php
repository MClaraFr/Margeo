<?php

namespace App\Services;

use App\Models\Plot;
use App\Repositories\PlotRepository;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Validation\ValidationException;

class PlotService
{
    public function __construct(private PlotRepository $plots) {}

    public function list(int $userId): Collection
    {
        return $this->plots->allByUser($userId);
    }

    public function find(int $userId, int $id): Plot
    {
        return $this->plots->findByUser($userId, $id);
    }

    public function create(int $userId, array $data): Plot
    {
        $this->ensureNameIsUnique($userId, $data['name']);

        return $this->plots->create($userId, $data);
    }

    public function update(int $userId, int $id, array $data): Plot
    {
        $plot = $this->plots->findByUser($userId, $id);
        $this->ensureNameIsUnique($userId, $data['name'], $id);

        return $this->plots->update($plot, $data);
    }

    public function delete(int $userId, int $id): void
    {
        $this->plots->delete($this->plots->findByUser($userId, $id));
    }

    private function ensureNameIsUnique(int $userId, string $name, ?int $ignoreId = null): void
    {
        if ($this->plots->nameExists($userId, $name, $ignoreId)) {
            throw ValidationException::withMessages([
                'name' => 'Já existe um talhão com esse nome.',
            ]);
        }
    }
}
