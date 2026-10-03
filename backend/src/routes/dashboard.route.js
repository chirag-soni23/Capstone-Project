import express from "express";

import { getDashboard, getDashboardUsers } from "../controllers/dashboard.controller.js";
import { isAuth } from "../middlewares/auth.middleware.js";
import { checkRole } from "../middlewares/role.middleware.js";

const dashboardRouter = express.Router();

dashboardRouter.get("/", isAuth, checkRole("admin"), getDashboard);
dashboardRouter.get("/users", isAuth, checkRole("admin"), getDashboardUsers);

export default dashboardRouter;
