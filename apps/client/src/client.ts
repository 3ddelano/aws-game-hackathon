import { GAME_NAME } from "@repo/common";
import io from "socket.io-client";
import "./style.css";
import {
  ConnectedUiScene,
  GameScene,
  InitialUiScene,
  RoomScene,
  SceneManager,
} from "./ui-scenes";

function setupCanvas() {
  const canvas = document.getElementById("app-canvas") as HTMLCanvasElement;
  const gameContainer = document.getElementById(
    "game-container",
  ) as HTMLDivElement;

  const ctx = canvas.getContext("2d");

  const ratio = window.devicePixelRatio ?? 1;

  const resizeCanvas = () => {
    console.log("resizing");

    const canvasSize = gameContainer.getBoundingClientRect();
    canvas.width = Math.floor(canvasSize.width * ratio);
    canvas.height = Math.floor(canvasSize.height * ratio);
    canvas.style.width = `${canvasSize.width}px`;
    canvas.style.height = `${canvasSize.height}px`;
    if (ctx) {
      // ctx.scale(ratio, ratio); // TODO: handle hdpi screens
      ctx.fillStyle = "black";
      ctx.fillRect(0, 0, canvasSize.width, canvasSize.height);
    }
  };
  window.onresize = (() => {
    const DEBOUCE_MS = 200;
    let timeout: Timer;
    return () => {
      clearTimeout(timeout);
      timeout = setTimeout(resizeCanvas, DEBOUCE_MS);
    };
  })();
  resizeCanvas();

  return { canvas, ctx };
}

async function main() {
  console.log(GAME_NAME);
  let connectedToServer = false;
  globalThis.socket = io("ws://localhost:3005", {
    reconnection: false,
  });

  globalThis.sceneManager = new SceneManager();
  const initialUiScene = new InitialUiScene();
  const connectedUiScene = new ConnectedUiScene();
  const roomScene = new RoomScene();
  const gameScene = new GameScene();

  const { ctx } = setupCanvas();
  if (!ctx) {
    initialUiScene.setMessage("Your browser does not support HTML5 canvas.");
    return;
  }

  // Scenes
  globalThis.sceneManager.registerScene(initialUiScene);
  globalThis.sceneManager.registerScene(connectedUiScene);
  globalThis.sceneManager.registerScene(roomScene);
  globalThis.sceneManager.registerScene(gameScene);

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
    sceneManager.showScene("initial");
    initialUiScene.setMessage("Disconnected from game server.");
  });
}

main();
