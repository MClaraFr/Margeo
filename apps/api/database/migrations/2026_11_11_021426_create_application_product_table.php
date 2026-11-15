<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('application_product', function (Blueprint $table) {
            $table->id();
            $table->foreignId('application_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->constrained()->restrictOnDelete();
            $table->decimal('quantity_per_ha', 12, 4);
            $table->decimal('unit_price_at_application', 12, 2);
            $table->timestamps();

            $table->unique(['application_id', 'product_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('application_product');
    }
};
