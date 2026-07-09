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
        Schema::create('properties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('city_id')->constrained()->cascadeOnDelete();
            $table->foreignId('area_id')->constrained()->cascadeOnDelete();
            
            // Basic Info
            $table->string('title');
            $table->string('slug')->unique();
            $table->text('description');
            
            // Property Details
            $table->enum('property_type', ['apartment', 'house', 'pg', 'hostel', 'villa']);
            $table->enum('room_type', ['1rk', '1bhk', '2bhk', '3bhk', '4bhk', 'single_room', 'shared_room']);
            $table->decimal('rent', 10, 2);
            $table->decimal('security_deposit', 10, 2)->default(0);
            $table->decimal('room_size', 8, 2)->nullable(); // in sqft
            
            // Location
            $table->string('address');
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            
            // Preferences
            $table->enum('gender_preference', ['any', 'male', 'female'])->default('any');
            $table->boolean('furnished')->default(false);
            $table->boolean('attached_bathroom')->default(false);
            
            // Amenities (JSON)
            $table->json('amenities')->nullable(); // ['wifi', 'parking', 'pet_friendly', 'ac', 'gym', 'pool']
            
            // Rules
            $table->json('rules')->nullable(); // ['no_smoking', 'no_drinking', 'no_parties', 'curfew_time']
            
            // Availability
            $table->date('available_from')->default(now()->format('Y-m-d'));
            $table->enum('status', ['draft', 'pending_payment', 'pending_approval', 'published', 'occupied', 'expired', 'rejected', 'hidden'])->default('draft');
            
            // Stats
            $table->integer('views_count')->default(0);
            $table->integer('favourites_count')->default(0);
            $table->integer('enquiries_count')->default(0);
            $table->decimal('average_rating', 3, 2)->default(0);
            $table->integer('total_reviews')->default(0);
            
            // Listing Fee Tracking
            $table->timestamp('listing_paid_at')->nullable();
            $table->timestamp('occupied_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            
            $table->timestamps();
            $table->softDeletes();

            // Indexes for search performance
            $table->index('slug');
            $table->index('owner_id');
            $table->index('city_id');
            $table->index('area_id');
            $table->index('property_type');
            $table->index('room_type');
            $table->index('rent');
            $table->index('status');
            $table->index('gender_preference');
            $table->index('furnished');
            $table->index('available_from');
            $table->index(['latitude', 'longitude']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('properties');
    }
};
