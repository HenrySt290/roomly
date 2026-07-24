<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Models\PropertyFavourite;
use App\Models\PropertyView;
use App\Models\City;
use App\Models\Area;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class PropertyController extends Controller
{
    /**
     * List properties with filters - teaser for guests, full for pass holders
     */
    public function index(Request $request)
    {
        $query = Property::with(['city', 'area', 'images', 'owner'])
            ->where('status', 'published')
            ->latest();

        // Filters
        if ($request->filled('city')) {
            $cityName = $request->city;
            $query->whereHas('city', fn($q) => $q->where('name', 'like', "%{$cityName}%"));
        }
        if ($request->filled('area')) {
            $areaName = $request->area;
            $query->whereHas('area', fn($q) => $q->where('name', 'like', "%{$areaName}%"));
        }
        if ($request->filled('min_rent')) {
            $query->where('rent', '>=', $request->min_rent);
        }
        if ($request->filled('max_rent')) {
            $query->where('rent', '<=', $request->max_rent);
        }
        if ($request->filled('property_type')) {
            $query->where('property_type', $request->property_type);
        }
        if ($request->filled('room_type')) {
            $query->where('room_type', $request->room_type);
        }
        if ($request->filled('furnished')) {
            $query->where('furnished', $request->boolean('furnished'));
        }
        if ($request->filled('parking')) {
            $query->whereRaw("JSON_CONTAINS(amenities, '\"parking\"')");
        }
        if ($request->filled('wifi')) {
            $query->whereRaw("JSON_CONTAINS(amenities, '\"wifi\"')");
        }
        if ($request->filled('pet_friendly')) {
            $query->whereRaw("JSON_CONTAINS(amenities, '\"pet_friendly\"')");
        }
        if ($request->filled('sort_by')) {
            match ($request->sort_by) {
                'lowest_rent' => $query->orderBy('rent', 'asc'),
                'highest_rent' => $query->orderBy('rent', 'desc'),
                'nearest' => $query->orderBy('created_at', 'desc'), // Simplified, real would use haversine
                default => $query->latest(),
            };
        }

        $perPage = min($request->get('limit', 20), 100);
        $properties = $query->paginate($perPage);

        $user = auth()->user();
        $hasPass = $user ? $user->hasActiveAccessPass() : false;

        $data = $properties->getCollection()->map(function ($property) use ($hasPass) {
            return $this->formatProperty($property, $hasPass);
        });

        return response()->json([
            'data' => $data,
            'current_page' => $properties->currentPage(),
            'last_page' => $properties->lastPage(),
            'per_page' => $properties->perPage(),
            'total' => $properties->total(),
        ]);
    }

    public function show(Request $request, $id)
    {
        $property = Property::with(['city', 'area', 'images', 'owner.ownerProfile', 'reviews.tenant'])
            ->findOrFail($id);

        // Increment view count
        $property->increment('views_count');

        // Record view
        try {
            PropertyView::create([
                'property_id' => $property->id,
                'user_id' => auth()->id(),
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);
        } catch (\Exception $e) {
            // Ignore view tracking errors
        }

        $user = auth()->user();
        $hasPass = $user ? $user->hasActiveAccessPass() : false;

        return response()->json([
            'property' => $this->formatProperty($property, $hasPass, true),
            'has_active_pass' => $hasPass,
        ]);
    }

    /**
     * Create property - pay-to-list model, no KYC blocking
     * Creates draft, then requires payment to publish
     */
    public function store(Request $request)
    {
        $user = auth()->user();
        if (!$user || !$user->isOwner()) {
            return response()->json(['message' => 'Only owners can create listings'], 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:100',
            'description' => 'required|string|max:2000',
            'property_type' => 'required|in:apartment,house,pg,hostel,villa,other',
            'room_type' => 'required|in:single,double,shared,dormitory,1rk,1bhk,2bhk,3bhk,4bhk,single_room,shared_room',
            'rent' => 'required|numeric|min:1',
            'deposit' => 'required|numeric|min:0',
            'area' => 'required|string|max:100',
            'city' => 'required|string|max:100',
            'address' => 'required|string|max:500',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'amenities' => 'nullable|array',
            'rules' => 'nullable|array',
            'available_from' => 'nullable|date',
            'images' => 'nullable|array|max:10',
            'gender_preference' => 'nullable|in:any,male,female',
            'furnished' => 'nullable|boolean',
            'attached_bathroom' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validation failed', 'errors' => $validator->errors()], 422);
        }

        // Find or create city/area
        $city = City::firstOrCreate(
            ['name' => $request->city],
            ['slug' => Str::slug($request->city), 'is_active' => true]
        );

        $area = Area::firstOrCreate(
            ['city_id' => $city->id, 'name' => $request->area],
            ['slug' => Str::slug($request->area), 'is_active' => true]
        );

        $property = Property::create([
            'owner_id' => $user->id,
            'city_id' => $city->id,
            'area_id' => $area->id,
            'title' => $request->title,
            'description' => $request->description,
            'property_type' => $request->property_type,
            'room_type' => $request->room_type,
            'rent' => $request->rent,
            'security_deposit' => $request->deposit,
            'address' => $request->address,
            'latitude' => $request->latitude ?? 28.6139,
            'longitude' => $request->longitude ?? 77.2090,
            'gender_preference' => $request->gender_preference ?? 'any',
            'furnished' => $request->boolean('furnished', false),
            'attached_bathroom' => $request->boolean('attached_bathroom', false),
            'amenities' => $request->amenities ?? [],
            'rules' => $request->rules ?? [],
            'available_from' => $request->available_from ?? now(),
            'status' => 'pending_payment', // Pay-to-list, no approval needed after payment
        ]);

        // Handle images if URLs provided (simplified)
        if ($request->filled('images') && is_array($request->images)) {
            foreach ($request->images as $index => $url) {
                $property->images()->create([
                    'url' => is_string($url) ? $url : $url['url'] ?? '',
                    'is_primary' => $index === 0,
                    'sort_order' => $index,
                ]);
            }
        }

        $user->ownerProfile?->increment('total_listings');

        return response()->json([
            'message' => 'Property created, proceed to payment',
            'property' => $this->formatProperty($property->load(['city', 'area', 'images']), true, true),
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $user = auth()->user();
        $property = Property::where('owner_id', $user->id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|string|max:100',
            'description' => 'sometimes|string|max:2000',
            'rent' => 'sometimes|numeric|min:1',
            'deposit' => 'sometimes|numeric|min:0',
            'address' => 'sometimes|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $property->update($request->only([
            'title', 'description', 'rent', 'security_deposit', 'address',
            'latitude', 'longitude', 'amenities', 'rules', 'furnished', 'attached_bathroom'
        ]));

        return response()->json([
            'message' => 'Property updated',
            'property' => $this->formatProperty($property->fresh()->load(['city', 'area', 'images']), true, true),
        ]);
    }

    public function destroy($id)
    {
        $user = auth()->user();
        $property = Property::where('owner_id', $user->id)->findOrFail($id);
        $property->delete();

        return response()->json(['message' => 'Property deleted']);
    }

    public function publish($id)
    {
        $user = auth()->user();
        $property = Property::where('owner_id', $user->id)->findOrFail($id);

        // In pay-to-list model, if paid, publish immediately, else mark pending_payment
        if ($property->listing_paid_at) {
            $property->update(['status' => 'published', 'expires_at' => now()->addDays(90)]);
        } else {
            $property->update(['status' => 'pending_payment']);
        }

        return response()->json([
            'message' => 'Property published',
            'property' => $this->formatProperty($property->fresh()->load(['city', 'area']), true, true),
        ]);
    }

    public function markOccupied($id)
    {
        $property = Property::where('owner_id', auth()->id())->findOrFail($id);
        $property->update(['status' => 'occupied', 'occupied_at' => now()]);
        auth()->user()->ownerProfile?->increment('occupied_listings');

        return response()->json(['message' => 'Marked as occupied', 'property' => $this->formatProperty($property, true, true)]);
    }

    public function relist($id)
    {
        $property = Property::where('owner_id', auth()->id())->findOrFail($id);
        $property->update(['status' => 'pending_payment', 'occupied_at' => null, 'listing_paid_at' => null]);

        return response()->json(['message' => 'Ready for relisting payment', 'property' => $this->formatProperty($property, true, true)]);
    }

    public function myProperties(Request $request)
    {
        $query = Property::with(['city', 'area', 'images'])
            ->where('owner_id', auth()->id())
            ->latest();

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $properties = $query->paginate($request->get('limit', 20));

        return response()->json([
            'data' => $properties->getCollection()->map(fn($p) => $this->formatProperty($p, true, true)),
            'current_page' => $properties->currentPage(),
            'last_page' => $properties->lastPage(),
            'total' => $properties->total(),
        ]);
    }

    public function favourites(Request $request)
    {
        $favourites = PropertyFavourite::with(['property.city', 'property.area', 'property.images'])
            ->where('user_id', auth()->id())
            ->latest()
            ->paginate($request->get('limit', 20));

        return response()->json([
            'data' => $favourites->getCollection()->map(fn($fav) => $this->formatProperty($fav->property, true)),
            'total' => $favourites->total(),
        ]);
    }

    public function toggleFavourite($propertyId)
    {
        $userId = auth()->id();
        $existing = PropertyFavourite::where('user_id', $userId)->where('property_id', $propertyId)->first();

        if ($existing) {
            $existing->delete();
            Property::where('id', $propertyId)->decrement('favourites_count');
            return response()->json(['message' => 'Removed from favourites', 'is_favourite' => false]);
        } else {
            PropertyFavourite::create(['user_id' => $userId, 'property_id' => $propertyId]);
            Property::where('id', $propertyId)->increment('favourites_count');
            return response()->json(['message' => 'Added to favourites', 'is_favourite' => true]);
        }
    }

    public function recordView(Request $request, $propertyId)
    {
        PropertyView::create([
            'property_id' => $propertyId,
            'user_id' => auth()->id(),
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);
        Property::where('id', $propertyId)->increment('views_count');
        return response()->json(['message' => 'View recorded']);
    }

    public function report(Request $request, $propertyId)
    {
        $request->validate(['reason' => 'required|string', 'description' => 'required|string']);
        // Store report logic - simplified
        return response()->json(['message' => 'Report submitted, we will investigate']);
    }

    private function formatProperty($property, bool $hasPass = false, bool $isOwner = false): array
    {
        $property->loadMissing(['city', 'area', 'images']);

        $base = [
            'id' => $property->id,
            'title' => $property->title,
            'slug' => $property->slug,
            'rent' => (float) $property->rent,
            'security_deposit' => (float) $property->security_deposit,
            'property_type' => $property->property_type,
            'room_type' => $property->room_type,
            'city' => $property->city->name ?? $property->city_id,
            'area' => $property->area->name ?? $property->area_id,
            'is_furnished' => $property->furnished,
            'has_attached_bathroom' => $property->attached_bathroom,
            'gender_preference' => $property->gender_preference,
            'status' => $property->status,
            'views_count' => $property->views_count,
            'favourites_count' => $property->favourites_count,
            'average_rating' => (float) $property->average_rating,
            'total_reviews' => $property->total_reviews,
            'available_from' => $property->available_from,
            'created_at' => $property->created_at,
            'updated_at' => $property->updated_at,
            'owner_id' => $property->owner_id,
            'amenities' => $hasPass || $isOwner ? ($property->amenities ?? []) : array_slice($property->amenities ?? [], 0, 3),
            'images' => $property->images->pluck('url')->toArray() ?: ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'],
        ];

        if ($hasPass || $isOwner) {
            $base = array_merge($base, [
                'description' => $property->description,
                'address' => $property->address,
                'latitude' => (float) $property->latitude,
                'longitude' => (float) $property->longitude,
                'rules' => $property->rules ?? [],
                'owner_name' => $property->owner->name ?? null,
                'deposit' => (float) $property->security_deposit,
            ]);
        } else {
            $base['description'] = Str::limit($property->description, 100);
            $base['address'] = '';
            $base['latitude'] = 0;
            $base['longitude'] = 0;
        }

        return $base;
    }
}
