import { successResponse } from "../utils/apiResponse.js";
import { StatusCodes } from "../config/index.js";

import {
  registerUser,
  loginUser,
  googleLoginUser,
  getMyProfile,
  updateUserProfile,
} from "../services/auth.service.js";

// register
export const register = async (req, res, next) => {
  try {
    const user = await registerUser({
      ...req.body,
      res,
    });

    return successResponse(res, StatusCodes.CREATED, {
      message: "User Registered Successfully",
      data: user,
    });
  } catch (error) {
    console.log(error.message)
    next(error);
  }
};

// login
export const login = async (req, res, next) => {
  try {
    const user = await loginUser({
      ...req.body,
      res,
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Login success",
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

// Google login
export const googleLogin = async (req, res, next) => {
  try {
    const user = await googleLoginUser({
      idToken: req.body.idToken,
      res,
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Google login success",
      data: user,
    });
  } catch (error) {
    console.log(error.message)
    next(error);
  }
};

// me
export const getMe = async (req, res, next) => {
  try {
    const user = await getMyProfile(req.user.id);

    return successResponse(res, StatusCodes.OK, {
      message: "Profile fetched",
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

// update profile
export const updateProfile = async (req, res, next) => {
  try {
    const user = await updateUserProfile(
      req.user.id,
      req.body,
    );

    return successResponse(res, StatusCodes.OK, {
      message: "Profile updated successfully",
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

// logout
export const logout = async (req, res, next) => {
  try {
    res.clearCookie("token", {
      httpOnly: true,
      sameSite: "strict",
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Logout Successfully",
    });
  } catch (error) {
    next(error);
  }
};