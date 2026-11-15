<?php

namespace App\Http\Controllers;

use App\Http\Requests\ApplicationRequest;
use App\Services\ApplicationService;
use Illuminate\Http\Request;

class ApplicationController extends Controller
{
    public function __construct(private ApplicationService $service) {}

    public function index(Request $request)
    {
        return $this->service->list($request->user()->id);
    }

    public function store(ApplicationRequest $request)
    {
        $application = $this->service->create(
            $request->user()->id,
            $request->validated()
        );

        return response()->json($application, 201);
    }

    public function show(Request $request, int $application)
    {
        return $this->service->find($request->user()->id, $application);
    }

    public function update(ApplicationRequest $request, int $application)
    {
        return $this->service->update(
            $request->user()->id,
            $application,
            $request->validated()
        );
    }

    public function destroy(Request $request, int $application)
    {
        $this->service->delete($request->user()->id, $application);

        return response()->noContent();
    }
}
