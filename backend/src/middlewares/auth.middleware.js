import jwt from "jsonwebtoken";
import User from "../models/auth.model.js";
import ApiError from "../utils/apiResponse.js";

export const isAuth = async (req, res, next) => {
  try {
    const token = req.cookies.token;

    if (!token) {
      throw ApiError.UNAUTHORIZED("Authentication required");
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findByPk(decoded.id);

    if (!user) {
      throw ApiError.UNAUTHORIZED("User not found");
    }
    req.user = user;

    next();
  } catch (error) {
    next(error);
  }
};
