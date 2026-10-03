import Joi from "joi";

export const sendNotificationSchema = Joi.object({
  title: Joi.string()
    .trim()
    .min(2)
    .max(100)
    .required()
    .messages({
      "string.base": "Title must be a string",
      "string.empty": "Title is required",
      "string.min": "Title must be at least 2 characters long",
      "string.max": "Title must not exceed 100 characters",
      "any.required": "Title is required",
    }),

  message: Joi.string()
    .trim()
    .min(2)
    .max(500)
    .required()
    .messages({
      "string.base": "Message must be a string",
      "string.empty": "Message is required",
      "string.min": "Message must be at least 2 characters long",
      "string.max": "Message must not exceed 500 characters",
      "any.required": "Message is required",
    }),
});