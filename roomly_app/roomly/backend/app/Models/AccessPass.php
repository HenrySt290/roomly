<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AccessPass extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'transaction_id',
        'status',
        'amount',
        'purchased_at',
        'activated_at',
        'expires_at',
        'properties_viewed',
        'payment_response',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'purchased_at' => 'datetime',
        'activated_at' => 'datetime',
        'expires_at' => 'datetime',
        'properties_viewed' => 'integer',
        'payment_response' => 'array',
    ];

    const VALIDITY_HOURS = 24;

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class, 'transaction_id');
    }

    /**
     * Check if pass is active
     */
    public function isActive(): bool
    {
        return $this->status === 'active' 
            && $this->expires_at 
            && $this->expires_at->isFuture();
    }

    /**
     * Get remaining hours
     */
    public function getRemainingHours(): int
    {
        if (!$this->isActive()) {
            return 0;
        }

        return max(0, now()->diffInHours($this->expires_at, false));
    }

    /**
     * Get remaining minutes
     */
    public function getRemainingMinutes(): int
    {
        if (!$this->isActive()) {
            return 0;
        }

        return max(0, now()->diffInMinutes($this->expires_at, false));
    }

    /**
     * Activate the pass
     */
    public function activate(): void
    {
        $this->update([
            'status' => 'active',
            'activated_at' => now(),
            'expires_at' => now()->addHours(self::VALIDITY_HOURS),
        ]);
    }

    /**
     * Increment properties viewed count
     */
    public function incrementViewed(): void
    {
        $this->increment('properties_viewed');
    }
}
