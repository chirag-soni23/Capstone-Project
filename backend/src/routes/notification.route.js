import express from "express";

import {
  sendNotificationToUsers,
} from "../controllers/notification.controller.js";

import validate from "../middlewares/validate.middleware.js";
import { isAuth } from "../middlewares/auth.middleware.js";
import { checkRole } from "../middlewares/role.middleware.js";

import {
  sendNotificationSchema,
} from "../validation/notification.validation.js";

const notificationRouter = express.Router();

notificationRouter.post(
  "/send",
  isAuth,
  checkRole("admin"),
  validate(sendNotificationSchema),
  sendNotificationToUsers,
);

export default notificationRouter;