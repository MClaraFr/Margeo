<?php

namespace App\Http\Controllers;

use App\Http\Requests\PlotRequest;
use App\Services\PlotService;
use Illuminate\Http\Request;

class PlotController extends Controller
{
    public function __construct(private PlotService $service) {}

    public function index(Request $request)
    {
        return $this->service->list($request->user()->id);
    }

    public function store(PlotRequest $request)
    {
        $plot = $this->service->create($request->user()->id, $request->validated());

        return response()->json($plot, 201);
    }

    public function show(Request $request, int $plot)
    {
        return $this->service->find($request->user()->id, $plot);
    }

    public function update(PlotRequest $request, int $plot)
    {
        return $this->service->update($request->user()->id, $plot, $request->validated());
    }

    public function destroy(Request $request, int $plot)
    {
        $this->service->delete($request->user()->id, $plot);

        return response()->noContent();
    }
}
