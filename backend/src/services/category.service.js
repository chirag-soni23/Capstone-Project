import { Op } from "sequelize";
import db from "../models/index.js";
import ApiError from "../utils/apiResponse.js";
import fs from "fs";
import path from "path";

// Create category
export const createCategoryService = async ({ name, file }) => {
  if (!file) {
    throw ApiError.BADREQUEST("Category image is required");
  }

  const existCategory = await db.Category.findOne({
    where: { name },
  });

  if (existCategory) {
    throw ApiError.CONFLICT("Category already exists");
  }

  const category = await db.Category.create({
    name,
    image: `/uploads/categories/${file.filename}`,
  });

  return category;
};

// Get categories
export const getCategoriesService = async ({
  page = 1,
  limit = 10,
  search = "",
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

  const { count, rows } = await db.Category.findAndCountAll({
    where,
    limit,
    offset,
    order: [["createdAt", "DESC"]],
  });

  return {
    categories: rows,
    pagination: {
      totalCategories: count,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      limit,
    },
  };
};

// Update category
export const updateCategoryService = async ({
  id,
  name,
  file,
}) => {
  const category = await db.Category.findByPk(id);

  if (!category) {
    throw ApiError.NOTFOUND("Category not found");
  }

  if (name && name !== category.name) {
    const existCategory = await db.Category.findOne({
      where: {
        name,
        id: {
          [Op.ne]: category.id,
        },
      },
    });

    if (existCategory) {
      throw ApiError.CONFLICT("Category already exists");
    }
  }

  let image = category.image;

  if (file) {
    if (category.image) {
      const oldImagePath = path.join(
        process.cwd(),
        category.image
      );

      if (fs.existsSync(oldImagePath)) {
        fs.unlinkSync(oldImagePath);
      }
    }

    image = `/uploads/categories/${file.filename}`;
  }

  await category.update({
    name: name ?? category.name,
    image,
  });

  return category;
};

// Delete category
export const deleteCategoryService = async (id) => {
  const category = await db.Category.findByPk(id);

  if (!category) {
    throw ApiError.NOTFOUND("Category not found");
  }

  if (category.image) {
    const imagePath = path.join(
      process.cwd(),
      category.image
    );

    if (fs.existsSync(imagePath)) {
      fs.unlinkSync(imagePath);
    }
  }

  await category.destroy();

  return true;
};