import express from "express";

import {
  createCategory,
  deleteCategory,
  getCategories,
  updateCategory,
} from "../controllers/category.controller.js";

import validate from "../middlewares/validate.middleware.js";

import {
  createCategorySchema,
  updateCategorySchema,
} from "../validation/category.validation.js";

import multerErrorHandler from "../middlewares/multerErrorHandler.js";

import { categoryUpload } from "../utils/multer.js";

import { isAuth } from "../middlewares/auth.middleware.js";
import { checkRole } from "../middlewares/role.middleware.js";

const categoryRouter = express.Router();

// Create category
categoryRouter.post(
  "/",
  isAuth,
  checkRole("admin"),
  categoryUpload.single("image"),
  multerErrorHandler,
  validate(createCategorySchema),
  createCategory,
);

// Get categories
categoryRouter.get(
  "/",
  getCategories,
);

// Update category
categoryRouter.patch(
  "/:id",
  isAuth,
  checkRole("admin"),
  categoryUpload.single("image"),
  multerErrorHandler,
  validate(updateCategorySchema),
  updateCategory,
);

// Delete category
categoryRouter.delete(
  "/:id",
  isAuth,
  checkRole("admin"),
  deleteCategory,
);

export default categoryRouter;