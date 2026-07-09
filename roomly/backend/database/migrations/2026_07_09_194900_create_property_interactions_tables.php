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
        Schema::create('property_favourites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('property_id')->constrained()->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['user_id', 'property_id']);
            $table->index('user_id');
            $table->index('property_id');
        });

        Schema::create('property_views', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->cascadeOnDelete(); // null for guests
            $table->string('session_id')->nullable(); // For guest tracking
            $table->ipAddress('ip_address');
            $table->text('user_agent')->nullable();
            $table->timestamps();

            $table->index('property_id');
            $table->index('user_id');
            $table->index('created_at');
        });

        Schema::create('enquiries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained()->cascadeOnDelete();
            $table->foreignId('tenant_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->text('message');
            $table->enum('status', ['pending', 'contacted', 'viewed', 'interested', 'not_interested', 'closed'])->default('pending');
            $table->timestamp('owner_replied_at')->nullable();
            $table->timestamps();

            $table->index('property_id');
            $table->index('tenant_id');
            $table->index('owner_id');
            $table->index('status');
        });

        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained()->cascadeOnDelete();
            $table->foreignId('tenant_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->tinyInteger('rating')->unsigned(); // 1-5
            $table->text('comment')->nullable();
            $table->boolean('is_verified_stay')->default(false); // Only if tenant actually moved in
            $table->boolean('is_approved')->default(false); // Admin moderation
            $table->text('admin_rejection_reason')->nullable();
            $table->integer('helpful_count')->default(0);
            $table->timestamps();

            $table->index('property_id');
            $table->index('tenant_id');
            $table->index('owner_id');
            $table->index('rating');
            $table->index('is_approved');
        });

        Schema::create('property_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained()->cascadeOnDelete();
            $table->foreignId('reported_by')->constrained('users')->cascadeOnDelete();
            $table->enum('reason', ['spam', 'fraud', 'incorrect_info', 'duplicate', 'unavailable', 'other']);
            $table->text('description');
            $table->enum('status', ['pending', 'investigating', 'resolved', 'dismissed'])->default('pending');
            $table->text('admin_notes')->nullable();
            $table->foreignId('resolved_by')->nullable()->constrained('users');
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index('property_id');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('property_reports');
        Schema::dropIfExists('reviews');
        Schema::dropIfExists('enquiries');
        Schema::dropIfExists('property_views');
        Schema::dropIfExists('property_favourites');
    }
};
