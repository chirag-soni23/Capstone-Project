import ApiError from "../utils/apiResponse.js";

export const checkRole = (...roles) => {
  return (req, res, next) => {

    if (!roles.includes(req.user.role)) {
      throw ApiError.FORBIDDEN("Access denied");
    }

    next();
  };
};