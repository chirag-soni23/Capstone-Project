import { firebaseMessaging } from "../config/firebase.js";
import ApiError from "../utils/apiResponse.js";

export const sendNotificationToUsersService = async ({
  title,
  message,
}) => {
  if (!title?.trim()) {
    throw ApiError.BADREQUEST("Notification title is required");
  }

  if (!message?.trim()) {
    throw ApiError.BADREQUEST("Notification message is required");
  }

  const response = await firebaseMessaging.send({
    topic: "users",

    notification: {
      title: title.trim(),
      body: message.trim(),
    },

    data: {
      type: "admin_notification",
      title: title.trim(),
      message: message.trim(),
    },

    android: {
      priority: "high",
      notification: {
        channelId: "default",
      },
    },
  });

  return {
    messageId: response,
    title: title.trim(),
    message: message.trim(),
  };
};