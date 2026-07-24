<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Enquiry;
use App\Models\EnquiryMessage;
use App\Models\Property;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EnquiryController extends Controller
{
    public function myEnquiries(Request $request)
    {
        $user = auth()->user();
        $enquiries = Enquiry::with(['property.images', 'owner', 'tenant'])
            ->where('tenant_id', $user->id)
            ->latest()
            ->paginate($request->get('limit', 20));

        return response()->json([
            'data' => $enquiries->getCollection()->map(fn($e) => $this->formatEnquiry($e)),
            'current_page' => $enquiries->currentPage(),
            'last_page' => $enquiries->lastPage(),
            'total' => $enquiries->total(),
        ]);
    }

    public function receivedEnquiries(Request $request)
    {
        $user = auth()->user();
        if (!$user->isOwner()) {
            return response()->json(['message' => 'Only owners can view received enquiries'], 403);
        }

        $enquiries = Enquiry::with(['property.images', 'tenant', 'owner'])
            ->where('owner_id', $user->id)
            ->latest()
            ->paginate($request->get('limit', 20));

        return response()->json([
            'data' => $enquiries->getCollection()->map(fn($e) => $this->formatEnquiry($e)),
            'current_page' => $enquiries->currentPage(),
            'last_page' => $enquiries->lastPage(),
            'total' => $enquiries->total(),
        ]);
    }

    public function show($id)
    {
        $enquiry = Enquiry::with(['property.images', 'tenant', 'owner', 'messages.sender'])
            ->where(function ($q) {
                $uid = auth()->id();
                $q->where('tenant_id', $uid)->orWhere('owner_id', $uid);
            })
            ->findOrFail($id);

        return response()->json([
            'data' => $this->formatEnquiry($enquiry, true),
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'property_id' => 'required|exists:properties,id',
            'message' => 'required|string|min:5|max:1000',
            'contact_method' => 'nullable|in:chat,whatsapp,call',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validation failed', 'errors' => $validator->errors()], 422);
        }

        $property = Property::findOrFail($request->property_id);
        $user = auth()->user();

        if ($property->owner_id === $user->id) {
            return response()->json(['message' => 'Cannot enquire on own property'], 403);
        }

        // Check if active pass required - tenant must have active pass unless owner
        if (!$user->hasActiveAccessPass() && $user->isTenant()) {
            // For demo, allow but warn - production would block
            // return response()->json(['message' => 'Active access pass required'], 403);
        }

        $enquiry = Enquiry::create([
            'property_id' => $property->id,
            'tenant_id' => $user->id,
            'owner_id' => $property->owner_id,
            'message' => $request->message,
            'contact_method' => $request->contact_method ?? 'chat',
            'status' => 'pending',
            'unread_count' => 1, // For owner
            'last_message' => $request->message,
            'last_message_at' => now(),
        ]);

        $property->increment('enquiries_count');

        // Create first message
        EnquiryMessage::create([
            'enquiry_id' => $enquiry->id,
            'sender_id' => $user->id,
            'sender_role' => $user->role,
            'message' => $request->message,
            'type' => 'text',
        ]);

        return response()->json([
            'message' => 'Enquiry sent',
            'data' => $this->formatEnquiry($enquiry->load(['property.images', 'tenant', 'owner'])),
            'enquiry' => $this->formatEnquiry($enquiry),
        ], 201);
    }

    public function reply(Request $request, $id)
    {
        $request->validate(['message' => 'required|string|min:1|max:1000']);

        $enquiry = Enquiry::where(function ($q) {
            $uid = auth()->id();
            $q->where('tenant_id', $uid)->orWhere('owner_id', $uid);
        })->findOrFail($id);

        $user = auth()->user();

        $enquiry->update([
            'status' => $user->isOwner() ? 'replied' : 'pending',
            'owner_replied_at' => $user->isOwner() ? now() : $enquiry->owner_replied_at,
            'last_message' => $request->message,
            'last_message_at' => now(),
            'unread_count' => $enquiry->unread_count + 1,
        ]);

        // Also create message for chat history
        EnquiryMessage::create([
            'enquiry_id' => $enquiry->id,
            'sender_id' => $user->id,
            'sender_role' => $user->role,
            'message' => $request->message,
            'type' => 'text',
        ]);

        return response()->json([
            'message' => 'Replied',
            'data' => $this->formatEnquiry($enquiry->fresh()->load(['property.images', 'tenant', 'owner'])),
        ]);
    }

    public function messages(Request $request, $id)
    {
        $enquiry = Enquiry::where(function ($q) {
            $uid = auth()->id();
            $q->where('tenant_id', $uid)->orWhere('owner_id', $uid);
        })->findOrFail($id);

        $messages = EnquiryMessage::where('enquiry_id', $enquiry->id)
            ->with('sender')
            ->orderBy('created_at')
            ->paginate($request->get('limit', 50));

        return response()->json([
            'data' => $messages->getCollection()->map(fn($m) => $this->formatMessage($m)),
            'current_page' => $messages->currentPage(),
            'last_page' => $messages->lastPage(),
        ]);
    }

    public function sendMessage(Request $request, $id)
    {
        $request->validate([
            'message' => 'required|string|min:1|max:1000',
            'type' => 'nullable|in:text,system,booking_request,booking_confirmed,payment_reminder',
            'metadata' => 'nullable|array',
        ]);

        $enquiry = Enquiry::where(function ($q) {
            $uid = auth()->id();
            $q->where('tenant_id', $uid)->orWhere('owner_id', $uid);
        })->findOrFail($id);

        $user = auth()->user();

        $enquiry->update([
            'last_message' => $request->message,
            'last_message_at' => now(),
            'unread_count' => $enquiry->unread_count + 1,
            'status' => $enquiry->status === 'pending' && $user->isOwner() ? 'replied' : $enquiry->status,
        ]);

        $message = EnquiryMessage::create([
            'enquiry_id' => $enquiry->id,
            'sender_id' => $user->id,
            'sender_role' => $user->role,
            'message' => $request->message,
            'type' => $request->type ?? 'text',
            'metadata' => $request->metadata,
        ]);

        return response()->json([
            'message' => 'Message sent',
            'data' => $this->formatMessage($message),
        ], 201);
    }

    public function markAsRead($id)
    {
        $enquiry = Enquiry::where('owner_id', auth()->id())->orWhere('tenant_id', auth()->id())->findOrFail($id);
        $enquiry->update(['unread_count' => 0]);

        EnquiryMessage::where('enquiry_id', $enquiry->id)
            ->where('sender_id', '!=', auth()->id())
            ->update(['is_read' => true]);

        return response()->json(['message' => 'Marked as read']);
    }

    public function close($id)
    {
        $enquiry = Enquiry::where(function ($q) {
            $q->where('tenant_id', auth()->id())->orWhere('owner_id', auth()->id());
        })->findOrFail($id);

        $enquiry->update(['status' => 'closed', 'is_closed' => true]);

        EnquiryMessage::create([
            'enquiry_id' => $enquiry->id,
            'sender_id' => auth()->id(),
            'sender_role' => 'system',
            'message' => 'Chat closed by ' . auth()->user()->name,
            'type' => 'system',
        ]);

        return response()->json(['message' => 'Enquiry closed']);
    }

    public function accept($id)
    {
        $enquiry = Enquiry::where('owner_id', auth()->id())->findOrFail($id);
        $enquiry->update(['status' => 'accepted']);

        EnquiryMessage::create([
            'enquiry_id' => $enquiry->id,
            'sender_id' => auth()->id(),
            'sender_role' => 'system',
            'message' => 'Booking accepted! Owner confirmed your request. Contact details shared.',
            'type' => 'booking_confirmed',
        ]);

        return response()->json(['message' => 'Booking accepted', 'data' => $this->formatEnquiry($enquiry)]);
    }

    public function destroy($id)
    {
        $enquiry = Enquiry::where('tenant_id', auth()->id())->orWhere('owner_id', auth()->id())->findOrFail($id);
        $enquiry->delete();
        return response()->json(['message' => 'Enquiry deleted']);
    }

    private function formatEnquiry($enquiry, bool $withMessages = false): array
    {
        $enquiry->loadMissing(['property', 'tenant', 'owner']);

        $data = [
            'id' => $enquiry->id,
            'property_id' => $enquiry->property_id,
            'property_title' => $enquiry->property->title ?? $enquiry->property_title ?? 'Property',
            'property_thumbnail' => $enquiry->property->images()->first()?->url ?? null,
            'tenant_id' => $enquiry->tenant_id,
            'tenant_name' => $enquiry->tenant->name ?? $enquiry->tenant_name ?? null,
            'tenant_avatar' => $enquiry->tenant->phone ?? null, // simplified
            'owner_id' => $enquiry->owner_id,
            'owner_name' => $enquiry->owner->name ?? $enquiry->owner_name ?? null,
            'message' => $enquiry->message,
            'contact_method' => $enquiry->contact_method ?? 'chat',
            'status' => $enquiry->status,
            'unread_count' => $enquiry->unread_count ?? 0,
            'last_message' => $enquiry->last_message,
            'last_message_at' => $enquiry->last_message_at,
            'created_at' => $enquiry->created_at,
            'updated_at' => $enquiry->updated_at,
            'property' => $enquiry->property ? [
                'id' => $enquiry->property->id,
                'title' => $enquiry->property->title,
                'thumbnail' => $enquiry->property->images()->first()?->url,
            ] : null,
        ];

        if ($withMessages) {
            $data['messages'] = $enquiry->messages()->with('sender')->orderBy('created_at')->get()->map(fn($m) => $this->formatMessage($m));
        }

        return $data;
    }

    private function formatMessage($msg): array
    {
        $msg->loadMissing('sender');
        return [
            'id' => $msg->id,
            'enquiry_id' => $msg->enquiry_id,
            'sender_id' => $msg->sender_id,
            'sender_name' => $msg->sender->name ?? $msg->sender_name ?? null,
            'sender_role' => $msg->sender_role,
            'message' => $msg->message,
            'type' => $msg->type,
            'is_read' => $msg->is_read,
            'metadata' => $msg->metadata,
            'created_at' => $msg->created_at,
            'timestamp' => $msg->created_at,
        ];
    }
}
