const express = require('express');
const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  next();
});

// Mock Data
const users = [
  { id: "1", name: "John Doe", email: "john@example.com", password: "password123" },
  { id: "2", name: "Jane Smith", email: "jane@example.com", password: "password123" }
];

const products = [
  {
    id: "1",
    title: "iPhone 15 Pro Max",
    description: "Latest flagship smartphone with advanced A17 Pro chip, titanium design, and professional camera system with 5x telephoto zoom.",
    shortDescription: "Latest iPhone with advanced camera",
    price: 1199.99,
    imageURL: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400",
    category: "Electronics",
    rating: 4.8,
    stock: 25,
    brand: "Apple"
  },
  {
    id: "2",
    title: "MacBook Pro 16-inch",
    description: "Powerful laptop with M3 Max chip, Liquid Retina XDR display, and up to 22 hours of battery life.",
    shortDescription: "Powerful laptop with M3 Max chip",
    price: 2499.99,
    imageURL: "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400",
    category: "Electronics",
    rating: 4.9,
    stock: 15,
    brand: "Apple"
  },
  {
    id: "3",
    title: "Nike Air Jordan 1 Retro High",
    description: "Classic basketball shoes with premium leather upper and iconic design that started it all.",
    shortDescription: "Classic basketball shoes",
    price: 179.99,
    imageURL: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400",
    category: "Fashion",
    rating: 4.6,
    stock: 60,
    brand: "Nike"
  },
  {
    id: "4",
    title: "Sony WH-1000XM5 Headphones",
    description: "Industry-leading noise canceling headphones with exceptional sound quality and 30-hour battery life.",
    shortDescription: "Noise canceling headphones",
    price: 399.99,
    imageURL: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400",
    category: "Electronics",
    rating: 4.7,
    stock: 40,
    brand: "Sony"
  }
];

const categories = [
  { id: "1", name: "Electronics", imageURL: "https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400", productCount: 3 },
  { id: "2", name: "Fashion", imageURL: "https://images.unsplash.com/photo-1445205170230-053b83016050?w=400", productCount: 1 },
  { id: "3", name: "Home & Garden", imageURL: "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400", productCount: 0 },
  { id: "4", name: "Sports", imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400", productCount: 0 }
];

const orders = [
  {
    id: "1",
    userId: "1",
    items: [
      {
        id: "1",
        productId: "1",
        productTitle: "iPhone 15 Pro Max",
        productImageURL: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400",
        quantity: 1,
        unitPrice: 1199.99,
        totalPrice: 1199.99
      }
    ],
    totalAmount: 1199.99,
    status: "delivered",
    orderDate: "2025-08-01T10:30:00.000Z",
    deliveryDate: "2025-08-05T14:20:00.000Z",
    shippingAddress: "123 Main St, City, State 12345"
  },
  {
    id: "2",
    userId: "1",
    items: [
      {
        id: "2",
        productId: "3",
        productTitle: "Nike Air Jordan 1 Retro High",
        productImageURL: "https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400",
        quantity: 2,
        unitPrice: 179.99,
        totalPrice: 359.98
      }
    ],
    totalAmount: 359.98,
    status: "shipped",
    orderDate: "2025-08-05T15:45:00.000Z",
    deliveryDate: null,
    shippingAddress: "123 Main St, City, State 12345"
  }
];

// Helper functions
const formatPrice = (price) => `₹${price.toFixed(2)}`;
const generateToken = () => 'jwt_token_' + Math.random().toString(36).substr(2, 9);

// ===== AUTHENTICATION ENDPOINTS =====

// Register
app.post('/api/auth/register', (req, res) => {
  const { name, email, password } = req.body;
  
  if (!name || !email || !password) {
    return res.status(400).json({
      status: 'fail',
      message: 'Name, email, and password are required'
    });
  }
  
  const existingUser = users.find(u => u.email === email);
  if (existingUser) {
    return res.status(400).json({
      status: 'fail',
      message: 'User with this email already exists'
    });
  }
  
  const newUser = {
    id: (users.length + 1).toString(),
    name,
    email,
    password
  };
  users.push(newUser);
  
  res.status(201).json({
    status: 'success',
    message: 'User registered successfully',
    data: {
      user: { id: newUser.id, name: newUser.name, email: newUser.email },
      token: generateToken(),
      refreshToken: generateToken(),
      expiresIn: 604800
    }
  });
});

// Login
app.post('/api/auth/signin', (req, res) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({
      status: 'fail',
      message: 'Email and password are required'
    });
  }
  
  const user = users.find(u => u.email === email && u.password === password);
  if (!user) {
    return res.status(401).json({
      status: 'fail',
      message: 'Invalid email or password'
    });
  }
  
  res.json({
    status: 'success',
    message: 'User signed in successfully',
    data: {
      user: { id: user.id, name: user.name, email: user.email },
      token: generateToken(),
      refreshToken: generateToken(),
      expiresIn: 604800
    }
  });
});

