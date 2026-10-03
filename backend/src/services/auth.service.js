import db from "../models/index.js";
import bcrypt from "bcrypt";
import generateToken from "../utils/generateToken.js";
import { firebaseAuth } from "../config/firebase.js";

// register user
export const registerUser = async ({
  name,
  email,
  password,
  confirmPassword,
  role,
  res,
}) => {
  if (password !== confirmPassword) {
    throw new Error("Password and Confirm Password do not match");
  }

  const existEmail = await db.User.findOne({
    where: { email },
  });

  if (existEmail) {
    throw new Error("Email already exists");
  }

  if (role === "admin") {
    const existingAdmin = await db.User.findOne({
      where: { role: "admin" },
    });

    if (existingAdmin) {
      throw new Error("Admin already exists");
    }
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  const user = await db.User.create({
    name,
    email,
    password: hashedPassword,
    role: role || "user",
  });

  generateToken(user, res);

  return user;
};

// login user
export const loginUser = async ({ email, password, res }) => {
  const user = await db.User.findOne({
    where: { email },
  });

  if (!user || !user.password) {
    throw new Error("Invalid email or password");
  }

  const match = await bcrypt.compare(password, user.password);

  if (!match) {
    throw new Error("Invalid email or password");
  }

  generateToken(user, res);

  return user;
};

// Google login
export const googleLoginUser = async ({ idToken, res }) => {
  if (!idToken || typeof idToken !== "string") {
    throw new Error("Firebase ID token is required");
  }

  const decodedToken = await firebaseAuth.verifyIdToken(idToken);

  const email = decodedToken.email;
  const name = decodedToken.name || "Google User";
  const uid = decodedToken.uid;

  if (!email) {
    throw new Error("Google account email not found");
  }

  let user = await db.User.findOne({
    where: { email },
  });

  if (!user) {
    user = await db.User.create({
      name,
      email,
      password: null,
      firebaseUid: uid,
      role: "user",
    });
  } else {
    if (!user.firebaseUid) {
      user.firebaseUid = uid;
      await user.save();
    }
  }

  generateToken(user, res);

  return user;
};
// get my profile
export const getMyProfile = async (userId) => {
  const user = await db.User.findByPk(userId, {
    attributes: {
      exclude: ["password"],
    },
  });

  if (!user) {
    throw new Error("User not found");
  }

  return user;
};

// update profile
export const updateUserProfile = async (userId, { name, email }) => {
  const user = await db.User.findByPk(userId);

  if (!user) {
    throw new Error("User not found");
  }

  if (email && email !== user.email) {
    const existEmail = await db.User.findOne({
      where: { email },
    });

    if (existEmail) {
      throw new Error("Email already exists");
    }

    user.email = email;
  }

  if (name) {
    user.name = name;
  }

  await user.save();

  return user;
};