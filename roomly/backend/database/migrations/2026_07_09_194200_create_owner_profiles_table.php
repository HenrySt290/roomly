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
        Schema::create('owner_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('aadhar_number')->nullable();
            $table->string('pan_number')->nullable();
            $table->enum('kyc_status', ['pending', 'submitted', 'approved', 'rejected'])->default('pending');
            $table->text('kyc_rejection_reason')->nullable();
            $table->timestamp('kyc_approved_at')->nullable();
            $table->timestamp('kyc_submitted_at')->nullable();
            $table->integer('total_listings')->default(0);
            $table->integer('active_listings')->default(0);
            $table->integer('occupied_listings')->default(0);
            $table->decimal('total_earnings', 10, 2)->default(0);
            $table->boolean('is_verified_badge')->default(false);
            $table->timestamps();

            $table->unique('user_id');
            $table->index('kyc_status');
            $table->index('is_verified_badge');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('owner_profiles');
    }
};
