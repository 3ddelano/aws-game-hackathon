import {
  type CreateRoomCallback,
  type GetPublicRoomCallback,
  type JoinRoomCallback,
  type PlayerData,
  ROOM_MAX_PLAYER_COUNT,
  type RoomData,
  SOCKET_CHANNEL_PUBLIC,
  type SocketChannelsType,
  type TeamName,
  mapRoomDataToPublicRoomData,
} from "@repo/common/common";
import { logger } from "@repo/common/logger";
import { customAlphabet } from "nanoid";

const nanoid = customAlphabet(
  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
  8,
);

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
      id: nanoid(),
      isPublic: isPublic,
      maxPlayerCount: ROOM_MAX_PLAYER_COUNT,
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

    const userSocket = globalThis.io.sockets.sockets.get(userId);

    userSocket?.leave(SOCKET_CHANNEL_PUBLIC);

    callback(room);

    globalThis.io.in(channelName).emit("roomPlayerJoined", playerData);
    userSocket?.join(channelName);

    if (room.isPublic) {
      if (room.players.length === room.maxPlayerCount) {
        globalThis.io
          .in(SOCKET_CHANNEL_PUBLIC)
          .emit("publicRoomDeleted", room.id);
      } else {
        globalThis.io
          .in(SOCKET_CHANNEL_PUBLIC)
          .emit("publicRoomUpdated", mapRoomDataToPublicRoomData(room));
      }
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

  public moveToTeamA(userId: string) {
    this.moveToTeam(userId, "A");
  }

  public moveToTeamB(userId: string) {
    this.moveToTeam(userId, "B");
  }

  public changeUsername(userId: string, name: string) {
    const room = this.rooms.find((r) => r.players.find((p) => p.id === userId));
    if (!room) return;

    const player = room.players.find((p) => p.id === userId);
    if (!player) return;

    player.name = name;

    const channelName: SocketChannelsType = `room_${room.id}`;
    globalThis.io.in(channelName).emit("roomPlayerUpdated", player);
  }

  public startGame(userId: string) {
    const room = this.rooms.find((r) => r.players.find((p) => p.id === userId));
    if (!room) return;

    const player = room.players.find((p) => p.id === userId);
    if (!player || player.id !== room.ownerId) return;

    const channelName: SocketChannelsType = `room_${room.id}`;
    globalThis.io.in(channelName).emit("roomGameStarted");
    
    for (const player of room.players) {
      globalThis.io.sockets.sockets.get(player.id)?.leave(channelName);
    }
  }

  public handlePlayerDisconnected(userId: string) {
    const room = this.rooms.find((r) => r.players.find((p) => p.id === userId));
    if (!room) return;

    const playerCountPrev = room.players.length;
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
      if (
        playerCountPrev === room.maxPlayerCount &&
        room.players.length < playerCountPrev
      ) {
        globalThis.io
          .in(SOCKET_CHANNEL_PUBLIC)
          .emit("publicRoomCreated", mapRoomDataToPublicRoomData(room));
      } else {
        globalThis.io
          .in(SOCKET_CHANNEL_PUBLIC)
          .emit("publicRoomUpdated", mapRoomDataToPublicRoomData(room));
      }
    }
  }

  private moveToTeam(userId: string, teamName: TeamName) {
    const room = this.rooms.find((r) => r.players.find((p) => p.id === userId));
    if (!room) return;

    const player = room.players.find((p) => p.id === userId);
    if (!player) return;

    player.team = teamName;

    room.players = room.players.map((p) => {
      if (p.id === userId) {
        return player;
      }
      return p;
    });

    const channelName: SocketChannelsType = `room_${room.id}`;
    globalThis.io.in(channelName).emit("roomPlayerUpdated", player);
  }
}
