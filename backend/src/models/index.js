import connection from "../db/db.js";
import User from "./auth.model.js";
import Category from "./category.model.js";
import Notification from "./notification.model.js";
import Product from "./product.model.js";
import Wishlist from "./wishlist.model.js";

const db = {
  connection,
  User,
  Category,
  Product,
  Notification,
  Wishlist,
};

Category.hasMany(Product, {
  foreignKey: "categoryId",
  as: "products",
});

Product.belongsTo(Category, {
  foreignKey: "categoryId",
  as: "category",
});

User.hasMany(Wishlist, {
  foreignKey: "userId",
  as: "wishlists",
  onDelete: "CASCADE",
});

Wishlist.belongsTo(User, {
  foreignKey: "userId",
  as: "user",
});

Product.hasMany(Wishlist, {
  foreignKey: "productId",
  as: "wishlists",
  onDelete: "CASCADE",
});

Wishlist.belongsTo(Product, {
  foreignKey: "productId",
  as: "product",
});
export default db;
