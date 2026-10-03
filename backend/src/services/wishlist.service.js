import { Op } from "sequelize";
import db from "../models/index.js";
import ApiError from "../utils/apiResponse.js";

// Add wishlist
export const addWishlistService = async ({
  userId,
  productId,
}) => {
  if (!productId) {
    throw ApiError.BADREQUEST("Product ID is required");
  }

  const product = await db.Product.findByPk(productId);

  if (!product) {
    throw ApiError.NOTFOUND("Product not found");
  }

  const existingWishlist = await db.Wishlist.findOne({
    where: {
      userId,
      productId,
    },
  });

  if (existingWishlist) {
    throw ApiError.CONFLICT(
      "Product already exists in wishlist",
    );
  }

  const wishlist = await db.Wishlist.create({
    userId,
    productId,
  });

  return wishlist;
};

// Get my wishlist
export const getMyWishlistService = async (userId) => {
  try {
    const wishlists = await db.Wishlist.findAll({
      where: {
        userId,
      },
      include: [
        {
          model: db.Product,
          as: "product",
          include: [
            {
              model: db.Category,
              as: "category",
              attributes: ["id", "name"],
            },
          ],
        },
      ],
      order: [["createdAt", "DESC"]],
    });

    return wishlists;
  } catch (error) {
    console.error("GET WISHLIST SERVICE ERROR:", error);
    throw error;
  }
};

// Remove wishlist
export const removeWishlistService = async ({
  userId,
  productId,
}) => {
  if (!productId) {
    throw ApiError.BADREQUEST("Product ID is required");
  }

  const wishlist = await db.Wishlist.findOne({
    where: {
      userId,
      productId,
    },
  });

  if (!wishlist) {
    throw ApiError.NOTFOUND(
      "Product not found in wishlist",
    );
  }

  await wishlist.destroy();

  return true;
};

// Check wishlist
export const checkWishlistService = async ({
  userId,
  productId,
}) => {
  const wishlist = await db.Wishlist.findOne({
    where: {
      userId,
      productId,
    },
  });

  return {
    isWishlisted: !!wishlist,
  };
};