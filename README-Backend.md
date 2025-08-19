# Enterprise App Backend

## 🚀 Quick Setup

```bash
# Install dependencies (already done)
npm install

# Copy environment variables
cp env.example .env

# Start development server
npm run dev
```

## 📡 API Endpoints

### Base URL: `http://localhost:3000/api`

### Authentication
- `POST /auth/register` - Register user
- `POST /auth/signin` - User login
- `GET /auth/profile` - Get profile (requires auth)

### Products
- `GET /products` - Get all products
- `GET /products/:id` - Get product by ID
- `GET /products/search?q=query` - Search products
- `GET /products/category/:categoryId` - Products by category

### Categories
- `GET /categories` - Get all categories

### Cart (requires authentication)
- `GET /cart` - Get user's cart
- `POST /cart` - Add item to cart
- `PUT /cart/:itemId` - Update cart item
- `DELETE /cart/:itemId` - Remove from cart

## 🧪 Sample Requests

### Register
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Get Products
```bash
curl http://localhost:3000/api/products
```

## 📚 Documentation
Visit http://localhost:3000/api-docs for complete API documentation.

## 🎯 iOS Integration Ready!

This backend matches the data models used in your iOS Enterprise App. All responses include proper JSON structure that the iOS app expects.