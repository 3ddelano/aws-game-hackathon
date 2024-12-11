export const GAME_NAME = "AWS Game Builder Hackathon";
export const ROOM_MAX_PLAYER_COUNT = 8;
export const SOCKET_CHANNEL_PUBLIC = "public";

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