// Get Profile
app.get('/api/auth/profile', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'fail',
      message: 'Authentication token required'
    });
  }
  
  // Mock user (in real app, decode JWT)
  const user = users[0];
  res.json({
    status: 'success',
    message: 'User profile retrieved successfully',
    data: {
      user: { id: user.id, name: user.name, email: user.email }
    }
  });
});

// ===== PRODUCT ENDPOINTS =====

// Get All Products
app.get('/api/products', (req, res) => {
  const { category, search, page = 1, limit = 20 } = req.query;
  let filteredProducts = [...products];
  
  if (category) {
    filteredProducts = filteredProducts.filter(p => 
      p.category.toLowerCase().includes(category.toLowerCase())
    );
  }
  
  if (search) {
    filteredProducts = filteredProducts.filter(p => 
      p.title.toLowerCase().includes(search.toLowerCase()) ||
      p.description.toLowerCase().includes(search.toLowerCase())
    );
  }
  
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + parseInt(limit);
  const paginatedProducts = filteredProducts.slice(startIndex, endIndex);
  
  res.json({
    status: 'success',
    message: 'Products retrieved successfully',
    data: {
      products: paginatedProducts.map(p => ({
        ...p,
        formattedPrice: formatPrice(p.price),
        isInStock: p.stock > 0
      })),
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(filteredProducts.length / limit),
        totalProducts: filteredProducts.length,
        hasNextPage: endIndex < filteredProducts.length,
        hasPrevPage: page > 1,
        limit: parseInt(limit)
      }
    }
  });
});

// Get Product by ID
app.get('/api/products/:id', (req, res) => {
  const product = products.find(p => p.id === req.params.id);
  if (!product) {
    return res.status(404).json({
      status: 'fail',
      message: 'Product not found'
    });
  }
  
  res.json({
    status: 'success',
    message: 'Product retrieved successfully',
    data: {
      product: {
        ...product,
        formattedPrice: formatPrice(product.price),
        isInStock: product.stock > 0
      }
    }
  });
});

// Search Products
app.get('/api/products/search', (req, res) => {
  const { q } = req.query;
  if (!q) {
    return res.status(400).json({
      status: 'fail',
      message: 'Search query is required'
    });
  }
  
  const searchResults = products.filter(p => 
    p.title.toLowerCase().includes(q.toLowerCase()) ||
    p.description.toLowerCase().includes(q.toLowerCase()) ||
    p.brand.toLowerCase().includes(q.toLowerCase())
  );
  
  res.json({
    status: 'success',
    message: 'Search results retrieved successfully',
    data: {
      products: searchResults.map(p => ({
        ...p,
        formattedPrice: formatPrice(p.price),
        isInStock: p.stock > 0
      })),
      searchQuery: q
    }
  });
});

// Get Products by Category
app.get('/api/products/category/:categoryId', (req, res) => {
  const { categoryId } = req.params;
  const category = categories.find(c => c.id === categoryId || c.name.toLowerCase() === categoryId.toLowerCase());
  
  if (!category) {
    return res.status(404).json({
      status: 'fail',
      message: 'Category not found'
    });
  }
  
  const categoryProducts = products.filter(p => 
    p.category.toLowerCase() === category.name.toLowerCase()
  );
  
  res.json({
    status: 'success',
    message: 'Products retrieved successfully',
    data: {
      products: categoryProducts.map(p => ({
        ...p,
        formattedPrice: formatPrice(p.price),
        isInStock: p.stock > 0
      })),
      category
    }
  });
});

// ===== CATEGORY ENDPOINTS =====

// Get All Categories
app.get('/api/categories', (req, res) => {
  res.json({
    status: 'success',
    message: 'Categories retrieved successfully',
    data: {
      categories,
      total: categories.length
    }
  });
});

// ===== ORDER ENDPOINTS =====

// Get User Orders
app.get('/api/orders', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'fail',
      message: 'Authentication token required'
    });
  }
  
  const userOrders = orders.map(order => ({
    ...order,
    formattedTotal: formatPrice(order.totalAmount),
    formattedOrderDate: new Date(order.orderDate).toLocaleDateString('en-IN'),
    itemCount: order.items.reduce((total, item) => total + item.quantity, 0)
  }));
  
  res.json({
    status: 'success',
    message: 'Orders retrieved successfully',
    data: {
      orders: userOrders,
      total: userOrders.length
    }
  });
});

