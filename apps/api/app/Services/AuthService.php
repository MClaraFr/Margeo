<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    public function login(string $whatsapp, string $password): ?array
    {
        $user = User::where('whatsapp', $whatsapp)->first();

        if (! $user || ! Hash::check($password, $user->password)) {
            return null;
        }

        $token = $user->createToken('app');

        return [
            'token' => $token->plainTextToken,
            'user' => $user,
        ];
    }
}
