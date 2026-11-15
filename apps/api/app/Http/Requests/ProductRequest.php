<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:150'],
            'unit' => ['required', 'string', 'max:10'],
            'price_per_unit' => ['required', 'numeric', 'min:0', 'max:9999999999.99'],
        ];
    }
}
