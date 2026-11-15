<?php

namespace App\Http\Controllers;

use App\Http\Requests\AuthLoginRequest;
use App\Services\AuthService;

class AuthController extends Controller
{
    public function __construct(private AuthService $authService) {}

    public function login(AuthLoginRequest $request)
    {
        $data = $request->validated();

        $result = $this->authService->login($data['whatsapp'], $data['password']);

        if ($result === null) {
            return response()->json(['message' => 'Credenciais inválidas'], 401);
        }

        return $result;
    }
}
