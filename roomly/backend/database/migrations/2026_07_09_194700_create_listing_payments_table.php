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
        Schema::create('listing_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained()->cascadeOnDelete();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->string('transaction_id')->unique();
            $table->enum('type', ['new_listing', 'relisting'])->default('new_listing');
            $table->enum('status', ['pending', 'paid', 'failed', 'refunded'])->default('pending');
            $table->decimal('amount', 10, 2)->default(9.00);
            $table->timestamp('paid_at')->nullable();
            $table->text('payment_response')->nullable(); // JSON response from Razorpay
            $table->timestamps();

            $table->index('property_id');
            $table->index('owner_id');
            $table->index('status');
            $table->index('type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listing_payments');
    }
};
