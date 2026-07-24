<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Enquiry extends Model
{
    use HasFactory;

    protected $fillable = [
        'property_id',
        'tenant_id',
        'owner_id',
        'message',
        'status',
        'contact_method',
        'owner_replied_at',
        'unread_count',
        'last_message',
        'last_message_at',
        'is_closed',
    ];

    protected $casts = [
        'owner_replied_at' => 'datetime',
        'last_message_at' => 'datetime',
        'unread_count' => 'integer',
        'is_closed' => 'boolean',
    ];

    // New chat system fields - if migration missing, these will be handled gracefully
    protected $attributes = [
        'status' => 'pending',
        'contact_method' => 'chat',
        'unread_count' => 0,
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(User::class, 'tenant_id');
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(EnquiryMessage::class)->orderBy('created_at');
    }

    // Helper to check if enquiry is for owner
    public function isForOwner(int $ownerId): bool
    {
        return $this->owner_id === $ownerId;
    }

    public function isFromTenant(int $tenantId): bool
    {
        return $this->tenant_id === $tenantId;
    }

    // Status helpers matching Flutter enum
    public function isPending(): bool
    {
        return in_array($this->status, ['pending']);
    }

    public function isReplied(): bool
    {
        return in_array($this->status, ['replied', 'contacted', 'viewed', 'interested']);
    }

    public function isAccepted(): bool
    {
        return $this->status === 'accepted';
    }

    public function scopeForUser($query, int $userId)
    {
        return $query->where(function ($q) use ($userId) {
            $q->where('tenant_id', $userId)->orWhere('owner_id', $userId);
        });
    }

    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function markAsReplied(): void
    {
        $this->update([
            'status' => 'replied',
            'owner_replied_at' => now(),
        ]);
    }

    public function markAsReadForOwner(): void
    {
        $this->decrement('unread_count');
        if ($this->unread_count < 0) {
            $this->update(['unread_count' => 0]);
        }
    }
}
