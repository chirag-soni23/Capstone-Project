import multer from "multer";
import path from "path";
import fs from "fs";
import ApiError from "./apiResponse.js";

const createStorage = (folder, prefix, maxSizeMB) => {
  const uploadDir = path.join(process.cwd(), "uploads", folder);

  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }

  return multer.diskStorage({
    destination: (req, file, cb) => {
      req.maxFileSize = `${maxSizeMB}MB`;
      cb(null, uploadDir);
    },

    filename: (req, file, cb) => {
      const ext = path.extname(file.originalname).toLowerCase();

      const fileName = `${prefix}-${Date.now()}-${Math.floor(
        Math.random() * 1000000,
      )}${ext}`;

      cb(null, fileName);
    },
  });
};

const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();

  const allowedExtensions = [".jpg", ".jpeg", ".png"];
  const allowedMimeTypes = [
    "image/jpeg",
    "image/png",
    "application/octet-stream",
  ];

  if (
    allowedExtensions.includes(ext) &&
    allowedMimeTypes.includes(file.mimetype)
  ) {
    return cb(null, true);
  }

  return cb(
    ApiError.BADREQUEST("Only JPG, JPEG and PNG images are allowed"),
    false,
  );
};

// product images and thumnail upload
export const productUpload = multer({
  storage: createStorage("products", "product", 5),
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB per file
  },
});

// category image upload
export const categoryUpload = multer({
  storage: createStorage("categories", "category", 2),
  fileFilter,
  limits: {
    fileSize: 2 * 1024 * 1024, // 2MB
  },
});

// profile image upload
export const profileUpload = multer({
  storage: createStorage("profiles", "profile", 2),
  fileFilter,
  limits: {
    fileSize: 2 * 1024 * 1024, // 2MB
  },
});
