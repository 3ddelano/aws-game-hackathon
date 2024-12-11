import { createServer } from "node:http";
import {
  type ClientToServerEvents,
  SOCKET_CHANNEL_PUBLIC,
  type ServerToClientEvents,
  TICK_RATE,
} from "@repo/common";
import { logger } from "@repo/common/logger";
import express from "express";
import * as socketio from "socket.io";
import type { GameSession } from "./managers/game-session";
import { MapManager } from "./managers/map-manager";
import { RoomManager } from "./managers/room-manager";

async function main() {
  logger.info("Starting game server...");

  logger.info("Loading maps...");
  MapManager.getInstance();

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
  const gameSessions: GameSession[] = [];

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
      const gameSession = roomManager.startGame(socket.id);
      if (gameSession) {
        gameSessions.push(gameSession);
      }
    });

    socket.on("disconnect", (reason) => {
      logger.info(`Client disconnected: id=${socket.id}, reason=${reason}`);

      roomManager.handlePlayerDisconnected(socket.id);
    });
  });

  const PORT = process.env.SERVER_PORT ?? 3005;
  httpServer.listen(PORT, () => {
    logger.info(`Server listening on port=${PORT}`);
  });

  // Main game loop
  logger.info(
    `Started game loop at ${TICK_RATE}ticks/second (${1000 / TICK_RATE}ms/tick)`,
  );
  let currentMs = Date.now();
  setInterval(() => {
    const startMs = Date.now();
    const deltaMs = startMs - currentMs;
    for (const session of gameSessions) {
      session.tick(deltaMs);
    }
    currentMs = Date.now();
    const elapsedMs = Date.now() - startMs;
    if (elapsedMs > 1000 / TICK_RATE) {
      logger.info(`Tick took too long: ${elapsedMs}ms`);
    }
  }, 1000 / TICK_RATE);
}

main();
