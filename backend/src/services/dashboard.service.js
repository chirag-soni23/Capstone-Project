import db from "../models/index.js";

export const getDashboardService = async () => {
  const [totalProducts, totalCategories, totalUsers] =
    await Promise.all([
      db.Product.count(),
      db.Category.count(),
      db.User.count(),
    ]);

  return {
    totalProducts,
    totalCategories,
    totalUsers,
  };
};

// Get all normal users
export const getDashboardUsersService = async () => {
  const users = await db.User.findAll({
    where: {
      role: "user",
    },
    attributes: ["id", "name", "email"],
    order: [["createdAt", "DESC"]],
  });

  return users;
};