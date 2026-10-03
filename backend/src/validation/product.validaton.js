import Joi from "joi";

// Create Product
export const createProductSchema = Joi.object({
  name: Joi.string()
    .trim()
    .min(2)
    .max(150)
    .required()
    .messages({
      "string.base": "Product name must be a string",
      "string.empty": "Product name is required",
      "string.min": "Product name must be at least 2 characters long",
      "string.max": "Product name must not exceed 150 characters",
      "any.required": "Product name is required",
    }),

  categoryId: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      "number.base": "Category ID must be a number",
      "number.integer": "Category ID must be an integer",
      "number.positive": "Category ID must be positive",
      "any.required": "Category is required",
    }),

  price: Joi.number()
    .positive()
    .required()
    .messages({
      "number.base": "Price must be a number",
      "number.positive": "Price must be positive",
      "any.required": "Price is required",
    }),

  discountPercentage: Joi.number()
    .min(0)
    .max(100)
    .required()
    .messages({
      "number.base": "Discount percentage must be a number",
      "number.min": "Discount percentage cannot be less than 0",
      "number.max": "Discount percentage cannot exceed 100",
      "any.required": "Discount percentage is required",
    }),

  description: Joi.string()
    .trim()
    .max(2000)
    .optional()
    .allow("")
    .messages({
      "string.base": "Description must be a string",
      "string.max": "Description must not exceed 2000 characters",
    }),
});

// Update Product
export const updateProductSchema = Joi.object({
  name: Joi.string()
    .trim()
    .min(2)
    .max(150)
    .optional()
    .messages({
      "string.base": "Product name must be a string",
      "string.min": "Product name must be at least 2 characters long",
      "string.max": "Product name must not exceed 150 characters",
    }),

  categoryId: Joi.number()
    .integer()
    .positive()
    .optional()
    .messages({
      "number.base": "Category ID must be a number",
      "number.integer": "Category ID must be an integer",
      "number.positive": "Category ID must be positive",
    }),

  price: Joi.number()
    .positive()
    .optional()
    .messages({
      "number.base": "Price must be a number",
      "number.positive": "Price must be positive",
    }),

  discountPercentage: Joi.number()
    .min(0)
    .max(100)
    .optional()
    .allow(null)
    .messages({
      "number.base": "Discount percentage must be a number",
      "number.min": "Discount percentage cannot be less than 0",
      "number.max": "Discount percentage cannot exceed 100",
    }),

  description: Joi.string()
    .trim()
    .max(2000)
    .optional()
    .allow("")
    .messages({
      "string.base": "Description must be a string",
      "string.max": "Description must not exceed 2000 characters",
    }),
})
  .min(1)
  .messages({
    "object.min": "At least one field is required to update",
  });