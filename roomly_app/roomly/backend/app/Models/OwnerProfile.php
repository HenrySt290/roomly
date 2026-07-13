<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class OwnerProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'aadhar_number',
        'pan_number',
        'kyc_status',
        'kyc_rejection_reason',
        'kyc_approved_at',
        'kyc_submitted_at',
        'total_listings',
        'active_listings',
        'occupied_listings',
        'total_earnings',
        'is_verified_badge',
    ];

    protected $casts = [
        'kyc_approved_at' => 'datetime',
        'kyc_submitted_at' => 'datetime',
        'total_listings' => 'integer',
        'active_listings' => 'integer',
        'occupied_listings' => 'integer',
        'total_earnings' => 'decimal:2',
        'is_verified_badge' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function kycDocuments(): HasMany
    {
        return $this->hasMany(KycDocument::class, 'owner_id');
    }

    public function isKycApproved(): bool
    {
        return $this->kyc_status === 'approved';
    }

    public function isKycPending(): bool
    {
        return in_array($this->kyc_status, ['pending', 'submitted']);
    }

    public function isKycRejected(): bool
    {
        return $this->kyc_status === 'rejected';
    }
}
