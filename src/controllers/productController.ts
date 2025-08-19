import { Request, Response, NextFunction } from 'express';
import { Product } from '@/models/Product';
import { Category } from '@/models/Category';
import { AppError } from '@/utils/AppError';
import { catchAsync } from '@/utils/catchAsync';
import { io } from '@/server';

interface ProductQuery {
  page?: string;
  limit?: string;
  category?: string;
  search?: string;
  minPrice?: string;
  maxPrice?: string;
  brand?: string;
  minRating?: string;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

/**
 * @swagger
 * /api/products:
 *   get:
 *     summary: Get all products with optional filtering and pagination
 *     tags: [Products]
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: Page number for pagination
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *         description: Number of products per page
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *         description: Filter by category name
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search in product title and description
 *       - in: query
 *         name: minPrice
 *         schema:
 *           type: number
 *           minimum: 0
 *         description: Minimum price filter
 *       - in: query
 *         name: maxPrice
 *         schema:
 *           type: number
 *           minimum: 0
 *         description: Maximum price filter
 *       - in: query
 *         name: brand
 *         schema:
 *           type: string
 *         description: Filter by brand name
 *       - in: query
 *         name: minRating
 *         schema:
 *           type: number
 *           minimum: 0
 *           maximum: 5
 *         description: Minimum rating filter
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [title, price, rating, createdAt, stock]
 *           default: createdAt
 *         description: Field to sort by
 *       - in: query
 *         name: sortOrder
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *         description: Sort order
 *     responses:
 *       200:
 *         description: Products retrieved successfully
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
 *                   example: "Products retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     products:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Product'
 *                     pagination:
 *                       type: object
 *                       properties:
 *                         currentPage:
 *                           type: integer
 *                         totalPages:
 *                           type: integer
 *                         totalProducts:
 *                           type: integer
 *                         hasNextPage:
 *                           type: boolean
 *                         hasPrevPage:
 *                           type: boolean
 *       500:
 *         description: Internal server error
 */
export const getAllProducts = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const {
    page = '1',
    limit = '20',
    category,
    search,
    minPrice,
    maxPrice,
    brand,
    minRating,
    sortBy = 'createdAt',
    sortOrder = 'desc'
  }: ProductQuery = req.query;

  const pageNumber = Math.max(1, parseInt(page));
  const limitNumber = Math.min(100, Math.max(1, parseInt(limit)));
  const skip = (pageNumber - 1) * limitNumber;

  // Build query
  const query: any = { isActive: true };

  if (category) {
    query.category = { $regex: new RegExp(category, 'i') };
  }

  if (search) {
    query.$or = [
      { title: { $regex: new RegExp(search, 'i') } },
      { description: { $regex: new RegExp(search, 'i') } },
      { brand: { $regex: new RegExp(search, 'i') } }
    ];
  }

  if (minPrice || maxPrice) {
    query.price = {};
    if (minPrice) query.price.$gte = parseFloat(minPrice);
    if (maxPrice) query.price.$lte = parseFloat(maxPrice);
  }

  if (brand) {
    query.brand = { $regex: new RegExp(brand, 'i') };
  }

  if (minRating) {
    query.rating = { $gte: parseFloat(minRating) };
  }

  // Build sort
  const sort: any = {};
  const validSortFields = ['title', 'price', 'rating', 'createdAt', 'stock'];
  const sortField = validSortFields.includes(sortBy) ? sortBy : 'createdAt';
  sort[sortField] = sortOrder === 'asc' ? 1 : -1;

  // Execute queries
  const [products, totalProducts] = await Promise.all([
    Product.find(query)
      .sort(sort)
      .skip(skip)
      .limit(limitNumber)
      .lean(),
    Product.countDocuments(query)
  ]);

  // Calculate pagination info
  const totalPages = Math.ceil(totalProducts / limitNumber);
  const hasNextPage = pageNumber < totalPages;
  const hasPrevPage = pageNumber > 1;

  res.status(200).json({
    status: 'success',
    message: 'Products retrieved successfully',
    data: {
      products: products.map(product => ({
        ...product,
        id: product._id.toString(),
        formattedPrice: `₹${product.price.toFixed(2)}`,
        isInStock: product.stock > 0
      })),
      pagination: {
        currentPage: pageNumber,
        totalPages,
        totalProducts,
        hasNextPage,
        hasPrevPage,
        limit: limitNumber
      }
    }
  });
});

/**
 * @swagger
 * /api/products/{id}:
 *   get:
 *     summary: Get a specific product by ID
 *     tags: [Products]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Product ID
 *     responses:
 *       200:
 *         description: Product retrieved successfully
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
 *                   example: "Product retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     product:
 *                       $ref: '#/components/schemas/Product'
 *       404:
 *         description: Product not found
 *       500:
 *         description: Internal server error
 */
export const getProductById = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  const product = await Product.findOne({ _id: id, isActive: true }).lean();

  if (!product) {
    return next(new AppError('Product not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Product retrieved successfully',
    data: {
      product: {
        ...product,
        id: product._id.toString(),
        formattedPrice: `₹${product.price.toFixed(2)}`,
        isInStock: product.stock > 0
      }
    }
  });
});

/**
 * @swagger
 * /api/products/category/{categoryId}:
 *   get:
 *     summary: Get products by category ID
 *     tags: [Products]
 *     parameters:
 *       - in: path
 *         name: categoryId
 *         required: true
 *         schema:
 *           type: string
 *         description: Category ID or name
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *     responses:
 *       200:
 *         description: Products retrieved successfully
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
 *                   example: "Products retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     products:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Product'
 *                     category:
 *                       $ref: '#/components/schemas/Category'
 *                     pagination:
 *                       type: object
 *       404:
 *         description: Category not found
 *       500:
 *         description: Internal server error
 */
