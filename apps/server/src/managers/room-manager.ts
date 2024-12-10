import {
  type CreateRoomCallback,
  type GetPublicRoomCallback,
  type JoinRoomCallback,
  type PlayerData,
  type PublicRoomCallback,
  type PublicRoomData,
  type RoomData,
  SOCKET_CHANNEL_PUBLIC,
  type SocketChannelsType,
  mapRoomDataToPublicRoomData,
} from "@repo/common/common";
import { logger } from "@repo/common/logger";
import { nanoid } from "nanoid";

export class RoomManager {
  private rooms: RoomData[] = [];

  public createRoom({
    userId,
    isPublic,
    callback,
  }: {
    userId: string;
    isPublic: boolean;
    callback: CreateRoomCallback;
  }) {
    const roomData: RoomData = {
      id: nanoid(6),
      isPublic: isPublic,
      maxPlayerCount: 8,
      ownerId: userId,
      players: [
        {
          id: userId,
          name: "Player 1",
          team: "A",
        },
      ],
    };
    this.rooms.push(roomData);

    const channelName: SocketChannelsType = `room_${roomData.id}`;
    globalThis.io.sockets.sockets.get(userId)?.join(channelName);
    globalThis.io.sockets.sockets.get(userId)?.leave(SOCKET_CHANNEL_PUBLIC);

    // Notify user of the new room
    callback(roomData);

    if (isPublic) {
      globalThis.io
        .in(SOCKET_CHANNEL_PUBLIC)
        .emit("publicRoomCreated", mapRoomDataToPublicRoomData(roomData));
    }
  }

  public joinRoom({
    userId,
    roomId,
    callback,
  }: {
    userId: string;
    roomId: string;
    callback: JoinRoomCallback;
  }) {
    const room = this.rooms.find((r) => r.id === roomId);
    if (!room) {
      callback({ error: "Room not found." });
      return;
    }

    if (room.players.length >= room.maxPlayerCount) {
      callback({ error: "Room is full." });
      return;
    }

    const teamCounts = room.players.reduce(
      (acc, p) => {
        acc[p.team] += 1;
        return acc;
      },
      { A: 0, B: 0 },
    );

    const playerData: PlayerData = {
      id: userId,
      name: `Player ${room.players.length + 1}`,
      team: teamCounts.A < teamCounts.B ? "A" : "B",
    };
    room.players.push(playerData);

    const channelName: SocketChannelsType = `room_${room.id}`;
    globalThis.io.sockets.sockets.get(userId)?.join(channelName);
    globalThis.io.sockets.sockets.get(userId)?.leave(SOCKET_CHANNEL_PUBLIC);

    callback(room);

    // Emit player joined to the room
    globalThis.io.in(channelName).emit("roomPlayerJoined", playerData);

    if (room.isPublic) {
      globalThis.io
        .in(SOCKET_CHANNEL_PUBLIC)
        .emit("publicRoomUpdated", mapRoomDataToPublicRoomData(room));
    }
  }

  public getPublicRooms({
    callback,
  }: {
    callback: GetPublicRoomCallback;
  }) {
    const publicRooms = this.rooms.filter(
      (r) => r.isPublic && r.players.length < r.maxPlayerCount,
    );

    callback(publicRooms.map(mapRoomDataToPublicRoomData));
  }

  public handlePlayerDisconnected(userId: string) {
    const room = this.rooms.find((r) => r.players.find((p) => p.id === userId));
    if (!room) return;

    room.players = room.players.filter((p) => p.id !== userId);

    const channelName: SocketChannelsType = `room_${room.id}`;
    globalThis.io.in(channelName).emit("roomPlayerLeft", userId);

    if (room.players.length === 0) {
      logger.info(`Deleting room: id=${room.id}, isPublic=${room.isPublic}`);
      if (room.isPublic) {
        globalThis.io
          .in(SOCKET_CHANNEL_PUBLIC)
          .emit("publicRoomDeleted", room.id);
      }
      this.rooms.splice(this.rooms.indexOf(room), 1);
      return;
    }

    if (room.ownerId === userId) {
      logger.info(
        `Assigning new room owner: roomId=${room.id}, isPublic=${room.isPublic}`,
      );
      const newOwnerId = room.players[0]?.id;
      if (newOwnerId) {
        room.ownerId = newOwnerId;
        globalThis.io.in(channelName).emit("roomOwnerChanged", newOwnerId);
      }
    }

    if (room.isPublic) {
      globalThis.io
        .in(SOCKET_CHANNEL_PUBLIC)
        .emit("publicRoomUpdated", mapRoomDataToPublicRoomData(room));
    }
  }
}
