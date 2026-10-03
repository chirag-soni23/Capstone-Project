import { StatusCodes } from "../config/index.js";
import { successResponse } from "../utils/apiResponse.js";

import {
  createCategoryService,
  getCategoriesService,
  updateCategoryService,
  deleteCategoryService,
} from "../services/category.service.js";

// Create category
export const createCategory = async (req, res, next) => {
  try {
    const category = await createCategoryService({
      name: req.body.name,
      file: req.file,
    });

    return successResponse(res, StatusCodes.CREATED, {
      message: "Category created successfully",
      data: category,
    });
  } catch (error) {
    next(error);
  }
};

// Get categories
export const getCategories = async (req, res, next) => {
  try {
    const data = await getCategoriesService({
      page: req.query.page,
      limit: req.query.limit,
      search: req.query.search || "",
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Categories fetched successfully",
      data,
    });
  } catch (error) {
    next(error);
  }
};

// Update category
export const updateCategory = async (req, res, next) => {
  try {
    const category = await updateCategoryService({
      id: req.params.id,
      name: req.body.name,
      file: req.file,
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Category updated successfully",
      data: category,
    });
  } catch (error) {
    next(error);
  }
};

// Delete category
export const deleteCategory = async (req, res, next) => {
  try {
    await deleteCategoryService(req.params.id);

    return successResponse(res, StatusCodes.OK, {
      message: "Category deleted successfully",
    });
  } catch (error) {
    next(error);
  }
};