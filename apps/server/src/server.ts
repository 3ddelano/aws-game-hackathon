import { createServer } from "node:http";
import type {
  ClientToServerEvents,
  RawMapData,
  RoomData,
  ServerToClientEvents,
} from "@repo/common";
import level01Data from "@repo/common/assets/maps/level01.json";
import { logger } from "@repo/common/logger";
import express from "express";
import { nanoid } from "nanoid";
import * as socketio from "socket.io";

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
  // Load map
  const map = new GameMap(level01Data);

  const app = express();
  const httpServer = createServer(app);
  const io = new socketio.Server<ClientToServerEvents, ServerToClientEvents>(
    httpServer,
    {
      cors: {
        origin: "*",
        methods: ["GET", "POST"],
      },
    },
  );

  const rooms: RoomData[] = [];

  io.on("connection", (socket) => {
    console.log(`New client connected ${socket.id}`);

    socket.onAny((eventName, ...args) => {
      console.log("Got event: ", eventName, args);
    });

    socket.on("createRoom", (isPublic) => {
      const roomData = {
        id: nanoid(6),
        isPublic: isPublic,
        maxPlayerCount: 8,
        ownerId: socket.id,
        players: [
          {
            id: socket.id,
            name: "Player 1",
          },
        ],
      };
      rooms.push(roomData);
      socket.emit("roomCreated", roomData);
      io.emit(
        "publicRooms",
        rooms.filter((r) => r.isPublic),
      );
    });

    socket.on("getPublicRooms", () => {
      socket.emit(
        "publicRooms",
        rooms.filter((r) => r.isPublic),
      );
    });

    socket.on("joinRoom", (roomCode) => {
      const room = rooms.find((r) => r.id === roomCode);
      if (!room) {
        socket.emit("joinRoomFailed", "Room not found.");
        return;
      }

      if (room.players.length === room.maxPlayerCount) {
        socket.emit("joinRoomFailed", "Room is full.");
        return;
      }

      room.players.push({
        id: socket.id,
        name: `Player ${room.players.length + 1}`,
      });

      for (const player of room.players) {
        const playerSocket = io.sockets.sockets.get(player.id);
        if (!playerSocket) continue;

        playerSocket.emit("roomJoined", room);
      }
    });

    socket.on("disconnect", () => {
      console.log("Client disconnected!");

      // remove the player from room, and if room is empty then remove the room
      for (let i = 0; i < rooms.length; i++) {
        const room = rooms[i];
        const index = room.players.findIndex((p) => p.id === socket.id);
        if (index === -1) continue;

        room.players.splice(index, 1);
        if (room.players.length === 0) {
          rooms.splice(i, 1);
        }
        io.emit(
          "publicRooms",
          rooms.filter((r) => r.isPublic),
        );
        break;
      }
    });
  });

  // Listen for connections
  const PORT = process.env.SERVER_PORT ?? 3000;
  httpServer.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });
}

main();
