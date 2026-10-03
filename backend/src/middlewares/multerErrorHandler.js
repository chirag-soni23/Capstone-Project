import { StatusCodes } from "../config/index.js";
import { MulterError } from "multer";

function multerErrorHandler(err, req, res, next) {
  console.error("Multer error handler:", err);

  if (err instanceof MulterError) {
    switch (err.code) {
      case "LIMIT_FILE_SIZE":
        if (err.field === "thumbnail") {
          return res.status(StatusCodes.BAD_REQUEST).json({
            success: false,
            message: "Thumbnail image size must not exceed 5MB",
          });
        }

        if (err.field === "images") {
          return res.status(StatusCodes.BAD_REQUEST).json({
            success: false,
            message: "Each gallery image size must not exceed 5MB",
          });
        }
        return res.status(StatusCodes.BAD_REQUEST).json({
          message: `File size exceeds the limit of ${req.maxFileSize || "allowed size"}`,
        });

      case "LIMIT_UNEXPECTED_FILE":
        if (err.field === "images") {
          return res.status(StatusCodes.BAD_REQUEST).json({
            success: false,
            message: "Maximum 5 gallery images are allowed.",
          });
        }

        if (err.field === "thumbnail") {
          return res.status(StatusCodes.BAD_REQUEST).json({
            success: false,
            message: "Only one thumbnail image is allowed.",
          });
        }

        return res.status(StatusCodes.BAD_REQUEST).json({
          success: false,
          message: `Unexpected file field: ${err.field}`,
        });

      case "LIMIT_FILE_COUNT":
        return res
          .status(StatusCodes.BAD_REQUEST)
          .json({ message: "Too many files uploaded" });

      default:
        return res
          .status(StatusCodes.BAD_REQUEST)
          .json({ message: `Multer error: ${err.message}` });
    }
  }

  if (err) {
    return res.status(err.statusCode || StatusCodes.BAD_REQUEST).json({
      message: err.message,
    });
  }

  next();
}

export default multerErrorHandler;
