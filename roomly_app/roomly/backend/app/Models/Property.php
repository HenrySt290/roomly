<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Property extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'owner_id',
        'city_id',
        'area_id',
        'title',
        'slug',
        'description',
        'property_type',
        'room_type',
        'rent',
        'security_deposit',
        'room_size',
        'address',
        'latitude',
        'longitude',
        'gender_preference',
        'furnished',
        'attached_bathroom',
        'amenities',
        'rules',
        'available_from',
        'status',
        'views_count',
        'favourites_count',
        'enquiries_count',
        'average_rating',
        'total_reviews',
        'listing_paid_at',
        'occupied_at',
        'expires_at',
    ];

    protected $casts = [
        'rent' => 'decimal:2',
        'security_deposit' => 'decimal:2',
        'room_size' => 'decimal:2',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'furnished' => 'boolean',
        'attached_bathroom' => 'boolean',
        'amenities' => 'array',
        'rules' => 'array',
        'available_from' => 'date',
        'listing_paid_at' => 'datetime',
        'occupied_at' => 'datetime',
        'expires_at' => 'datetime',
        'views_count' => 'integer',
        'favourites_count' => 'integer',
        'enquiries_count' => 'integer',
        'average_rating' => 'decimal:2',
        'total_reviews' => 'integer',
    ];

    /**
     * Boot the model
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($property) {
            if (empty($property->slug)) {
                $property->slug = Str::slug($property->title) . '-' . Str::random(6);
            }
        });

        static::updating(function ($property) {
            if ($property->isDirty('title')) {
                $property->slug = Str::slug($property->title) . '-' . Str::random(6);
            }
        });
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function city(): BelongsTo
    {
        return $this->belongsTo(City::class);
    }

    public function area(): BelongsTo
    {
        return $this->belongsTo(Area::class);
    }

    public function images(): HasMany
    {
        return $this->hasMany(PropertyImage::class);
    }

    public function primaryImage(): ?PropertyImage
    {
        return $this->images()->where('is_primary', true)->first() 
            ?? $this->images()->orderBy('sort_order')->first();
    }

    public function favourites(): HasMany
    {
        return $this->hasMany(PropertyFavourite::class);
    }

    public function views(): HasMany
    {
        return $this->hasMany(PropertyView::class);
    }

    public function enquiries(): HasMany
    {
        return $this->hasMany(Enquiry::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function listingPayment(): HasOne
    {
        return $this->hasOne(ListingPayment::class);
    }

    /**
     * Check if property is published
     */
    public function isPublished(): bool
    {
        return $this->status === 'published';
    }

    /**
     * Check if property is occupied
     */
    public function isOccupied(): bool
    {
        return $this->status === 'occupied';
    }

    /**
     * Check if property is available
     */
    public function isAvailable(): bool
    {
        return $this->status === 'published';
    }

    /**
     * Check if property requires payment
     */
    public function requiresPayment(): bool
    {
        return in_array($this->status, ['draft', 'pending_payment']);
    }

    /**
     * Get teaser data for non-pass holders
     */
    public function getTeaserData(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'rent' => $this->rent,
            'property_type' => $this->property_type,
            'room_type' => $this->room_type,
            'area' => $this->area?->name,
            'city' => $this->city?->name,
            'furnished' => $this->furnished,
            'attached_bathroom' => $this->attached_bathroom,
            'gender_preference' => $this->gender_preference,
            'amenities' => array_slice($this->amenities ?? [], 0, 3), // Only first 3 amenities
            'primary_image' => $this->primaryImage()?->url,
            'room_size' => $this->room_size,
            'available_from' => $this->available_from,
        ];
    }

    /**
     * Get full data for pass holders
     */
    public function getFullData(): array
    {
        return array_merge($this->getTeaserData(), [
            'description' => $this->description,
            'address' => $this->address,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'security_deposit' => $this->security_deposit,
            'rules' => $this->rules,
            'amenities' => $this->amenities,
            'images' => $this->images->map(fn($img) => $img->url),
            'owner' => [
                'name' => $this->owner->name,
                'is_verified' => $this->owner->ownerProfile?->is_verified_badge ?? false,
            ],
        ]);
    }
}
