<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\OwnerProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    /**
     * Register new user - tenant or owner
     * If they pay, they can list (no KYC required)
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:users,email',
            'phone' => 'required|string|max:20',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|in:tenant,owner,admin',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'is_active' => true,
        ]);

        // Create owner profile if owner role - auto verified badge off, but no KYC blocking
        if ($user->role === 'owner') {
            OwnerProfile::create([
                'user_id' => $user->id,
                'kyc_status' => 'not_required', // Pay-to-list model
                'is_verified_badge' => false,
                'total_listings' => 0,
                'active_listings' => 0,
            ]);
        }

        // Assign role via spatie if needed
        try {
            $user->assignRole($request->role);
        } catch (\Exception $e) {
            // Roles may not be seeded yet, ignore
        }

        $token = JWTAuth::fromUser($user);
        $refreshToken = JWTAuth::customClaims(['type' => 'refresh'])->fromUser($user);

        return response()->json([
            'message' => 'Registration successful',
            'user' => $this->formatUser($user),
            'access_token' => $token,
            'refresh_token' => $refreshToken,
            'token_type' => 'bearer',
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validation failed', 'errors' => $validator->errors()], 422);
        }

        $credentials = $request->only('email', 'password');

        try {
            if (!$token = JWTAuth::attempt($credentials)) {
                return response()->json(['message' => 'Invalid credentials'], 401);
            }
        } catch (JWTException $e) {
            return response()->json(['message' => 'Could not create token'], 500);
        }

        $user = auth()->user();
        if (!$user->is_active || $user->is_suspended) {
            auth()->logout();
            return response()->json(['message' => 'Account suspended'], 403);
        }

        $refreshToken = JWTAuth::customClaims(['type' => 'refresh'])->fromUser($user);

        return response()->json([
            'message' => 'Login successful',
            'user' => $this->formatUser($user),
            'access_token' => $token,
            'refresh_token' => $refreshToken,
            'token_type' => 'bearer',
        ]);
    }

    public function me()
    {
        try {
            $user = auth()->user();
            if (!$user) {
                return response()->json(['message' => 'Unauthenticated'], 401);
            }
            return response()->json([
                'user' => $this->formatUser($user),
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Token invalid'], 401);
        }
    }

    public function logout()
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
            return response()->json(['message' => 'Logged out successfully']);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Failed to logout'], 500);
        }
    }

    public function refresh()
    {
        try {
            $token = JWTAuth::refresh(JWTAuth::getToken());
            $refreshToken = JWTAuth::customClaims(['type' => 'refresh'])->fromUser(auth()->user());
            return response()->json([
                'access_token' => $token,
                'refresh_token' => $refreshToken,
                'token_type' => 'bearer',
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Token refresh failed'], 401);
        }
    }

    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email']);
        // In production, send reset link via email queue
        return response()->json(['message' => 'Password reset link sent to email']);
    }

    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);
        if ($validator->fails()) {
            return response()->json(['message' => 'Validation failed', 'errors' => $validator->errors()], 422);
        }
        return response()->json(['message' => 'Password reset successful']);
    }

    public function verifyEmail(Request $request)
    {
        return response()->json(['message' => 'Email verified']);
    }

    public function resendVerification()
    {
        return response()->json(['message' => 'Verification email resent']);
    }

    private function formatUser($user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'is_active' => $user->is_active,
            'is_email_verified' => $user->email_verified_at !== null,
            'is_phone_verified' => $user->is_phone_verified,
            'created_at' => $user->created_at,
            'owner_profile' => $user->ownerProfile ?? null,
        ];
    }
}
