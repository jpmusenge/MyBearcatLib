import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyBmDqnq2JsV6UTO-DWFSj_RNxt3OoWa_VA",
  authDomain: "mybearcatlib.firebaseapp.com",
  projectId: "mybearcatlib",
  storageBucket: "mybearcatlib.firebasestorage.app",
  messagingSenderId: "509579807960",
  appId: "1:509579807960:web:0b7b9c5e7885e4559fdbad",
  measurementId: "G-J70YZ7Q2PY",
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
