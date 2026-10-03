import express from "express";

import {
  addWishlist,
  getMyWishlist,
  removeWishlist,
  checkWishlist,
} from "../controllers/wishlist.controller.js";

import { isAuth } from "../middlewares/auth.middleware.js";

const wishlistRouter = express.Router();

wishlistRouter.post(
  "/",
  isAuth,
  addWishlist,
);

wishlistRouter.get(
  "/",
  isAuth,
  getMyWishlist,
);

wishlistRouter.get(
  "/check/:productId",
  isAuth,
  checkWishlist,
);

wishlistRouter.delete(
  "/:productId",
  isAuth,
  removeWishlist,
);

export default wishlistRouter;