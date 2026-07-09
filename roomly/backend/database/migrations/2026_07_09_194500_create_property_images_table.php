<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('property_images', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained()->cascadeOnDelete();
            $table->string('url');
            $table->string('file_name');
            $table->string('mime_type');
            $table->integer('file_size'); // in bytes
            $table->integer('sort_order')->default(0);
            $table->boolean('is_primary')->default(false);
            $table->string('storage_disk')->default('s3'); // s3, r2, local
            $table->timestamps();

            $table->index('property_id');
            $table->index('is_primary');
            $table->index('sort_order');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('property_images');
    }
};
