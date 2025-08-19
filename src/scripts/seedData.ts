import mongoose from 'mongoose';
import { config } from '@/config/environment';
import { Product } from '@/models/Product';
import { Category } from '@/models/Category';
import { User } from '@/models/User';

const sampleCategories = [
  { name: 'Electronics', imageURL: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400', productCount: 0 },
  { name: 'Fashion', imageURL: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400', productCount: 0 },
  { name: 'Home & Garden', imageURL: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400', productCount: 0 },
  { name: 'Sports', imageURL: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400', productCount: 0 },
  { name: 'Books', imageURL: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400', productCount: 0 }
];

const sampleProducts = [
  {
    title: 'iPhone 15 Pro Max',
    description: 'Latest flagship smartphone with advanced A17 Pro chip, titanium design, and professional camera system with 5x telephoto zoom.',
    price: 1199.99,
    imageURL: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
    category: 'Electronics',
    rating: 4.8,
    stock: 25,
    brand: 'Apple'
  },
  {
    title: 'MacBook Pro 16-inch',
    description: 'Powerful laptop with M3 Max chip, Liquid Retina XDR display, and up to 22 hours of battery life.',
    price: 2499.99,
    imageURL: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400',
    category: 'Electronics',
    rating: 4.9,
    stock: 15,
    brand: 'Apple'
  },
  {
    title: 'Sony WH-1000XM5 Headphones',
    description: 'Industry-leading noise canceling headphones with exceptional sound quality and 30-hour battery life.',
    price: 399.99,
    imageURL: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
    category: 'Electronics',
    rating: 4.7,
    stock: 40,
    brand: 'Sony'
  },
  {
    title: 'Nike Air Jordan 1 Retro High',
    description: 'Classic basketball shoes with premium leather upper and iconic design that started it all.',
    price: 179.99,
    imageURL: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400',
    category: 'Fashion',
    rating: 4.6,
    stock: 60,
    brand: 'Nike'
  },
  {
    title: 'Adidas Ultraboost 22',
    description: 'High-performance running shoes with responsive Boost midsole and Primeknit upper.',
    price: 189.99,
    imageURL: 'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=400',
    category: 'Sports',
    rating: 4.5,
    stock: 45,
    brand: 'Adidas'
  },
  {
    title: 'The Design of Everyday Things',
    description: 'Essential book on design principles and user experience by Don Norman.',
    price: 24.99,
    imageURL: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
    category: 'Books',
    rating: 4.7,
    stock: 100,
    brand: 'Basic Books'
  },
  {
    title: 'Smart Coffee Maker',
    description: 'WiFi-enabled coffee maker with app control, multiple brewing options, and thermal carafe.',
    price: 299.99,
    imageURL: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
    category: 'Home & Garden',
    rating: 4.4,
    stock: 30,
    brand: 'Breville'
  },
  {
    title: 'Yoga Mat Premium',
    description: 'Non-slip yoga mat with extra cushioning and alignment markers for perfect practice.',
    price: 79.99,
    imageURL: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
    category: 'Sports',
    rating: 4.3,
    stock: 80,
    brand: 'Manduka'
  },
  {
    title: 'Wireless Charging Pad',
    description: 'Fast wireless charger compatible with all Qi-enabled devices, sleek design.',
    price: 49.99,
    imageURL: 'https://images.unsplash.com/photo-1586953208448-b95a79798f07?w=400',
    category: 'Electronics',
    rating: 4.2,
    stock: 120,
    brand: 'Anker'
  },
  {
    title: 'Premium Cotton T-Shirt',
    description: 'Soft, comfortable, and sustainable cotton t-shirt in various colors.',
    price: 29.99,
    imageURL: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
    category: 'Fashion',
    rating: 4.1,
    stock: 200,
    brand: 'Uniqlo'
  }
];

const sampleUsers = [
  {
    name: 'John Doe',
    email: 'john@example.com',
    password: 'password123'
  },
  {
    name: 'Jane Smith',
    email: 'jane@example.com',
    password: 'password123'
  }
];

const seedDatabase = async () => {
  try {
    console.log('🌱 Starting database seeding...');
    
    // Connect to database
    await mongoose.connect(config.mongodb.uri);
    console.log('📦 Connected to MongoDB');

    // Clear existing data
    await Promise.all([
      Product.deleteMany({}),
      Category.deleteMany({}),
      User.deleteMany({})
    ]);
    console.log('🧹 Cleared existing data');

    // Seed categories
    const categories = await Category.create(sampleCategories);
    console.log(`📂 Created ${categories.length} categories`);

    // Seed products
    const products = await Product.create(sampleProducts);
    console.log(`📱 Created ${products.length} products`);

    // Update category product counts
    for (const category of categories) {
      const productCount = await Product.countDocuments({ 
        category: category.name,
        isActive: true 
      });
      await Category.findByIdAndUpdate(category._id, { productCount });
    }
    console.log('🔄 Updated category product counts');

    // Seed users
    const users = await User.create(sampleUsers);
    console.log(`👥 Created ${users.length} users`);

    console.log('✅ Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   Categories: ${categories.length}`);
    console.log(`   Products: ${products.length}`);
    console.log(`   Users: ${users.length}`);
    console.log('\n🔐 Test Users:');
    sampleUsers.forEach(user => {
      console.log(`   Email: ${user.email} | Password: ${user.password}`);
    });
    
  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    await mongoose.disconnect();
    console.log('📦 Disconnected from MongoDB');
    process.exit(0);
  }
};

// Run seeding if this file is executed directly
if (require.main === module) {
  seedDatabase();
}

export { seedDatabase };