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
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('transaction_id')->unique(); // Razorpay payment ID
            $table->string('order_id'); // Razorpay order ID
            $table->string('signature')->nullable(); // Razorpay signature
            $table->enum('type', ['access_pass', 'listing_fee', 'refund']);
            $table->enum('status', ['created', 'paid', 'failed', 'refunded']);
            $table->decimal('amount', 10, 2);
            $table->string('currency')->default('INR');
            $table->text('description')->nullable();
            $table->json('metadata')->nullable(); // Additional payment metadata
            $table->json('razorpay_response')->nullable(); // Full Razorpay response
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('transaction_id');
            $table->index('order_id');
            $table->index('type');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
