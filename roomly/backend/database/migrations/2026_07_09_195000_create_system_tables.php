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
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('type'); // email, sms, push, in_app
            $table->enum('category', ['auth', 'payment', 'property', 'enquiry', 'review', 'admin', 'system']);
            $table->string('title');
            $table->text('message');
            $table->json('data')->nullable(); // Additional notification data
            $table->string('action_url')->nullable(); // Click action URL
            $table->boolean('is_read')->default(false);
            $table->timestamp('read_at')->nullable();
            $table->timestamp('sent_at')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('type');
            $table->index('category');
            $table->index('is_read');
            $table->index('created_at');
        });

        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('action'); // created, updated, deleted, approved, rejected, etc.
            $table->string('model_type'); // App\Models\Property
            $table->unsignedBigInteger('model_id');
            $table->string('model_title')->nullable(); // Human readable title
            $table->json('old_values')->nullable(); // Before state
            $table->json('new_values')->nullable(); // After state
            $table->ipAddress('ip_address');
            $table->text('user_agent')->nullable();
            $table->timestamps();

            $table->index('user_id');
            $table->index('action');
            $table->index(['model_type', 'model_id']);
            $table->index('created_at');
        });

        Schema::create('kyc_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->enum('document_type', ['aadhar_front', 'aadhar_back', 'pan', 'ownership_proof', 'other']);
            $table->string('file_url');
            $table->string('file_name');
            $table->string('mime_type');
            $table->integer('file_size');
            $table->string('storage_disk')->default('s3');
            $table->enum('verification_status', ['pending', 'verified', 'rejected'])->default('pending');
            $table->text('rejection_reason')->nullable();
            $table->foreignId('verified_by')->nullable()->constrained('users');
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();

            $table->index('owner_id');
            $table->index('verification_status');
        });

        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->text('value')->nullable();
            $table->string('type')->default('string'); // string, boolean, integer, json
            $table->string('group')->default('general'); // general, payment, email, seo, etc.
            $table->text('description')->nullable();
            $table->boolean('is_public')->default(false); // Visible to frontend
            $table->timestamps();

            $table->index('key');
            $table->index('group');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('settings');
        Schema::dropIfExists('kyc_documents');
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('notifications');
    }
};
