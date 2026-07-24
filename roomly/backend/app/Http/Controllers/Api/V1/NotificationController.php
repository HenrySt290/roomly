<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', auth()->id())
            ->latest()
            ->paginate($request->get('limit', 20));

        return response()->json([
            'data' => $notifications->getCollection()->map(fn($n) => $this->format($n)),
            'total' => $notifications->total(),
            'current_page' => $notifications->currentPage(),
            'last_page' => $notifications->lastPage(),
        ]);
    }

    public function markAsRead($id)
    {
        $notification = Notification::where('user_id', auth()->id())->findOrFail($id);
        $notification->markAsRead();

        return response()->json(['message' => 'Marked as read']);
    }

    public function markAllAsRead()
    {
        Notification::where('user_id', auth()->id())->where('is_read', false)->update([
            'is_read' => true,
            'read_at' => now(),
        ]);

        return response()->json(['message' => 'All marked as read']);
    }

    public function destroy($id)
    {
        $notification = Notification::where('user_id', auth()->id())->findOrFail($id);
        $notification->delete();

        return response()->json(['message' => 'Deleted']);
    }

    public function unreadCount()
    {
        $count = Notification::where('user_id', auth()->id())->where('is_read', false)->count();
        return response()->json(['count' => $count, 'unread_count' => $count]);
    }

    private function format($n): array
    {
        return [
            'id' => $n->id,
            'title' => $n->title,
            'body' => $n->message,
            'message' => $n->message,
            'type' => $n->type,
            'category' => $n->category,
            'is_read' => $n->is_read,
            'read' => $n->is_read,
            'data' => $n->data,
            'action_url' => $n->action_url,
            'created_at' => $n->created_at,
        ];
    }
}
