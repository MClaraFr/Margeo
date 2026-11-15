<?php

namespace App\Services;

use App\Models\Application;
use App\Models\Plot;
use App\Models\Product;
use App\Repositories\ApplicationRepository;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ApplicationService
{
    public function __construct(private ApplicationRepository $applications) {}

    public function list(int $userId): Collection
    {
        return $this->applications->allByUser($userId);
    }

    public function find(int $userId, int $id): Application
    {
        return $this->applications->findByUser($userId, $id);
    }

    public function create(int $userId, array $data): Application
    {
        return DB::transaction(function () use ($userId, $data) {
            $products = $this->prepareProducts($userId, $data['products']);
            $this->validatePlot($userId, $data['plot_id'], $data['area_ha']);

            return $this->applications->create($userId, $data, $products);
        });
    }

    public function update(int $userId, int $id, array $data): Application
    {
        return DB::transaction(function () use ($userId, $id, $data) {
            $application = $this->applications->findByUser($userId, $id);
            $products = $this->prepareProducts($userId, $data['products']);
            $this->validatePlot($userId, $data['plot_id'], $data['area_ha']);

            return $this->applications->update($application, $data, $products);
        });
    }

    public function delete(int $userId, int $id): void
    {
        $this->applications->delete(
            $this->applications->findByUser($userId, $id)
        );
    }

    private function validatePlot(int $userId, int $plotId, float $area): void
    {
        $plot = Plot::where('user_id', $userId)->find($plotId);

        if (! $plot) {
            throw ValidationException::withMessages([
                'plot_id' => 'O talhão informado não pertence ao usuário.',
            ]);
        }

        if ($area > $plot->area_ha) {
            throw ValidationException::withMessages([
                'area_ha' => 'A área aplicada não pode ser maior que a área do talhão.',
            ]);
        }
    }

    private function prepareProducts(int $userId, array $items): array
    {
        $prepared = [];

        foreach ($items as $item) {
            $product = Product::where('user_id', $userId)
                ->find($item['product_id']);

            if (! $product) {
                throw ValidationException::withMessages([
                    'products' => 'Um dos produtos informados não pertence ao usuário.',
                ]);
            }

            $prepared[$product->id] = [
                'quantity_per_ha' => $item['quantity_per_ha'],
                'unit_price_at_application' => $product->price_per_unit,
            ];
        }

        return $prepared;
    }
}
