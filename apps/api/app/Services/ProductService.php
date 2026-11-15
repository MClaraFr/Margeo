<?php

namespace App\Services;

use App\Models\Product;
use App\Repositories\ProductRepository;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Validation\ValidationException;

class ProductService
{
    public function __construct(private ProductRepository $products) {}

    public function list(int $userId): Collection
    {
        return $this->products->allByUser($userId);
    }

    public function find(int $userId, int $id): Product
    {
        return $this->products->findByUser($userId, $id);
    }

    public function create(int $userId, array $data): Product
    {
        $this->ensureNameIsUnique($userId, $data['name']);

        return $this->products->create($userId, $data);
    }

    public function update(int $userId, int $id, array $data): Product
    {
        $product = $this->products->findByUser($userId, $id);

        $this->ensureNameIsUnique($userId, $data['name'], $id);

        return $this->products->update($product, $data);
    }

    public function delete(int $userId, int $id): void
    {
        $this->products->delete(
            $this->products->findByUser($userId, $id)
        );
    }

    private function ensureNameIsUnique(
        int $userId,
        string $name,
        ?int $ignoreId = null
    ): void {
        if ($this->products->nameExists($userId, $name, $ignoreId)) {
            throw ValidationException::withMessages([
                'name' => 'Já existe um produto cadastrado com esse nome.',
            ]);
        }
    }
}
