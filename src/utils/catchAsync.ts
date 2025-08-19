import { Request, Response, NextFunction } from 'express';

/**
 * Higher-order function to catch async errors and pass them to Express error handler
 * This eliminates the need for try-catch blocks in every async route handler
 * 
 * @param fn - Async function to wrap
 * @returns Express middleware function
 */
export const catchAsync = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    fn(req, res, next).catch(next);
  };
};