// Get Order by ID
app.get('/api/orders/:orderId', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'fail',
      message: 'Authentication token required'
    });
  }
  
  const order = orders.find(o => o.id === req.params.orderId);
  if (!order) {
    return res.status(404).json({
      status: 'fail',
      message: 'Order not found'
    });
  }
  
  res.json({
    status: 'success',
    message: 'Order retrieved successfully',
    data: {
      order: {
        ...order,
        formattedTotal: formatPrice(order.totalAmount),
        formattedOrderDate: new Date(order.orderDate).toLocaleDateString('en-IN'),
        itemCount: order.items.reduce((total, item) => total + item.quantity, 0)
      }
    }
  });
});

// Create Order
app.post('/api/orders', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'fail',
      message: 'Authentication token required'
    });
  }
  
  const { items, shippingAddress } = req.body;
  if (!items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({
      status: 'fail',
      message: 'Order items are required'
    });
  }
  
  const totalAmount = items.reduce((total, item) => total + (item.unitPrice * item.quantity), 0);
  
  const newOrder = {
    id: (orders.length + 1).toString(),
    userId: "1", // Mock user ID
    items: items.map(item => ({
      id: Math.random().toString(36).substr(2, 9),
      ...item,
      totalPrice: item.unitPrice * item.quantity
    })),
    totalAmount,
    status: "pending",
    orderDate: new Date().toISOString(),
    deliveryDate: null,
    shippingAddress: shippingAddress || "123 Main St, City, State 12345"
  };
  
  orders.push(newOrder);
  
  res.status(201).json({
    status: 'success',
    message: 'Order created successfully',
    data: {
      order: {
        ...newOrder,
        formattedTotal: formatPrice(newOrder.totalAmount),
        formattedOrderDate: new Date(newOrder.orderDate).toLocaleDateString('en-IN')
      }
    }
  });
});

// ===== CART ENDPOINTS =====

// Get Cart (Mock - in real app would be stored in DB)
app.get('/api/cart', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'fail',
      message: 'Authentication token required'
    });
  }
  
  // Mock cart data
  const cartItems = [
    {
      id: "cart1",
      userId: "1",
      productId: "1",
      quantity: 1,
      dateAdded: new Date().toISOString(),
      product: products[0],
      totalPrice: products[0].price,
      formattedTotalPrice: formatPrice(products[0].price)
    }
  ];
  
  const totalAmount = cartItems.reduce((sum, item) => sum + item.totalPrice, 0);
  const totalItems = cartItems.reduce((sum, item) => sum + item.quantity, 0);
  
  res.json({
    status: 'success',
    message: 'Cart retrieved successfully',
    data: {
      items: cartItems,
      totalAmount,
      totalItems,
      formattedTotalAmount: formatPrice(totalAmount)
    }
  });
});

// Add to Cart
app.post('/api/cart', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: 'fail',
      message: 'Authentication token required'
    });
  }
  
  const { productId, quantity = 1 } = req.body;
  if (!productId) {
    return res.status(400).json({
      status: 'fail',
      message: 'Product ID is required'
    });
  }
  
  const product = products.find(p => p.id === productId);
  if (!product) {
    return res.status(404).json({
      status: 'fail',
      message: 'Product not found'
    });
  }
  
  res.status(201).json({
    status: 'success',
    message: 'Item added to cart successfully',
    data: {
      cartItem: {
        id: Math.random().toString(36).substr(2, 9),
        userId: "1",
        productId,
        quantity,
        dateAdded: new Date().toISOString()
      }
    }
  });
});

// ===== BASIC ENDPOINTS =====

// Health Check
app.get('/health', (req, res) => {
  res.json({
    status: 'success',
    message: 'Enterprise App Backend is running!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// API Test
app.get('/api/test', (req, res) => {
  res.json({
    status: 'success',
    message: 'Complete eCommerce API is working!',
    availableEndpoints: {
      auth: ['/api/auth/register', '/api/auth/signin', '/api/auth/profile'],
      products: ['/api/products', '/api/products/:id', '/api/products/search', '/api/products/category/:categoryId'],
      categories: ['/api/categories'],
      orders: ['/api/orders', '/api/orders/:orderId'],
      cart: ['/api/cart']
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`
🚀 Complete Enterprise eCommerce Backend Started!
📱 All iOS APIs ready on port ${PORT}
🌍 Health Check: http://localhost:${PORT}/health
🎯 Test API: http://localhost:${PORT}/api/test
📚 Complete API Documentation ready!
⚡ Ready for full iOS integration!
  `);
});

module.exports = app;