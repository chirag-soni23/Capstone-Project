import { StatusCodes } from "../config/index.js";
import { successResponse } from "../utils/apiResponse.js";

import {
  getDashboardService,
  getDashboardUsersService,
} from "../services/dashboard.service.js";

export const getDashboard = async (req, res, next) => {
  try {
    const data = await getDashboardService();

    return successResponse(res, StatusCodes.OK, {
      message: "Dashboard data fetched successfully",
      data,
    });
  } catch (error) {
    next(error);
  }
};

// Get all users
export const getDashboardUsers = async (req, res, next) => {
  try {
    const users = await getDashboardUsersService();

    return successResponse(res, StatusCodes.OK, {
      message: "Users fetched successfully",
      data: users,
    });
  } catch (error) {
    next(error);
  }
};