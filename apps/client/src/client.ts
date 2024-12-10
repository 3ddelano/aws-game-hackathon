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
  const gameContainer = document.getElementById(
    "game-container",
  ) as HTMLDivElement;
  globalThis.sceneManager = new SceneManager();
  const initialUiScene = new InitialUiScene();
  const connectedUiScene = new ConnectedUiScene();
  const roomScene = new RoomScene();

  // Setting up HDPI canvas
  const ratio = window.devicePixelRatio ?? 1;
  const canvasSize = gameContainer.getBoundingClientRect();

  const ctx = canvas.getContext("2d");
  if (!ctx) {
    initialUiScene.setMessage("Your browser does not support HTML5 canvas.");
    return;
  }

  // Initialize canvas
  const resizeCanvas = () => {
    const canvasSize = gameContainer.getBoundingClientRect();
    canvas.width = canvasSize.width * ratio;
    canvas.height = canvasSize.height * ratio;
    canvas.style.width = `${canvasSize.width}px`;
    canvas.style.height = `${canvasSize.height}px`;
    ctx.scale(ratio, ratio);
    ctx.fillStyle = "black";
    ctx.fillRect(0, 0, canvasSize.width, canvasSize.height);
  };
  window.onresize = () => {
    resizeCanvas();
  };
  resizeCanvas();

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
    }, 300);
  });

  globalThis.socket.on("disconnect", (err) => {
    console.log("disconnect", err);
    connectedToServer = false;
    initialUiScene.setMessage("Disconnected from game server.");
  });
}

main();
