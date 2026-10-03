import express from "express";

import {
  createProduct,
  deleteProduct,
  getProducts,
  getProductById,
  updateProduct,
} from "../controllers/product.controller.js";

import validate from "../middlewares/validate.middleware.js";



import multerErrorHandler from "../middlewares/multerErrorHandler.js";
import { productUpload } from "../utils/multer.js";

import { isAuth } from "../middlewares/auth.middleware.js";
import { checkRole } from "../middlewares/role.middleware.js";
import { createProductSchema, updateProductSchema } from "../validation/product.validaton.js";

const productRouter = express.Router();

// Create product
productRouter.post(
  "/",
  isAuth,
  checkRole("admin"),
  productUpload.single("image"),
  multerErrorHandler,
  validate(createProductSchema),
  createProduct,
);

// Get products
productRouter.get(
  "/",
  getProducts,
);

// Get product by ID
productRouter.get(
  "/:id",
  getProductById,
);

// Update product
productRouter.patch(
  "/:id",
  isAuth,
  checkRole("admin"),
  productUpload.single("image"),
  multerErrorHandler,
  validate(updateProductSchema),
  updateProduct,
);

// Delete product
productRouter.delete(
  "/:id",
  isAuth,
  checkRole("admin"),
  deleteProduct,
);

export default productRouter;