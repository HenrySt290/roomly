<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class EnquiryMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'enquiry_id',
        'sender_id',
        'sender_role',
        'message',
        'type',
        'is_read',
        'metadata',
    ];

    protected $casts = [
        'is_read' => 'boolean',
        'metadata' => 'array',
    ];

    public function enquiry(): BelongsTo
    {
        return $this->belongsTo(Enquiry::class);
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function scopeText($query)
    {
        return $query->where('type', 'text');
    }

    public function scopeBookingRequest($query)
    {
        return $query->where('type', 'booking_request');
    }

    public function isSystem(): bool
    {
        return $this->type === 'system';
    }

    public function isBookingRequest(): bool
    {
        return $this->type === 'booking_request';
    }

    public function isBookingConfirmed(): bool
    {
        return $this->type === 'booking_confirmed';
    }
}
