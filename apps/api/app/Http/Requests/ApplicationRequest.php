<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ApplicationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'plot_id' => ['required', 'integer', 'exists:plots,id'],
            'application_date' => ['required', 'date'],
            'area_ha' => ['required', 'numeric', 'gt:0'],
            'products' => ['required', 'array', 'min:1'],
            'products.*.product_id' => ['required', 'integer', 'distinct', 'exists:products,id'],
            'products.*.quantity_per_ha' => ['required', 'numeric', 'gt:0'],
        ];
    }
}
