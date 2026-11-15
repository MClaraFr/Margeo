<?php

namespace App\Http\Controllers;

use App\Http\Requests\ProductRequest;
use App\Services\ProductService;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function __construct(private ProductService $service) {}

    public function index(Request $request)
    {
        return $this->service->list($request->user()->id);
    }

    public function store(ProductRequest $request)
    {
        $product = $this->service->create(
            $request->user()->id,
            $request->validated()
        );

        return response()->json($product, 201);
    }

    public function show(Request $request, int $product)
    {
        return $this->service->find($request->user()->id, $product);
    }

    public function update(ProductRequest $request, int $product)
    {
        return $this->service->update(
            $request->user()->id,
            $product,
            $request->validated()
        );
    }

    public function destroy(Request $request, int $product)
    {
        $this->service->delete($request->user()->id, $product);

        return response()->noContent();
    }
}
