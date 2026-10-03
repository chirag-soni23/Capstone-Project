import Joi from "joi";

// category
export const createCategorySchema = Joi.object({
  name: Joi.string().trim().min(2).max(50).required().messages({
    "string.base": "Category name must be a string",
    "string.empty": "Category name is required",
    "string.min": "Category name must be at least 2 characters long",
    "string.max": "Category name must not exceed 50 characters",
    "any.required": "Category name is required",
  }),
});

export const updateCategorySchema = Joi.object({
  name: Joi.string().trim().min(2).max(50).optional().messages({
    "string.base": "Category name must be a string",
    "string.min": "Category name must be at least 2 characters long",
    "string.max": "Category name must not exceed 50 characters",
  }),

})
  .min(1)
  .messages({
    "object.min": "At least one field is required to update",
  });

