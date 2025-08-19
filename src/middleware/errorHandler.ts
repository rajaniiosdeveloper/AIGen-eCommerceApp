import { Request, Response, NextFunction } from 'express';
import { AppError } from '@/utils/AppError';
import { config } from '@/config/environment';

interface ErrorResponse {
  status: string;
  message: string;
  error?: any;
  stack?: string;
}

/**
 * Handle different types of database and validation errors
 */
const handleCastErrorDB = (err: any): AppError => {
  const message = `Invalid ${err.path}: ${err.value}`;
  return new AppError(message, 400);
};

const handleDuplicateFieldsDB = (err: any): AppError => {
  const value = err.errmsg.match(/(["'])(\\?.)*?\1/)[0];
  const message = `Duplicate field value: ${value}. Please use another value!`;
  return new AppError(message, 400);
};

const handleValidationErrorDB = (err: any): AppError => {
  const errors = Object.values(err.errors).map((el: any) => el.message);
  const message = `Invalid input data. ${errors.join('. ')}`;
  return new AppError(message, 400);
};

const handleJWTError = (): AppError =>
  new AppError('Invalid token. Please log in again!', 401);

const handleJWTExpiredError = (): AppError =>
  new AppError('Your token has expired! Please log in again.', 401);

/**
 * Send error response for development environment
 */
const sendErrorDev = (err: any, res: Response) => {
  const errorResponse: ErrorResponse = {
    status: err.status || 'error',
    message: err.message,
    error: err,
    stack: err.stack
  };

  res.status(err.statusCode || 500).json(errorResponse);
};

/**
 * Send error response for production environment
 */
const sendErrorProd = (err: any, res: Response) => {
  // Operational, trusted error: send message to client
  if (err.isOperational) {
    const errorResponse: ErrorResponse = {
      status: err.status,
      message: err.message
    };

    res.status(err.statusCode).json(errorResponse);
  } else {
    // Programming or other unknown error: don't leak error details
    console.error('ERROR 💥', err);

    const errorResponse: ErrorResponse = {
      status: 'error',
      message: 'Something went very wrong!'
    };

    res.status(500).json(errorResponse);
  }
};

/**
 * Global error handling middleware
 * This should be the last middleware in the application
 */
const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  if (config.nodeEnv === 'development') {
    sendErrorDev(err, res);
  } else {
    let error = { ...err };
    error.message = err.message;

    // Handle specific error types
    if (error.name === 'CastError') error = handleCastErrorDB(error);
    if (error.code === 11000) error = handleDuplicateFieldsDB(error);
    if (error.name === 'ValidationError') error = handleValidationErrorDB(error);
    if (error.name === 'JsonWebTokenError') error = handleJWTError();
    if (error.name === 'TokenExpiredError') error = handleJWTExpiredError();

    sendErrorProd(error, res);
  }
};

export default errorHandler;