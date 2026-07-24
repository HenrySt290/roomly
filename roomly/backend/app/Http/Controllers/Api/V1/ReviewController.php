<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Property;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function index(Request $request, $propertyId = null)
    {
        $propertyId = $propertyId ?? $request->get('property_id');

        $query = Review::with(['tenant', 'property'])
            ->where('is_approved', true)
            ->latest();

        if ($propertyId) {
            $query->where('property_id', $propertyId);
        }

        $reviews = $query->paginate($request->get('limit', 20));

        return response()->json([
            'data' => $reviews->getCollection()->map(fn($r) => $this->formatReview($r)),
            'current_page' => $reviews->currentPage(),
            'last_page' => $reviews->lastPage(),
            'total' => $reviews->total(),
            'average_rating' => $propertyId ? Property::find($propertyId)?->average_rating ?? 0 : 0,
        ]);
    }

    public function myReviews(Request $request)
    {
        $reviews = Review::with(['property.images', 'property.city'])
            ->where('tenant_id', auth()->id())
            ->latest()
            ->paginate($request->get('limit', 20));

        return response()->json([
            'data' => $reviews->getCollection()->map(fn($r) => $this->formatReview($r, true)),
            'total' => $reviews->total(),
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'property_id' => 'required|exists:properties,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'required|string|min:10|max:1000',
        ]);

        $user = auth()->user();
        $property = Property::findOrFail($request->property_id);

        // Check if user already reviewed this property
        $existing = Review::where('property_id', $property->id)->where('tenant_id', $user->id)->first();
        if ($existing) {
            return response()->json(['message' => 'You have already reviewed this property'], 422);
        }

        $review = Review::create([
            'property_id' => $property->id,
            'tenant_id' => $user->id,
            'owner_id' => $property->owner_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
            'is_approved' => true, // Auto approve for MVP, no admin needed
            'is_verified_stay' => false,
        ]);

        // Update property average rating
        $avg = Review::where('property_id', $property->id)->where('is_approved', true)->avg('rating');
        $count = Review::where('property_id', $property->id)->where('is_approved', true)->count();
        $property->update([
            'average_rating' => $avg,
            'total_reviews' => $count,
        ]);

        return response()->json([
            'message' => 'Review submitted',
            'data' => $this->formatReview($review->load(['tenant', 'property'])),
            'review' => $this->formatReview($review),
        ], 201);
    }

    public function destroy($id)
    {
        $review = Review::where('tenant_id', auth()->id())->findOrFail($id);
        $propertyId = $review->property_id;
        $review->delete();

        // Recalculate average
        $property = Property::find($propertyId);
        if ($property) {
            $avg = Review::where('property_id', $propertyId)->where('is_approved', true)->avg('rating') ?? 0;
            $count = Review::where('property_id', $propertyId)->where('is_approved', true)->count();
            $property->update(['average_rating' => $avg, 'total_reviews' => $count]);
        }

        return response()->json(['message' => 'Review deleted']);
    }

    private function formatReview($review, bool $withProperty = false): array
    {
        $review->loadMissing(['tenant']);

        $data = [
            'id' => $review->id,
            'property_id' => $review->property_id,
            'tenant_id' => $review->tenant_id,
            'tenant_name' => $review->tenant->name ?? 'Tenant',
            'tenant_avatar' => $review->tenant->phone ?? null,
            'rating' => $review->rating,
            'comment' => $review->comment,
            'is_approved' => $review->is_approved,
            'is_verified_stay' => $review->is_verified_stay,
            'created_at' => $review->created_at,
            'updated_at' => $review->updated_at,
        ];

        if ($withProperty && $review->relationLoaded('property')) {
            $data['property'] = $review->property ? [
                'id' => $review->property->id,
                'title' => $review->property->title,
                'city' => $review->property->city?->name,
                'thumbnail' => $review->property->images()->first()?->url,
            ] : null;
        }

        return $data;
    }
}
