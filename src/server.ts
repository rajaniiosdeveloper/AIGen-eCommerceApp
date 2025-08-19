import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'success',
    message: 'Enterprise App Backend is running!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// API Routes
app.get('/api/test', (req, res) => {
  res.json({
    status: 'success',
    message: 'API is working! Ready for iOS integration.',
    endpoints: {
      products: '/api/products',
      auth: '/api/auth',
      cart: '/api/cart',
      categories: '/api/categories'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`
🚀 Enterprise App Backend Started!
📱 iOS eCommerce API is running on port ${PORT}
🌍 Health Check: http://localhost:${PORT}/health
🎯 Test API: http://localhost:${PORT}/api/test
⚡ Ready for iOS app integration!
  `);
});

export default app;