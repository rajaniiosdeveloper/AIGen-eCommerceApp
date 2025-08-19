import jwt from 'jsonwebtoken';
import { config } from '@/config/environment';
import { AppError } from './AppError';

interface TokenPayload {
  userId: string;
  iat?: number;
  exp?: number;
}

/**
 * Generate JWT access and refresh tokens for a user
 * @param userId - User ID to include in token payload
 * @returns Object containing access token and refresh token
 */
export const generateTokens = (userId: string) => {
  const payload: TokenPayload = { userId };

  const accessToken = jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn,
    issuer: 'enterprise-app-backend',
    audience: 'enterprise-app-ios'
  });

  const refreshToken = jwt.sign(payload, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshExpiresIn,
    issuer: 'enterprise-app-backend',
    audience: 'enterprise-app-ios'
  });

  return {
    accessToken,
    refreshToken
  };
};

/**
 * Verify and decode JWT access token
 * @param token - JWT token to verify
 * @returns Decoded token payload
 * @throws AppError if token is invalid or expired
 */
export const verifyAccessToken = (token: string): TokenPayload => {
  try {
    const decoded = jwt.verify(token, config.jwt.secret, {
      issuer: 'enterprise-app-backend',
      audience: 'enterprise-app-ios'
    }) as TokenPayload;

    return decoded;
  } catch (error: any) {
    if (error.name === 'TokenExpiredError') {
      throw new AppError('Access token has expired', 401);
    } else if (error.name === 'JsonWebTokenError') {
      throw new AppError('Invalid access token', 401);
    } else if (error.name === 'NotBeforeError') {
      throw new AppError('Access token not active yet', 401);
    } else {
      throw new AppError('Token verification failed', 401);
    }
  }
};

/**
 * Verify and decode JWT refresh token
 * @param token - JWT refresh token to verify
 * @returns Decoded token payload
 * @throws AppError if token is invalid or expired
 */
export const verifyRefreshToken = (token: string): TokenPayload => {
  try {
    const decoded = jwt.verify(token, config.jwt.refreshSecret, {
      issuer: 'enterprise-app-backend',
      audience: 'enterprise-app-ios'
    }) as TokenPayload;

    return decoded;
  } catch (error: any) {
    if (error.name === 'TokenExpiredError') {
      throw new AppError('Refresh token has expired', 401);
    } else if (error.name === 'JsonWebTokenError') {
      throw new AppError('Invalid refresh token', 401);
    } else if (error.name === 'NotBeforeError') {
      throw new AppError('Refresh token not active yet', 401);
    } else {
      throw new AppError('Refresh token verification failed', 401);
    }
  }
};

/**
 * Decode JWT token without verification (for extracting payload)
 * @param token - JWT token to decode
 * @returns Decoded token payload or null
 */
export const decodeToken = (token: string): TokenPayload | null => {
  try {
    return jwt.decode(token) as TokenPayload;
  } catch (error) {
    return null;
  }
};

/**
 * Check if JWT token is expired
 * @param token - JWT token to check
 * @returns True if token is expired, false otherwise
 */
export const isTokenExpired = (token: string): boolean => {
  try {
    const decoded = jwt.decode(token) as TokenPayload;
    if (!decoded || !decoded.exp) return true;

    const currentTime = Math.floor(Date.now() / 1000);
    return decoded.exp < currentTime;
  } catch (error) {
    return true;
  }
};

/**
 * Get token expiry time
 * @param token - JWT token
 * @returns Expiry date or null
 */
export const getTokenExpiry = (token: string): Date | null => {
  try {
    const decoded = jwt.decode(token) as TokenPayload;
    if (!decoded || !decoded.exp) return null;

    return new Date(decoded.exp * 1000);
  } catch (error) {
    return null;
  }
};

/**
 * Extract user ID from JWT token
 * @param token - JWT token
 * @returns User ID or null
 */
export const getUserIdFromToken = (token: string): string | null => {
  try {
    const decoded = jwt.decode(token) as TokenPayload;
    return decoded?.userId || null;
  } catch (error) {
    return null;
  }
};