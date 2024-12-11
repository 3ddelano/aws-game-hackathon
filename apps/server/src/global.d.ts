import type { ClientToServerEvents, ServerToClientEvents } from "@repo/common";
import type { Server } from "socket.io";

declare global {
  var io: Server<ClientToServerEvents, ServerToClientEvents>;
}
