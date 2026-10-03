import { StatusCodes } from "../config/index.js";

class ApiError extends Error {
  constructor(statusCode, message, error = null) {
    super(message);
    this.statusCode = statusCode;
    this.message = message;
    this.error = error;
  }
  static BADREQUEST(message = "bad request", error = null) {
    return new ApiError(StatusCodes.BAD_REQUEST, message, error);
  }
  static UNAUTHORIZED(message = "invalid authentication", error = null) {
    return new ApiError(StatusCodes.UNAUTHORIZED, message, error);
  }
  static FORBIDDEN(message = "Access Denied", error = null) {
    return new ApiError(StatusCodes.FORBIDDEN, message, error);
  }
  static NOTFOUND(message = "Resource Not Found", error = null) {
    return new ApiError(StatusCodes.NOT_FOUND, message, error);
  }
  static CONFLICT(
    message = "A conflict occurred with the current state of the resource",
    error = null
  ) {
    return new ApiError(StatusCodes.CONFLICT, message, error);
  }
  static INTLSERVER(message = "Internal Server Error", error = null) {
    return new ApiError(StatusCodes.INTERNAL_SERVER_ERROR, message, error);
  }
}

export default ApiError;

export function successResponse(res, statusCode = 200, payload = {}) {
  const response = {
    success: true,
    statusCode,
    ...payload
  };

  return res.status(statusCode).json(response);
}