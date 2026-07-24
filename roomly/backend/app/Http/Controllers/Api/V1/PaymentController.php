<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Models\Transaction;
use App\Models\AccessPass;
use App\Models\ListingPayment;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    /**
     * Create Razorpay order for listing fee ₹9
     * Pay-to-list: no KYC needed, publish after payment
     */
    public function createListingOrder(Request $request)
    {
        $request->validate(['property_id' => 'required|exists:properties,id']);

        $property = Property::where('owner_id', auth()->id())->findOrFail($request->property_id);

        // If already paid, return existing
        if ($property->listing_paid_at && $property->status === 'published') {
            return response()->json(['message' => 'Already paid and published', 'order' => $this->mockOrder($property, 9)], 200);
        }

        $order = $this->mockRazorpayOrder(9, 'listing_' . $property->id);

        // Create pending transaction
        $transaction = Transaction::create([
            'user_id' => auth()->id(),
            'amount' => 9,
            'type' => 'listing_fee',
            'status' => 'pending',
            'payment_gateway' => 'razorpay',
            'gateway_order_id' => $order['id'],
            'metadata' => ['property_id' => $property->id],
        ]);

        ListingPayment::create([
            'property_id' => $property->id,
            'user_id' => auth()->id(),
            'transaction_id' => $transaction->id,
            'amount' => 9,
            'status' => 'pending',
            'gateway_order_id' => $order['id'],
        ]);

        return response()->json([
            'message' => 'Listing order created',
            'order' => $order,
            'transaction_id' => $transaction->id,
        ], 201);
    }

    public function createAccessPassOrder(Request $request)
    {
        $user = auth()->user();

        // If active pass exists, return error
        if ($user->hasActiveAccessPass()) {
            $active = $user->activeAccessPass();
            return response()->json([
                'message' => 'Active pass exists',
                'access_pass' => $active,
                'remaining_seconds' => $active ? now()->diffInSeconds($active->expires_at, false) : 0,
            ], 200);
        }

        $order = $this->mockRazorpayOrder(5, 'access_pass_' . $user->id);

        $transaction = Transaction::create([
            'user_id' => $user->id,
            'amount' => 5,
            'type' => 'access_pass',
            'status' => 'pending',
            'payment_gateway' => 'razorpay',
            'gateway_order_id' => $order['id'],
        ]);

        return response()->json([
            'message' => 'Access pass order created',
            'order' => $order,
            'transaction_id' => $transaction->id,
        ], 201);
    }

    public function verifyPayment(Request $request)
    {
        $request->validate([
            'order_id' => 'required|string',
            'payment_id' => 'required|string',
            'signature' => 'required|string',
        ]);

        // In production, verify signature using Razorpay secret
        // Here we mock success
        $transaction = Transaction::where('gateway_order_id', $request->order_id)->first();

        if (!$transaction) {
            // Try find by order id in listing payments
            $listingPayment = ListingPayment::where('gateway_order_id', $request->order_id)->first();
            if ($listingPayment) {
                $transaction = $listingPayment->transaction;
            }
        }

        if ($transaction) {
            $transaction->update([
                'status' => 'success',
                'gateway_payment_id' => $request->payment_id,
                'gateway_signature' => $request->signature,
                'paid_at' => now(),
            ]);

            // Handle based on type + real-time notifications
            if ($transaction->type === 'listing_fee') {
                $propertyId = $transaction->metadata['property_id'] ?? $request->get('property_id');
                if ($propertyId) {
                    $property = Property::find($propertyId);
                    if ($property) {
                        $property->update([
                            'status' => 'published',
                            'listing_paid_at' => now(),
                            'expires_at' => now()->addDays(90),
                        ]);
                        $property->owner->ownerProfile?->increment('active_listings');

                        try {
                            Notification::create([
                                'user_id' => $property->owner_id,
                                'type' => 'payment',
                                'category' => 'payment',
                                'title' => 'Listing Published!',
                                'message' => $property->title . ' is now live after ₹9 payment',
                                'data' => ['property_id' => $property->id, 'type' => 'listing_published'],
                                'action_url' => '/properties/' . $property->id,
                                'is_read' => false,
                                'sent_at' => now(),
                            ]);
                        } catch (\Exception $e) {}
                    }
                }
                ListingPayment::where('transaction_id', $transaction->id)->update([
                    'status' => 'paid',
                    'gateway_payment_id' => $request->payment_id,
                    'gateway_signature' => $request->signature,
                    'paid_at' => now(),
                ]);
            } elseif ($transaction->type === 'access_pass') {
                $pass = AccessPass::create([
                    'user_id' => $transaction->user_id,
                    'transaction_id' => $transaction->id,
                    'status' => 'active',
                    'amount' => 5,
                    'purchased_at' => now(),
                    'activated_at' => now(),
                    'expires_at' => now()->addHours(24),
                    'properties_viewed' => 0,
                    'payment_response' => [
                        'order_id' => $request->order_id,
                        'payment_id' => $request->payment_id,
                    ],
                ]);

                try {
                    Notification::create([
                        'user_id' => $transaction->user_id,
                        'type' => 'payment',
                        'category' => 'payment',
                        'title' => 'Access Pass Activated!',
                        'message' => 'Your ₹5 pass is active for 24 hours. Unlock unlimited properties!',
                        'data' => ['type' => 'access_pass_activated', 'expires_at' => $pass->expires_at, 'remaining_seconds' => 86400],
                        'action_url' => '/home',
                        'is_read' => false,
                        'sent_at' => now(),
                    ]);
                } catch (\Exception $e) {}
            }
        }

        return response()->json([
            'message' => 'Payment verified',
            'verified' => true,
            'order_id' => $request->order_id,
            'payment_id' => $request->payment_id,
        ]);
    }

    public function transactionHistory(Request $request)
    {
        $transactions = Transaction::where('user_id', auth()->id())
            ->latest()
            ->paginate($request->get('limit', 20));

        return response()->json([
            'data' => $transactions->getCollection()->map(fn($t) => $this->formatTransaction($t)),
            'total' => $transactions->total(),
        ]);
    }

    public function getTransaction($id)
    {
        $transaction = Transaction::where('user_id', auth()->id())->findOrFail($id);
        return response()->json(['transaction' => $this->formatTransaction($transaction)]);
    }

    public function paymentStatus($orderId)
    {
        $transaction = Transaction::where('gateway_order_id', $orderId)->where('user_id', auth()->id())->firstOrFail();
        return response()->json(['status' => $transaction->status, 'transaction' => $this->formatTransaction($transaction)]);
    }

    public function currentAccessPass()
    {
        $user = auth()->user();
        $active = $user->activeAccessPass();

        if (!$active) {
            return response()->json(['message' => 'No active pass'], 404);
        }

        return response()->json([
            'pass' => [
                'id' => $active->id,
                'is_active' => $active->isActive(),
                'expires_at' => $active->expires_at,
                'purchased_at' => $active->purchased_at,
                'remaining_seconds' => now()->diffInSeconds($active->expires_at, false),
            ]
        ]);
    }

    public function accessPassStatus()
    {
        $user = auth()->user();
        $hasActive = $user->hasActiveAccessPass();
        $active = $hasActive ? $user->activeAccessPass() : null;

        return response()->json([
            'has_active_pass' => $hasActive,
            'remaining_seconds' => $active ? now()->diffInSeconds($active->expires_at, false) : 0,
            'expires_at' => $active?->expires_at,
        ]);
    }

    public function accessPassHistory(Request $request)
    {
        $passes = AccessPass::where('user_id', auth()->id())->latest()->paginate($request->get('limit', 20));
        return response()->json([
            'data' => $passes->getCollection()->map(fn($p) => [
                'id' => $p->id,
                'amount' => $p->amount,
                'status' => $p->status,
                'purchased_at' => $p->purchased_at,
                'expires_at' => $p->expires_at,
                'properties_viewed' => $p->properties_viewed,
            ]),
            'total' => $passes->total(),
        ]);
    }

    public function remainingTime()
    {
        $active = auth()->user()->activeAccessPass();
        if (!$active) {
            return response()->json(['message' => 'No active pass'], 404);
        }
        return response()->json(['remaining_seconds' => now()->diffInSeconds($active->expires_at, false)]);
    }

    private function mockRazorpayOrder(int $amountRupees, string $receipt): array
    {
        // Razorpay expects paise
        $amountPaise = $amountRupees * 100;
        return [
            'id' => 'order_' . Str::random(14),
            'receipt' => $receipt,
            'amount' => $amountPaise,
            'currency' => 'INR',
            'status' => 'created',
            'created_at' => now()->timestamp,
        ];
    }

    private function mockOrder($property, int $amount)
    {
        return $this->mockRazorpayOrder($amount, 'listing_' . $property->id);
    }

    private function formatTransaction($t): array
    {
        return [
            'id' => $t->id,
            'amount' => (float) $t->amount,
            'type' => $t->type,
            'status' => $t->status,
            'gateway_order_id' => $t->gateway_order_id,
            'gateway_payment_id' => $t->gateway_payment_id,
            'paid_at' => $t->paid_at,
            'created_at' => $t->created_at,
        ];
    }
}
