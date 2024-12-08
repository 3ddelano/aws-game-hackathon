import { GAME_NAME } from "@repo/common";
import io from "socket.io-client";
import "./style.css";

console.log(GAME_NAME);

const socket = io("ws://localhost:3005");

socket.on("connect", () => {
  console.log("Connected to server");
});
