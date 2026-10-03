import express from "express";
import {
  getMe,
  googleLogin,
  login,
  logout,
  register,
  updateProfile,
} from "../controllers/auth.controller.js";
import { isAuth } from "../middlewares/auth.middleware.js";
import {
  loginSchema,
  registerUserSchema,
  updateProfileSchema,
} from "../validation/auth.validaton.js";
import validate from "../middlewares/validate.middleware.js";

const authRouter = express.Router();

authRouter.post("/register", validate(registerUserSchema), register);
authRouter.post("/login", validate(loginSchema), login);
authRouter.post("/google", googleLogin);
authRouter.get("/me", isAuth, getMe);
authRouter.patch(
  "/update-profile",
  isAuth,
  validate(updateProfileSchema),
  updateProfile,
);
authRouter.post("/logout", isAuth, logout);

export default authRouter;
