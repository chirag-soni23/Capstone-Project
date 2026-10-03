import { cert, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getMessaging } from "firebase-admin/messaging";

import serviceAccount from "./firebase-service-account.json" with {
  type: "json",
};

const firebaseApp = initializeApp({
  credential: cert(serviceAccount),
});

export const firebaseAuth = getAuth(firebaseApp);
export const firebaseMessaging = getMessaging(firebaseApp);