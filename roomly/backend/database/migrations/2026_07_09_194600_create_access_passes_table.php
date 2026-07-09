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
        Schema::create('access_passes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('transaction_id')->unique();
            $table->enum('status', ['pending', 'active', 'expired', 'refunded'])->default('pending');
            $table->decimal('amount', 10, 2)->default(5.00);
            $table->timestamp('purchased_at')->nullable();
            $table->timestamp('activated_at')->nullable();
            $table->timestamp('expires_at')->nullable(); // 24 hours from activation
            $table->integer('properties_viewed')->default(0);
            $table->text('payment_response')->nullable(); // JSON response from Razorpay
            $table->timestamps();

            $table->index('user_id');
            $table->index('status');
            $table->index('expires_at');
            $table->index(['user_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('access_passes');
    }
};
