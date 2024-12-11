import type { PlayerData, PublicRoomData, RoomData } from "./common";

export type SocketChannelsType =
  | typeof SOCKET_CHANNEL_PUBLIC
  | `room_${string}`
  | `game_${string}`;

export type GetPublicRoomCallback = (data: PublicRoomData[]) => void;
export type CreateRoomCallback = (data: RoomData) => void;
export type JoinRoomCallback = (data: RoomData | { error: string }) => void;

export interface ClientToServerEvents {
  // Called initially when the client connects to the server
  getPublicRooms: (callback: GetPublicRoomCallback) => void;

  createRoom: (isPublic: boolean, callback: CreateRoomCallback) => void;
  joinRoom: (roomId: string, callback: JoinRoomCallback) => void;
  moveToTeamA: () => void;
  moveToTeamB: () => void;
  changeUsername: (name: string) => void;
  startGame: () => void;
}

export interface ServerToClientEvents {
  // Sent to the public channel
  publicRoomCreated(roomData: PublicRoomData): void;
  publicRoomUpdated(roomData: PublicRoomData): void;
  publicRoomDeleted(roomId: string): void;

  // Sent to the room channel
  roomPlayerJoined(playerData: PlayerData): void;
  roomPlayerUpdated(playerData: PlayerData): void;
  roomPlayerLeft(playerId: string): void;
  roomOwnerChanged(newOwnerId: string): void;
  roomGameStarted(): void;
}
