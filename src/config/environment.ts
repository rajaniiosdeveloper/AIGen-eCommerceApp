import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

interface Config {
  port: number;
  nodeEnv: string;
  mongodb: {
    uri: string;
    testUri: string;
  };
  jwt: {
    secret: string;
    expiresIn: string;
    refreshSecret: string;
    refreshExpiresIn: string;
  };
  cors: {
    origin: string;
  };
  rateLimit: {
    windowMs: number;
    maxRequests: number;
  };
  payment: {
    providerUrl: string;
    key: string;
    secret: string;
  };
  socketIO: {
    corsOrigin: string;
  };
  upload: {
    maxFileSize: number;
    path: string;
  };
  email?: {
    service: string;
    user: string;
    pass: string;
  };
  logging: {
    level: string;
    file: string;
  };
  redis?: {
    url: string;
  };
}

const requiredEnvVars = [
  'JWT_SECRET',
  'MONGODB_URI'
];

// Check for required environment variables
const missingEnvVars = requiredEnvVars.filter(envVar => !process.env[envVar]);
if (missingEnvVars.length > 0) {
  throw new Error(`Missing required environment variables: ${missingEnvVars.join(', ')}`);
}

export const config: Config = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  
  mongodb: {
    uri: process.env.MONGODB_URI!,
    testUri: process.env.MONGODB_TEST_URI || 'mongodb://localhost:27017/enterprise_app_test_db'
  },
  
  jwt: {
    secret: process.env.JWT_SECRET!,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    refreshSecret: process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET + '_refresh',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d'
  },
  
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000'
  },
  
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10), // 15 minutes
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10)
  },
  
  payment: {
    providerUrl: process.env.PAYMENT_PROVIDER_URL || 'https://dummy-payment-api.com',
    key: process.env.PAYMENT_PROVIDER_KEY || 'dummy_payment_key',
    secret: process.env.PAYMENT_PROVIDER_SECRET || 'dummy_payment_secret'
  },
  
  socketIO: {
    corsOrigin: process.env.SOCKET_IO_CORS_ORIGIN || '*'
  },
  
  upload: {
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE || '5242880', 10), // 5MB
    path: process.env.UPLOAD_PATH || 'uploads/'
  },
  
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    file: process.env.LOG_FILE || 'logs/app.log'
  }
};

// Add optional configurations
if (process.env.EMAIL_SERVICE && process.env.EMAIL_USER && process.env.EMAIL_PASS) {
  config.email = {
    service: process.env.EMAIL_SERVICE,
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  };
}

if (process.env.REDIS_URL) {
  config.redis = {
    url: process.env.REDIS_URL
  };
}

// Validate configuration
if (config.port < 1 || config.port > 65535) {
  throw new Error('PORT must be a valid port number between 1 and 65535');
}

if (!['development', 'production', 'test'].includes(config.nodeEnv)) {
  throw new Error('NODE_ENV must be one of: development, production, test');
}

// Log configuration in development
if (config.nodeEnv === 'development') {
  console.log('📋 Configuration loaded:');
  console.log(`   Port: ${config.port}`);
  console.log(`   Environment: ${config.nodeEnv}`);
  console.log(`   Database: ${config.mongodb.uri.replace(/\/\/.*@/, '//***:***@')}`);
  console.log(`   JWT Secret: ${config.jwt.secret.substring(0, 10)}...`);
  console.log(`   CORS Origin: ${config.cors.origin}`);
  console.log(`   Rate Limit: ${config.rateLimit.maxRequests} requests per ${config.rateLimit.windowMs}ms`);
}