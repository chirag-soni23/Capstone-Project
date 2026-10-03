import { StatusCodes } from "../config/index.js";
import { successResponse } from "../utils/apiResponse.js";

import {
  addWishlistService,
  getMyWishlistService,
  removeWishlistService,
  checkWishlistService,
} from "../services/wishlist.service.js";

// Add wishlist
export const addWishlist = async (req, res, next) => {
  try {
    const wishlist = await addWishlistService({
      userId: req.user.id,
      productId: req.body.productId,
    });

    return successResponse(res, StatusCodes.CREATED, {
      message: "Product added to wishlist",
      data: wishlist,
    });
  } catch (error) {
    next(error);
  }
};

// Get my wishlist
export const getMyWishlist = async (req, res, next) => {
  try {
    const wishlist = await getMyWishlistService(
      req.user.id,
    );

    return successResponse(res, StatusCodes.OK, {
      message: "Wishlist fetched successfully",
      data: wishlist,
    });
  } catch (error) {
    next(error);
  }
};

// Remove wishlist
export const removeWishlist = async (req, res, next) => {
  try {
    await removeWishlistService({
      userId: req.user.id,
      productId: req.params.productId,
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Product removed from wishlist",
    });
  } catch (error) {
    next(error);
  }
};

// Check wishlist
export const checkWishlist = async (req, res, next) => {
  try {
    const data = await checkWishlistService({
      userId: req.user.id,
      productId: req.params.productId,
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Wishlist status fetched successfully",
      data,
    });
  } catch (error) {
    next(error);
  }
};