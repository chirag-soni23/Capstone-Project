import { StatusCodes } from "../config/index.js";
import { successResponse } from "../utils/apiResponse.js";

import {
  createProductService,
  getProductsService,
  getProductByIdService,
  updateProductService,
  deleteProductService,
} from "../services/product.service.js";

// Create product
export const createProduct = async (req, res, next) => {
  try {
    const product = await createProductService({
      name: req.body.name,
      categoryId: req.body.categoryId,
      price: req.body.price,
      discountPercentage: req.body.discountPercentage,
      description: req.body.description,
      file: req.file,
    });

    return successResponse(res, StatusCodes.CREATED, {
      message: "Product created successfully",
      data: product,
    });
  } catch (error) {
    next(error);
  }
};

// Get products
export const getProducts = async (req, res, next) => {
  try {
    const data = await getProductsService({
      page: req.query.page,
      limit: req.query.limit,
      search: req.query.search || "",
      categoryId: req.query.categoryId,
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Products fetched successfully",
      data,
    });
  } catch (error) {
    next(error);
  }
};

// Get product by ID
export const getProductById = async (req, res, next) => {
  try {
    const product = await getProductByIdService(req.params.id);

    return successResponse(res, StatusCodes.OK, {
      message: "Product fetched successfully",
      data: product,
    });
  } catch (error) {
    next(error);
  }
};

// Update product
export const updateProduct = async (req, res, next) => {
  try {
    const product = await updateProductService({
      id: req.params.id,
      name: req.body.name,
      categoryId: req.body.categoryId,
      price: req.body.price,
      discountPercentage: req.body.discountPercentage,
      description: req.body.description,
      file: req.file,
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Product updated successfully",
      data: product,
    });
  } catch (error) {
    next(error);
  }
};

// Delete product
export const deleteProduct = async (req, res, next) => {
  try {
    await deleteProductService(req.params.id);

    return successResponse(res, StatusCodes.OK, {
      message: "Product deleted successfully",
    });
  } catch (error) {
    next(error);
  }
};