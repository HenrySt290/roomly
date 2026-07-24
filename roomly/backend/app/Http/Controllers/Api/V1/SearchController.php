<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\City;
use App\Models\Area;
use App\Models\Property;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function cities()
    {
        $cities = City::active()->orderBy('name')->get(['id', 'name', 'slug', 'state']);
        return response()->json(['data' => $cities]);
    }

    public function areas(Request $request)
    {
        $query = Area::with('city')->active();

        if ($request->filled('city')) {
            $cityName = $request->city;
            $query->whereHas('city', fn($q) => $q->where('name', 'like', "%{$cityName}%")->orWhere('slug', 'like', "%{$cityName}%"));
        }

        if ($request->filled('city_id')) {
            $query->where('city_id', $request->city_id);
        }

        $areas = $query->orderBy('name')->get(['id', 'city_id', 'name', 'slug']);

        return response()->json(['data' => $areas]);
    }

    public function amenities()
    {
        return response()->json([
            'data' => [
                ['key' => 'wifi', 'label' => 'WiFi', 'icon' => 'wifi'],
                ['key' => 'parking', 'label' => 'Parking', 'icon' => 'local_parking'],
                ['key' => 'furnished', 'label' => 'Furnished', 'icon' => 'chair'],
                ['key' => 'attached_bathroom', 'label' => 'Attached Bathroom', 'icon' => 'bathtub'],
                ['key' => 'pet_friendly', 'label' => 'Pet Friendly', 'icon' => 'pets'],
                ['key' => 'ac', 'label' => 'AC', 'icon' => 'ac_unit'],
                ['key' => 'lift', 'label' => 'Lift', 'icon' => 'elevator'],
                ['key' => 'security', 'label' => 'Security', 'icon' => 'security'],
                ['key' => 'gym', 'label' => 'Gym', 'icon' => 'fitness_center'],
            ]
        ]);
    }

    public function search(Request $request)
    {
        // Wrapper around PropertyController index but with extra geo handling
        $query = Property::with(['city', 'area', 'images'])
            ->where('status', 'published')
            ->latest();

        if ($request->filled('city')) {
            $query->whereHas('city', fn($q) => $q->where('name', 'like', "%{$request->city}%"));
        }
        if ($request->filled('area')) {
            $query->whereHas('area', fn($q) => $q->where('name', 'like', "%{$request->area}%"));
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

        // Geo radius search (simplified)
        if ($request->filled('lat') && $request->filled('lng') && $request->filled('radius')) {
            $lat = $request->lat;
            $lng = $request->lng;
            $radius = $request->radius; // km
            // Haversine approximation - for production use spatial index
            $query->whereRaw("(6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) < ?", [
                $lat, $lng, $lat, $radius
            ]);
        }

        $perPage = min($request->get('limit', 20), 100);
        $properties = $query->paginate($perPage);

        return response()->json([
            'data' => $properties->getCollection()->map(function ($p) {
                return [
                    'id' => $p->id,
                    'title' => $p->title,
                    'rent' => (float) $p->rent,
                    'property_type' => $p->property_type,
                    'room_type' => $p->room_type,
                    'city' => $p->city->name ?? null,
                    'area' => $p->area->name ?? null,
                    'latitude' => (float) $p->latitude,
                    'longitude' => (float) $p->longitude,
                    'primary_image' => $p->images()->first()?->url,
                    'is_furnished' => $p->furnished,
                ];
            }),
            'total' => $properties->total(),
        ]);
    }

    public function stats()
    {
        return response()->json([
            'total_properties' => Property::where('status', 'published')->count(),
            'total_cities' => City::active()->count(),
            'total_owners' => \App\Models\User::where('role', 'owner')->count(),
            'average_rent' => Property::where('status', 'published')->avg('rent'),
        ]);
    }
}
