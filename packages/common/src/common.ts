export const GAME_NAME = "AWS Game Builder Hackathon";
export const ROOM_MAX_PLAYER_COUNT = 8;

export type GameSceneName = "initial" | "connected" | "room" | "game";

export type TeamName = "A" | "B";

export type PlayerData = {
  id: string;
  name: string;
  team: TeamName;
};

export type RoomData = {
  id: string;
  isPublic: boolean;
  ownerId: string;

  maxPlayerCount: number;
  players: PlayerData[];
};

export type PublicRoomData = {
  id: string;
  maxPlayerCount: number;
  playerCount: number;
};

export const mapRoomDataToPublicRoomData = (
  roomData: RoomData,
): PublicRoomData => ({
  id: roomData.id,
  maxPlayerCount: roomData.maxPlayerCount,
  playerCount: roomData.players.length,
});

export const SOCKET_CHANNEL_PUBLIC = "public";
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
