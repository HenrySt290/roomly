<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\PropertyController;
use App\Http\Controllers\Api\V1\EnquiryController;
use App\Http\Controllers\Api\V1\ReviewController;
use App\Http\Controllers\Api\V1\PaymentController;
use App\Http\Controllers\Api\V1\SearchController;
use App\Http\Controllers\Api\V1\NotificationController;

/*
|--------------------------------------------------------------------------
| API Routes - Roomly SaaS MVP
| Pay-to-list model: No KYC blocking, publish after payment
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // Public routes
    Route::get('/cities', [SearchController::class, 'cities']);
    Route::get('/areas', [SearchController::class, 'areas']);
    Route::get('/amenities', [SearchController::class, 'amenities']);
    Route::get('/stats', [SearchController::class, 'stats']);
    Route::get('/search', [SearchController::class, 'search']);

    // Properties public
    Route::get('/properties', [PropertyController::class, 'index']);
    Route::get('/properties/{id}', [PropertyController::class, 'show']);
    Route::post('/properties/{id}/view', [PropertyController::class, 'recordView']);

    // Auth public
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
        Route::post('/reset-password', [AuthController::class, 'resetPassword']);
    });

    // Protected routes - JWT
    Route::middleware('auth:api')->group(function () {

        // Auth
        Route::prefix('auth')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::get('/me', [AuthController::class, 'me']);
            Route::post('/refresh', [AuthController::class, 'refresh']);
            Route::post('/refresh-token', [AuthController::class, 'refresh']);
            Route::post('/verify-email', [AuthController::class, 'verifyEmail']);
            Route::post('/resend-verification', [AuthController::class, 'resendVerification']);
        });

        // Properties owner
        Route::post('/properties', [PropertyController::class, 'store']);
        Route::put('/properties/{id}', [PropertyController::class, 'update']);
        Route::delete('/properties/{id}', [PropertyController::class, 'destroy']);
        Route::post('/properties/{id}/publish', [PropertyController::class, 'publish']);
        Route::post('/properties/{id}/occupy', [PropertyController::class, 'markOccupied']);
        Route::post('/properties/{id}/relist', [PropertyController::class, 'relist']);
        Route::get('/properties/my-properties', [PropertyController::class, 'myProperties']);
        Route::get('/my-properties', [PropertyController::class, 'myProperties']); // alias for Flutter
        Route::get('/properties/favourites', [PropertyController::class, 'favourites']);
        Route::post('/properties/{id}/favourite', [PropertyController::class, 'toggleFavourite']);
        Route::delete('/properties/{id}/favourite', [PropertyController::class, 'toggleFavourite']);
        Route::post('/properties/{id}/report', [PropertyController::class, 'report']);

        // Property search alias
        Route::get('/properties/search', [SearchController::class, 'search']);

        // Access Pass
        Route::prefix('access-pass')->group(function () {
            Route::get('/current', [PaymentController::class, 'currentAccessPass']);
            Route::get('/status', [PaymentController::class, 'accessPassStatus']);
            Route::get('/history', [PaymentController::class, 'accessPassHistory']);
            Route::get('/remaining-time', [PaymentController::class, 'remainingTime']);
            Route::post('/purchase', [PaymentController::class, 'createAccessPassOrder']);
            Route::post('/verify', [PaymentController::class, 'verifyPayment']); // Flutter uses /access-pass/verify
            Route::get('/my', [PaymentController::class, 'accessPassHistory']);
        });

        // Payments
        Route::prefix('payments')->group(function () {
            Route::post('/create-listing-order', [PaymentController::class, 'createListingOrder']);
            Route::post('/create-access-pass-order', [PaymentController::class, 'createAccessPassOrder']);
            Route::post('/verify', [PaymentController::class, 'verifyPayment']);
            Route::get('/transactions', [PaymentController::class, 'transactionHistory']);
            Route::get('/transaction/{id}', [PaymentController::class, 'getTransaction']);
            Route::get('/status/{orderId}', [PaymentController::class, 'paymentStatus']);
        });

        // Compatibility for Flutter's /payment/* endpoints
        Route::prefix('payment')->group(function () {
            Route::post('/create-order', [PaymentController::class, 'createListingOrder']);
            Route::post('/verify', [PaymentController::class, 'verifyPayment']);
            Route::get('/history', [PaymentController::class, 'transactionHistory']);
        });

        // Enquiries & Chat Booking System
        Route::prefix('enquiries')->group(function () {
            Route::get('/', [EnquiryController::class, 'myEnquiries']);
            Route::get('/received', [EnquiryController::class, 'receivedEnquiries']);
            Route::post('/', [EnquiryController::class, 'store']);
            Route::get('/{id}', [EnquiryController::class, 'show']);
            Route::post('/{id}/reply', [EnquiryController::class, 'reply']);
            Route::post('/{id}/read', [EnquiryController::class, 'markAsRead']);
            Route::post('/{id}/close', [EnquiryController::class, 'close']);
            Route::post('/{id}/accept', [EnquiryController::class, 'accept']);
            Route::delete('/{id}', [EnquiryController::class, 'destroy']);
            Route::get('/{id}/messages', [EnquiryController::class, 'messages']);
            Route::post('/{id}/messages', [EnquiryController::class, 'sendMessage']);
        });

        // Reviews
        Route::prefix('reviews')->group(function () {
            Route::get('/', [ReviewController::class, 'index']);
            Route::get('/my', [ReviewController::class, 'myReviews']);
            Route::post('/', [ReviewController::class, 'store']);
            Route::delete('/{id}', [ReviewController::class, 'destroy']);
        });
        Route::get('/properties/{id}/reviews', [ReviewController::class, 'index']);

        // Notifications
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index']);
            Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
            Route::post('/{id}/read', [NotificationController::class, 'markAsRead']);
            Route::post('/read-all', [NotificationController::class, 'markAllAsRead']);
            Route::delete('/{id}', [NotificationController::class, 'destroy']);
        });
    });
});

// Legacy /api without v1 prefix for Flutter compatibility
Route::prefix('api/v1')->group(function () {
    // Duplicate public for legacy clients using /api/v1 prefix via ApiClient baseUrl
    Route::get('/cities', [SearchController::class, 'cities']);
});
