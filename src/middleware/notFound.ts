import { Request, Response, NextFunction } from 'express';
import { AppError } from '@/utils/AppError';

/**
 * 404 Not Found middleware
 * This middleware should be placed after all route definitions
 * but before the error handling middleware
 */
export const notFound = (req: Request, res: Response, next: NextFunction) => {
  const message = `Cannot ${req.method} ${req.originalUrl} on this server`;
  next(new AppError(message, 404));
};