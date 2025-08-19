import { Request, Response, NextFunction } from 'express';
import { Category } from '@/models/Category';
import { Product } from '@/models/Product';
import { AppError } from '@/utils/AppError';
import { catchAsync } from '@/utils/catchAsync';

/**
 * @swagger
 * /api/categories:
 *   get:
 *     summary: Get all categories
 *     tags: [Categories]
 *     responses:
 *       200:
 *         description: Categories retrieved successfully
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
 *                   example: "Categories retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     categories:
 *                       type: array
 *                       items:
 *                         $ref: '#/components/schemas/Category'
 *                     total:
 *                       type: integer
 *                       description: Total number of categories
 *       500:
 *         description: Internal server error
 */
export const getAllCategories = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const categories = await Category.find({ isActive: true })
    .sort({ productCount: -1, name: 1 })
    .lean();

  // Update product counts for each category
  for (const category of categories) {
    const productCount = await Product.countDocuments({
      category: { $regex: new RegExp(`^${category.name}$`, 'i') },
      isActive: true
    });
    
    if (productCount !== category.productCount) {
      await Category.findByIdAndUpdate(category._id, { productCount });
      category.productCount = productCount;
    }
  }

  res.status(200).json({
    status: 'success',
    message: 'Categories retrieved successfully',
    data: {
      categories: categories.map(category => ({
        ...category,
        id: category._id.toString()
      })),
      total: categories.length
    }
  });
});

/**
 * @swagger
 * /api/categories/{id}:
 *   get:
 *     summary: Get a specific category by ID
 *     tags: [Categories]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Category ID
 *     responses:
 *       200:
 *         description: Category retrieved successfully
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
 *                   example: "Category retrieved successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     category:
 *                       $ref: '#/components/schemas/Category'
 *       404:
 *         description: Category not found
 *       500:
 *         description: Internal server error
 */
export const getCategoryById = catchAsync(async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;

  let category;
  if (id.match(/^[0-9a-fA-F]{24}$/)) {
    // Valid ObjectId
    category = await Category.findOne({ _id: id, isActive: true }).lean();
  } else {
    // Search by name
    category = await Category.findOne({ 
      name: { $regex: new RegExp(`^${id}$`, 'i') },
      isActive: true 
    }).lean();
  }

  if (!category) {
    return next(new AppError('Category not found', 404));
  }

  // Update product count
  const productCount = await Product.countDocuments({
    category: { $regex: new RegExp(`^${category.name}$`, 'i') },
    isActive: true
  });

  if (productCount !== category.productCount) {
    await Category.findByIdAndUpdate(category._id, { productCount });
    category.productCount = productCount;
  }

  res.status(200).json({
    status: 'success',
    message: 'Category retrieved successfully',
    data: {
      category: {
        ...category,
        id: category._id.toString()
      }
    }
  });
});