export * from "./types";
export const GAME_NAME = "AWS Game Builder Hackathon";

export type GameSceneName = "initial" | "connected" | "room" | "game";

export type PlayerData = {
  id: string;
  name: string;
};

export type RoomData = {
  id: string;
  isPublic: boolean;
  ownerId: string;

  maxPlayerCount: number;
  players: PlayerData[];
};

export interface ClientToServerEvents {
  getPublicRooms: () => void;
  createRoom: (isPublic: boolean) => void;
  joinRoom: (roomId: string) => void;
}

export interface ServerToClientEvents {
  roomCreated(roomData: RoomData): void;

  joinRoomFailed: (msg: string) => void;
  roomJoined(roomData: RoomData): void;
  publicRooms(rooms: RoomData[]): void;
}
