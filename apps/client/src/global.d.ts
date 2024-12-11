import type { ClientToServerEvents, ServerToClientEvents } from "@repo/common";
import type { Socket } from "socket.io-client";
import type { SceneManager } from "./ui-scenes";

declare global {
  var socket: Socket<ServerToClientEvents, ClientToServerEvents>;
  var sceneManager: SceneManager;
}
