import { createServer } from "node:http";
import {
  type ClientToServerEvents,
  type RawMapData,
  SOCKET_CHANNEL_PUBLIC,
  type ServerToClientEvents,
} from "@repo/common";
import level01Data from "@repo/common/assets/maps/level01.json";
import { logger } from "@repo/common/logger";
import express from "express";
import * as socketio from "socket.io";
import { RoomManager } from "./managers/room-manager";

class GameMap {
  private data: RawMapData;

  constructor(json: unknown) {
    if ((json as { type?: string })?.type !== "map") {
      throw new Error(`Could not create GameMap: Invalid json: ${json}`);
    }
    this.data = {
      ...(json as object),
      // biome-ignore lint/suspicious/noExplicitAny: <explanation>
      layers: (json as any).layers.map((layer: any) => ({
        ...layer,
        data: layer.data.reduce((acc: number[][], elm: number, i: number) => {
          const row = Math.floor(i / layer.width);
          if (!acc[row]) {
            acc[row] = [];
          }
          acc[row].push(elm);
          return acc;
        }, [] as number[][]),
      })),
    } as RawMapData;
  }

  public getLayer(name: string) {
    const layer = this.data.layers.find((layer) => layer.name === name);
    if (!layer) {
      throw new Error(`Could not find layer ${name}`);
    }
    return layer;
  }

  public getPayload() {
    return this.data;
  }
}

async function main() {
  logger.info("Starting game server...");
  // // Load map
  // const map = new GameMap(level01Data);

  const app = express();
  const httpServer = createServer(app);
  globalThis.io = new socketio.Server<
    ClientToServerEvents,
    ServerToClientEvents
  >(httpServer, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"],
    },
  });

  const roomManager = new RoomManager();

  io.on("connection", (socket) => {
    logger.info(`New client connected: id ${socket.id}`);

    // New player will join the public channel
    socket.join(SOCKET_CHANNEL_PUBLIC);

    socket.onAny((eventName, ...args) => {
      logger.info("Got event:", eventName, args);
    });

    socket.on("createRoom", (isPublic, callback) => {
      roomManager.createRoom({
        userId: socket.id,
        isPublic,
        callback,
      });
    });

    socket.on("joinRoom", (roomId, callback) => {
      roomManager.joinRoom({ userId: socket.id, roomId, callback });
    });

    socket.on("getPublicRooms", (callback) => {
      roomManager.getPublicRooms({
        callback,
      });
    });

    socket.on("moveToTeamA", () => {
      roomManager.moveToTeamA(socket.id);
    });

    socket.on("moveToTeamB", () => {
      roomManager.moveToTeamB(socket.id);
    });

    socket.on("changeUsername", (name) => {
      roomManager.changeUsername(socket.id, name);
    });

    socket.on("startGame", () => {
      roomManager.startGame(socket.id);
    });

    socket.on("disconnect", (reason) => {
      logger.info(`Client disconnected: id=${socket.id}, reason=${reason}`);

      roomManager.handlePlayerDisconnected(socket.id);
    });
  });

  const PORT = process.env.SERVER_PORT ?? 3000;
  httpServer.listen(PORT, () => {
    logger.info(`Server listening on port=${PORT}`);
  });
}

main();
