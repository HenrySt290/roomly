<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Spatie\Permission\Traits\HasRoles;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\HasMany;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable, HasRoles;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
        'is_active',
        'is_suspended',
        'suspension_reason',
        'suspended_at',
        'is_phone_verified',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
            'is_suspended' => 'boolean',
            'is_phone_verified' => 'boolean',
            'suspended_at' => 'datetime',
        ];
    }

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [
            'role' => $this->role,
            'is_owner' => $this->role === 'owner',
            'is_tenant' => $this->role === 'tenant',
            'is_admin' => $this->role === 'admin',
        ];
    }

    /**
     * Check if user is an owner
     */
    public function isOwner(): bool
    {
        return $this->role === 'owner';
    }

    /**
     * Check if user is a tenant
     */
    public function isTenant(): bool
    {
        return $this->role === 'tenant';
    }

    /**
     * Check if user is an admin
     */
    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    /**
     * Get owner profile relationship
     */
    public function ownerProfile(): HasOne
    {
        return $this->hasOne(OwnerProfile::class);
    }

    /**
     * Get tenant profile relationship
     */
    public function tenantProfile(): HasOne
    {
        return $this->hasOne(TenantProfile::class);
    }

    /**
     * Get properties relationship (for owners)
     */
    public function properties(): HasMany
    {
        return $this->hasMany(Property::class, 'owner_id');
    }

    /**
     * Get access passes relationship
     */
    public function accessPasses(): HasMany
    {
        return $this->hasMany(AccessPass::class);
    }

    /**
     * Get transactions relationship
     */
    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }

    /**
     * Get notifications relationship
     */
    public function notifications(): HasMany
    {
        return $this->hasMany(Notification::class);
    }

    /**
     * Get favourites relationship
     */
    public function favourites(): HasMany
    {
        return $this->hasMany(PropertyFavourite::class);
    }

    /**
     * Get enquiries sent relationship
     */
    public function enquiriesSent(): HasMany
    {
        return $this->hasMany(Enquiry::class, 'tenant_id');
    }

    /**
     * Get enquiries received relationship (for owners)
     */
    public function enquiriesReceived(): HasMany
    {
        return $this->hasMany(Enquiry::class, 'owner_id');
    }

    /**
     * Get reviews relationship
     */
    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class, 'tenant_id');
    }

    /**
     * Get active access pass
     */
    public function activeAccessPass(): ?AccessPass
    {
        return $this->accessPasses()
            ->where('status', 'active')
            ->where('expires_at', '>', now())
            ->latest('activated_at')
            ->first();
    }

    /**
     * Check if user has active access pass
     */
    public function hasActiveAccessPass(): bool
    {
        return $this->activeAccessPass() !== null;
    }
}
