import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '@/models/User';
import { config } from '@/config/environment';
import { AppError } from '@/utils/AppError';
import { catchAsync } from '@/utils/catchAsync';
import { generateTokens, verifyRefreshToken } from '@/utils/tokenUtils';

interface AuthRequest extends Request {
  user?: any;
}

interface LoginRequest {
  email: string;
  password: string;
}

interface RegisterRequest {
  name: string;
  email: string;
  password: string;
}

interface RefreshTokenRequest {
  refreshToken: string;
}

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 50
 *                 example: "John Doe"
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john@example.com"
 *               password:
 *                 type: string
 *                 minLength: 6
 *                 example: "password123"
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "User registered successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *                     token:
 *                       type: string
 *                     refreshToken:
 *                       type: string
 *                     expiresIn:
 *                       type: integer
 *       400:
 *         description: Validation error or user already exists
 *       500:
 *         description: Internal server error
 */
export const register = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { name, email, password }: RegisterRequest = req.body;

  // Validation
  if (!name || !email || !password) {
    return next(new AppError('Name, email, and password are required', 400));
  }

  if (password.length < 6) {
    return next(new AppError('Password must be at least 6 characters long', 400));
  }

  // Check if user already exists
  const existingUser = await User.findOne({ email: email.toLowerCase() });
  if (existingUser) {
    return next(new AppError('User with this email already exists', 400));
  }

  // Create new user
  const user = await User.create({
    name: name.trim(),
    email: email.toLowerCase().trim(),
    password
  });

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user.id);

  // Response (matches iOS app AuthResponse structure)
  res.status(201).json({
    status: 'success',
    message: 'User registered successfully',
    data: {
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      token: accessToken,
      refreshToken,
      expiresIn: 7 * 24 * 60 * 60 // 7 days in seconds
    }
  });
});

/**
 * @swagger
 * /api/auth/signin:
 *   post:
 *     summary: Sign in an existing user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "john@example.com"
 *               password:
 *                 type: string
 *                 example: "password123"
 *     responses:
 *       200:
 *         description: User signed in successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "User signed in successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *                     token:
 *                       type: string
 *                     refreshToken:
 *                       type: string
 *                     expiresIn:
 *                       type: integer
 *       400:
 *         description: Invalid credentials
 *       401:
 *         description: Invalid email or password
 *       500:
 *         description: Internal server error
 */
export const signIn = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { email, password }: LoginRequest = req.body;

  // Validation
  if (!email || !password) {
    return next(new AppError('Email and password are required', 400));
  }

  // Find user and include password for comparison
  const user = await User.findOne({ 
    email: email.toLowerCase(), 
    isActive: true 
  }).select('+password');

  if (!user) {
    return next(new AppError('Invalid email or password', 401));
  }

  // Check password
  const isPasswordValid = await user.comparePassword(password);
  if (!isPasswordValid) {
    return next(new AppError('Invalid email or password', 401));
  }

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user.id);

  // Response (matches iOS app AuthResponse structure)
  res.status(200).json({
    status: 'success',
    message: 'User signed in successfully',
    data: {
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      token: accessToken,
      refreshToken,
      expiresIn: 7 * 24 * 60 * 60 // 7 days in seconds
    }
  });
});

/**
 * @swagger
 * /api/auth/refresh:
 *   post:
 *     summary: Refresh access token
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *     responses:
 *       200:
 *         description: Token refreshed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "Token refreshed successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *                     token:
 *                       type: string
 *                     refreshToken:
 *                       type: string
 *                     expiresIn:
 *                       type: integer
 *       400:
 *         description: Refresh token is required
 *       401:
 *         description: Invalid or expired refresh token
 *       500:
 *         description: Internal server error
 */
export const refreshToken = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { refreshToken: token }: RefreshTokenRequest = req.body;

  if (!token) {
    return next(new AppError('Refresh token is required', 400));
  }

  // Verify refresh token
  const decoded = verifyRefreshToken(token);
  
  // Find user
  const user = await User.findById(decoded.userId);
  if (!user || !user.isActive) {
    return next(new AppError('User not found or inactive', 401));
  }

  // Generate new tokens
  const { accessToken, refreshToken: newRefreshToken } = generateTokens(user.id);

  // Response (matches iOS app AuthResponse structure)
  res.status(200).json({
    status: 'success',
    message: 'Token refreshed successfully',
    data: {
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      token: accessToken,
      refreshToken: newRefreshToken,
      expiresIn: 7 * 24 * 60 * 60 // 7 days in seconds
    }
  });
});

/**
 * @swagger
 * /api/auth/profile:
 *   get:
 *     summary: Get current user profile
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "User profile retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *       401:
 *         description: Authentication required
 *       500:
 *         description: Internal server error
 */
export const getProfile = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  // User is already attached to request by auth middleware
  const user = req.user;

  res.status(200).json({
    status: 'success',
    message: 'User profile retrieved successfully',
    data: {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }
    }
  });
});

/**
 * @swagger
 * /api/auth/logout:
 *   post:
 *     summary: Logout user (client-side token removal)
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User logged out successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "User logged out successfully"
 *       401:
 *         description: Authentication required
 */
export const logout = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  // In a stateless JWT implementation, logout is typically handled client-side
  // The client should remove the token from storage
  // For server-side logout, you might want to implement a token blacklist with Redis

  res.status(200).json({
    status: 'success',
    message: 'User logged out successfully. Please remove the token from client storage.'
  });
});

/**
 * @swagger
 * /api/auth/verify:
 *   get:
 *     summary: Verify if current token is valid
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Token is valid
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "Token is valid"
 *                 data:
 *                   type: object
 *                   properties:
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *                     tokenExpiry:
 *                       type: string
 *                       format: date-time
 *       401:
 *         description: Invalid or expired token
 */
export const verifyToken = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  const user = req.user;
  
  // Get token expiry from the decoded JWT
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];
  
  if (token) {
    const decoded = jwt.decode(token) as any;
    const tokenExpiry = new Date(decoded.exp * 1000);
    
    res.status(200).json({
      status: 'success',
      message: 'Token is valid',
      data: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email
        },
        tokenExpiry: tokenExpiry.toISOString()
      }
    });
  } else {
    return next(new AppError('No token provided', 401));
  }
});