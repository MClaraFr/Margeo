<?php

namespace App\Repositories;

use App\Models\Product;
use Illuminate\Database\Eloquent\Collection;

class ProductRepository
{
    public function allByUser(int $userId): Collection
    {
        return Product::where('user_id', $userId)
            ->orderBy('name')
            ->get();
    }

    public function findByUser(int $userId, int $id): Product
    {
        return Product::where('user_id', $userId)->findOrFail($id);
    }

    public function nameExists(int $userId, string $name, ?int $ignoreId = null): bool
    {
        return Product::where('user_id', $userId)
            ->whereRaw('LOWER(name) = ?', [mb_strtolower($name)])
            ->when($ignoreId, fn ($q) => $q->where('id', '!=', $ignoreId))
            ->exists();
    }

    public function create(int $userId, array $data): Product
    {
        $product = new Product($data);
        $product->user_id = $userId;
        $product->save();

        return $product;
    }

    public function update(Product $product, array $data): Product
    {
        $product->update($data);

        return $product;
    }

    public function delete(Product $product): void
    {
        $product->delete();
    }
}
