import type {
  GameMapData,
  PublicRoomData,
  RoomData,
  RoomPlayerData,
  SOCKET_CHANNEL_PUBLIC,
} from "./common";

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

  // While in room
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
  roomPlayerJoined(playerData: RoomPlayerData): void;
  roomPlayerUpdated(playerData: RoomPlayerData): void;
  roomPlayerLeft(playerId: string): void;
  roomOwnerChanged(newOwnerId: string): void;
  roomGameStarted(): void;

  // Sent to a user when joining a game
  mapData(data: GameMapData): void;
  // Sent to the game channel
}
