import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import cookieParser from "cookie-parser";

import errorHandler from "./src/middlewares/error.middleware.js";
import { connectDB } from "./src/db/db.js";

import authRoutes from "./src/routes/auth.route.js";
import categoryRouter from "./src/routes/category.route.js";
import path from "path";
import productRouter from "./src/routes/product.route.js";
import dashboardRouter from "./src/routes/dashboard.route.js";
import notificationRouter from "./src/routes/notification.route.js";
import wishlistRouter from "./src/routes/wishlist.route.js";

dotenv.config();

const app = express();

const PORT = process.env.PORT || 5000;

// middlewares
app.use(express.json());
app.use(
  "/uploads",
  (req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Cross-Origin-Resource-Policy", "cross-origin");
    next();
  },
  express.static(path.join(process.cwd(), "uploads")),
);
app.use(
  express.urlencoded({
    extended: true,
  }),
);
app.use(cookieParser());
app.use(
  cors({
    origin: true,
    credentials: true,
    maxAge: 86400,
  }),
);

// check route
app.get("/api/check", (req, res) => {
  res.json({
    message: "GlowCare API is running",
  });
});

// routes
app.use("/api/auth", authRoutes);
app.use("/api/category", categoryRouter);
app.use("/api/product",productRouter);
app.use("/api/dashboard",dashboardRouter);
app.use("/api/notification",notificationRouter);
app.use("/api/wishlist",wishlistRouter)
// error handler middleware
app.use(errorHandler);

app.listen(PORT, async () => {
  console.log(`Server Listening on port no. ${PORT}`);

  await connectDB();
});
