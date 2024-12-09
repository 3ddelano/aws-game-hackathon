import { GAME_NAME } from "@repo/common";
import io from "socket.io-client";
import "./style.css";
import {
  ConnectedUiScene,
  InitialUiScene,
  RoomScene,
  SceneManager,
} from "./ui-scenes";

async function main() {
  console.log(GAME_NAME);
  let connectedToServer = false;
  globalThis.socket = io("ws://localhost:3005", {
    reconnection: false,
  });

  const canvas = document.getElementById("app-canvas") as HTMLCanvasElement;
  const ctx = canvas.getContext("2d");

  globalThis.sceneManager = new SceneManager();
  const initialUiScene = new InitialUiScene();
  const connectedUiScene = new ConnectedUiScene();
  const roomScene = new RoomScene();

  if (!ctx) {
    initialUiScene.setMessage("Your browser does not support HTML5 canvas.");
    return;
  }

  // Scenes
  globalThis.sceneManager.registerScene(initialUiScene);
  globalThis.sceneManager.registerScene(connectedUiScene);
  globalThis.sceneManager.registerScene(roomScene);

  globalThis.socket.onAny((eventName, ...args) => {
    console.log("Got event: ", eventName, args);
  });

  globalThis.socket.on("connect_error", (err) => {
    console.error("connect_error", err);
    console.log("Failed to connect to game server.");
    connectedToServer = false;
    initialUiScene.setMessage("Failed to connect to game server.");
  });

  globalThis.socket.on("connect", () => {
    console.log("Connected to server");
    console.log("Socket id: ", socket.id);
    connectedToServer = true;
    setTimeout(() => {
      globalThis.sceneManager.showScene("connected");
    }, 250);
  });

  globalThis.socket.on("disconnect", (err) => {
    console.log("disconnect", err);
    connectedToServer = false;
    initialUiScene.setMessage("Disconnected from game server.");
  });
}

main();
