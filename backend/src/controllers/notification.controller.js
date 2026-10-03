import { StatusCodes } from "../config/index.js";
import { successResponse } from "../utils/apiResponse.js";

import {
  sendNotificationToUsersService,
} from "../services/notification.service.js";

export const sendNotificationToUsers = async (req, res, next) => {
  try {
    const notification = await sendNotificationToUsersService({
      title: req.body.title,
      message: req.body.message,
    });

    return successResponse(res, StatusCodes.OK, {
      message: "Notification sent successfully",
      data: notification,
    });
  } catch (error) {
    next(error);
  }
};