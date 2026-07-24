<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('enquiry_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('enquiry_id')->constrained('enquiries')->cascadeOnDelete();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->string('sender_role')->default('tenant'); // tenant, owner, system
            $table->text('message');
            $table->enum('type', ['text', 'system', 'booking_request', 'booking_confirmed', 'payment_reminder'])->default('text');
            $table->boolean('is_read')->default(false);
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index('enquiry_id');
            $table->index('sender_id');
            $table->index('type');
            $table->index('created_at');
        });

        // Enhance enquiries table with new columns needed for chat system
        Schema::table('enquiries', function (Blueprint $table) {
            if (!Schema::hasColumn('enquiries', 'contact_method')) {
                $table->enum('contact_method', ['chat', 'whatsapp', 'call'])->default('chat')->after('message');
            }
            if (!Schema::hasColumn('enquiries', 'unread_count')) {
                $table->integer('unread_count')->default(0)->after('status');
            }
            if (!Schema::hasColumn('enquiries', 'last_message')) {
                $table->text('last_message')->nullable()->after('unread_count');
            }
            if (!Schema::hasColumn('enquiries', 'last_message_at')) {
                $table->timestamp('last_message_at')->nullable()->after('last_message');
            }
            if (!Schema::hasColumn('enquiries', 'is_closed')) {
                $table->boolean('is_closed')->default(false)->after('last_message_at');
            }
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('enquiry_messages');
        Schema::table('enquiries', function (Blueprint $table) {
            $table->dropColumn(['contact_method', 'unread_count', 'last_message', 'last_message_at', 'is_closed']);
        });
    }
};