export const getProductsByCategory = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { categoryId } = req.params;
  const { page = '1', limit = '20' } = req.query;

  const pageNumber = Math.max(1, parseInt(page as string));
  const limitNumber = Math.min(100, Math.max(1, parseInt(limit as string)));
  const skip = (pageNumber - 1) * limitNumber;

  // Find category (by ID or name)
  let category;
  if (categoryId.match(/^[0-9a-fA-F]{24}$/)) {
    // Valid ObjectId
    category = await Category.findOne({ _id: categoryId, isActive: true });
  } else {
    // Search by name
    category = await Category.findOne({ 
      name: { $regex: new RegExp(`^${categoryId}$`, 'i') }, 
      isActive: true 
    });
  }

  if (!category) {
    return next(new AppError('Category not found', 404));
  }

  // Find products in this category
  const query = {
    category: { $regex: new RegExp(`^${category.name}$`, 'i') },
    isActive: true,
    stock: { $gt: 0 }
  };

  const [products, totalProducts] = await Promise.all([
    Product.find(query)
      .sort({ rating: -1, createdAt: -1 })
      .skip(skip)
      .limit(limitNumber)
      .lean(),
    Product.countDocuments(query)
  ]);

  const totalPages = Math.ceil(totalProducts / limitNumber);

  res.status(200).json({
    status: 'success',
    message: 'Products retrieved successfully',
    data: {
      products: products.map(product => ({
        ...product,
        id: product._id.toString(),
        formattedPrice: `₹${product.price.toFixed(2)}`,
        isInStock: product.stock > 0
      })),
      category: {
        ...category.toObject(),
        id: category.id
      },
      pagination: {
        currentPage: pageNumber,
        totalPages,
        totalProducts,
        hasNextPage: pageNumber < totalPages,
        hasPrevPage: pageNumber > 1,
        limit: limitNumber
      }
    }
  });
});

/**
 * @swagger
 * /api/products/search:
 *   get:
 *     summary: Search products
 *     tags: [Products]
 *     parameters:
 *       - in: query
 *         name: q
 *         required: true
 *         schema:
 *           type: string
 *         description: Search query
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *     responses:
 *       200:
 *         description: Search results retrieved successfully
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
 *                   example: "Search results retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     products:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Product'
 *                     searchQuery:
 *                       type: string
 *                     pagination:
 *                       type: object
 *       400:
 *         description: Search query is required
 *       500:
 *         description: Internal server error
 */
export const searchProducts = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { q: query, page = '1', limit = '20' } = req.query;

  if (!query || typeof query !== 'string') {
    return next(new AppError('Search query is required', 400));
  }

  const pageNumber = Math.max(1, parseInt(page as string));
  const limitNumber = Math.min(100, Math.max(1, parseInt(limit as string)));
  const skip = (pageNumber - 1) * limitNumber;

  // Build search query
  const searchQuery = {
    $and: [
      { isActive: true },
      { stock: { $gt: 0 } },
      {
        $or: [
          { title: { $regex: new RegExp(query, 'i') } },
          { description: { $regex: new RegExp(query, 'i') } },
          { brand: { $regex: new RegExp(query, 'i') } },
          { category: { $regex: new RegExp(query, 'i') } }
        ]
      }
    ]
  };

  const [products, totalProducts] = await Promise.all([
    Product.find(searchQuery)
      .sort({ rating: -1, createdAt: -1 })
      .skip(skip)
      .limit(limitNumber)
      .lean(),
    Product.countDocuments(searchQuery)
  ]);

  const totalPages = Math.ceil(totalProducts / limitNumber);

  res.status(200).json({
    status: 'success',
    message: 'Search results retrieved successfully',
    data: {
      products: products.map(product => ({
        ...product,
        id: product._id.toString(),
        formattedPrice: `₹${product.price.toFixed(2)}`,
        isInStock: product.stock > 0
      })),
      searchQuery: query,
      pagination: {
        currentPage: pageNumber,
        totalPages,
        totalProducts,
        hasNextPage: pageNumber < totalPages,
        hasPrevPage: pageNumber > 1,
        limit: limitNumber
      }
    }
  });
});

/**
 * @swagger
 * /api/products/featured:
 *   get:
 *     summary: Get featured products (high rating, in stock)
 *     tags: [Products]
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 50
 *           default: 10
 *         description: Number of featured products to return
 *     responses:
 *       200:
 *         description: Featured products retrieved successfully
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
 *                   example: "Featured products retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     products:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Product'
 *       500:
 *         description: Internal server error
 */
export const getFeaturedProducts = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { limit = '10' } = req.query;
  const limitNumber = Math.min(50, Math.max(1, parseInt(limit as string)));

  const products = await Product.find({
    isActive: true,
    stock: { $gt: 0 },
    rating: { $gte: 4 }
  })
    .sort({ rating: -1, stock: -1 })
    .limit(limitNumber)
    .lean();

  res.status(200).json({
    status: 'success',
    message: 'Featured products retrieved successfully',
    data: {
      products: products.map(product => ({
        ...product,
        id: product._id.toString(),
        formattedPrice: `₹${product.price.toFixed(2)}`,
        isInStock: product.stock > 0
      }))
    }
  });
});

// Real-time product updates (for stock changes, price updates, etc.)
export const notifyProductUpdate = (productId: string, updateType: 'stock' | 'price' | 'availability') => {
  io.emit('product-update', {
    productId,
    updateType,
    timestamp: new Date().toISOString()
  });
};