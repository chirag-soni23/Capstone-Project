import { Op } from "sequelize";
import db from "../models/index.js";
import ApiError from "../utils/apiResponse.js";
import fs from "fs";
import path from "path";

// Create product
export const createProductService = async ({
  name,
  categoryId,
  price,
  discountPercentage,
  description,
  file,
}) => {
  if (!file) {
    throw ApiError.BADREQUEST("Product image is required");
  }

  if (!name) {
    throw ApiError.BADREQUEST("Product name is required");
  }

  if (!categoryId) {
    throw ApiError.BADREQUEST("Category is required");
  }

  if (price === undefined || price === null || price === "") {
    throw ApiError.BADREQUEST("Product price is required");
  }

  const category = await db.Category.findByPk(categoryId);

  if (!category) {
    throw ApiError.NOTFOUND("Category not found");
  }

  const existProduct = await db.Product.findOne({
    where: {
      name,
    },
  });

  if (existProduct) {
    throw ApiError.CONFLICT("Product already exists");
  }

  const productPrice = Number(price);
  const discount = Number(discountPercentage || 0);

  if (isNaN(productPrice) || productPrice < 0) {
    throw ApiError.BADREQUEST("Invalid product price");
  }

  if (isNaN(discount) || discount < 0 || discount > 100) {
    throw ApiError.BADREQUEST(
      "Discount percentage must be between 0 and 100",
    );
  }

  const discountPrice = (
    productPrice -
    (productPrice * discount) / 100
  ).toFixed(2);

  const product = await db.Product.create({
    name,
    categoryId,
    price: productPrice,
    discountPercentage: discount,
    discountPrice,
    description,
    image: `/uploads/products/${file.filename}`,
  });

  return product;
};

// Get products
export const getProductsService = async ({
  page = 1,
  limit = 10,
  search = "",
  categoryId,
}) => {
  page = parseInt(page);
  limit = parseInt(limit);

  if (isNaN(page) || page < 1) {
    throw ApiError.BADREQUEST("Page must be a positive integer");
  }

  if (isNaN(limit) || limit < 1 || limit > 50) {
    throw ApiError.BADREQUEST("Limit must be between 1 and 50");
  }

  const offset = (page - 1) * limit;

  const where = {};

  if (search.trim()) {
    where.name = {
      [Op.like]: `%${search.trim()}%`,
    };
  }

  if (categoryId) {
    where.categoryId = categoryId;
  }

  const { count, rows } = await db.Product.findAndCountAll({
    where,
    limit,
    offset,
    order: [["createdAt", "DESC"]],
    include: [
      {
        model: db.Category,
        as: "category",
        attributes: ["id", "name"],
      },
    ],
  });

  return {
    products: rows,
    pagination: {
      totalProducts: count,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      limit,
    },
  };
};

// Get product by ID
export const getProductByIdService = async (id) => {
  const product = await db.Product.findByPk(id, {
    include: [
      {
        model: db.Category,
        as: "category",
        attributes: ["id", "name"],
      },
    ],
  });

  if (!product) {
    throw ApiError.NOTFOUND("Product not found");
  }

  return product;
};

// Update product
export const updateProductService = async ({
  id,
  name,
  categoryId,
  price,
  discountPercentage,
  description,
  file,
}) => {
  const product = await db.Product.findByPk(id);

  if (!product) {
    throw ApiError.NOTFOUND("Product not found");
  }

  if (categoryId && Number(categoryId) !== product.categoryId) {
    const category = await db.Category.findByPk(categoryId);

    if (!category) {
      throw ApiError.NOTFOUND("Category not found");
    }
  }

  if (name && name !== product.name) {
    const existProduct = await db.Product.findOne({
      where: {
        name,
        id: {
          [Op.ne]: product.id,
        },
      },
    });

    if (existProduct) {
      throw ApiError.CONFLICT("Product already exists");
    }
  }

  const updatedPrice =
    price !== undefined && price !== null && price !== ""
      ? Number(price)
      : Number(product.price);

  const updatedDiscount =
    discountPercentage !== undefined &&
    discountPercentage !== null &&
    discountPercentage !== ""
      ? Number(discountPercentage)
      : Number(product.discountPercentage);

  if (isNaN(updatedPrice) || updatedPrice < 0) {
    throw ApiError.BADREQUEST("Invalid product price");
  }

  if (
    isNaN(updatedDiscount) ||
    updatedDiscount < 0 ||
    updatedDiscount > 100
  ) {
    throw ApiError.BADREQUEST(
      "Discount percentage must be between 0 and 100",
    );
  }

  const discountPrice = (
    updatedPrice -
    (updatedPrice * updatedDiscount) / 100
  ).toFixed(2);

  let image = product.image;

  if (file) {
    if (product.image) {
      const oldImagePath = path.join(
        process.cwd(),
        product.image,
      );

      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
      }
    }

    image = `/uploads/products/${file.filename}`;
  }

  await product.update({
    name: name ?? product.name,
    categoryId: categoryId ?? product.categoryId,
    price: updatedPrice,
    discountPercentage: updatedDiscount,
    discountPrice,
    description: description ?? product.description,
    image,
  });

  return product;
};

// Delete product
export const deleteProductService = async (id) => {
  const product = await db.Product.findByPk(id);

  if (!product) {
    throw ApiError.NOTFOUND("Product not found");
  }

  if (product.image) {
    const imagePath = path.join(
      process.cwd(),
      product.image,
    );

    if (fs.existsSync(imagePath)) {
      fs.unlinkSync(imagePath);
    }
  }

  await product.destroy();

  return true;
};