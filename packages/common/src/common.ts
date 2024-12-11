export const GAME_NAME = "AWS Game Builder Hackathon";
export const ROOM_MAX_PLAYER_COUNT = 8;
export const SOCKET_CHANNEL_PUBLIC = "public";
export const TICK_RATE = 20;
export const GAME_DURATION_MS = 5 * 60 * 1000;

export type GameSceneName = "initial" | "connected" | "room" | "game";

export type TeamName = "A" | "B";

export type RoomPlayerData = {
  id: string;
  name: string;
  team: TeamName;
  // TODO: character sprite
};

export type RoomData = {
  id: string;
  isPublic: boolean;
  ownerId: string;

  maxPlayerCount: number;
  players: RoomPlayerData[];
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

export class Vector2 {
  x: number;
  y: number;

  constructor(obj?: { x?: number; y?: number }) {
    this.x = obj?.x ?? 0;
    this.y = obj?.y ?? 0;
  }

  normalize() {
    const length = Math.sqrt(this.x * this.x + this.y * this.y);
    this.x /= length;
    this.y /= length;
  }

  multiply(scalar: number) {
    this.x *= scalar;
    this.y *= scalar;
  }

  add(vector: Vector2) {
    this.x += vector.x;
    this.y += vector.y;
  }

  subtract(vector: Vector2) {
    this.x -= vector.x;
    this.y -= vector.y;
  }
}

export interface Entity {
  tick(deltaMs: number): void;
}

export class Rect2 {
  x: number;
  y: number;
  w: number;
  h: number;

  constructor(obj?: { x?: number; y?: number; w?: number; h?: number }) {
    this.x = obj?.x ?? 0;
    this.y = obj?.y ?? 0;
    this.w = obj?.w ?? 0;
    this.h = obj?.h ?? 0;
  }

  isColliding(rect: Rect2) {
    return (
      this.x < rect.x + rect.w &&
      this.x + this.w > rect.x &&
      this.y < rect.y + rect.h &&
      this.y + this.h > rect.y
    );
  }
}

export interface Positionable {
  getPosition(): Vector2;
  setPosition(pos: Vector2): void;
}

export interface Collidable {
  getHitbox(): Rect2;
}

export const MOVE_UP = 0b0001 as const;
export const MOVE_DOWN = 0b0010 as const;
export const MOVE_LEFT = 0b0100 as const;
export const MOVE_RIGHT = 0b1000 as const;
export const MOVE_NONE = 0b0000 as const;
export type MoveInput = 0b0001 | 0b0010 | 0b0100 | 0b1000 | 0b0000;

export class GameMapData {
  readonly backgroundTiles: number[][];
  readonly foregroundTiles: number[][];
  readonly staticCollisionRects: Rect2[] = [];
  readonly tileSize: number;
  readonly width: number;
  readonly height: number;

  constructor(data: {
    backgroundTiles: number[][];
    foregroundTiles: number[][];
    staticCollisionRects: Rect2[];
    tileSize: number;
    width: number;
    height: number;
  }) {
    this.backgroundTiles = data.backgroundTiles;
    this.foregroundTiles = data.foregroundTiles;
    this.staticCollisionRects = data.staticCollisionRects;
    this.tileSize = data.tileSize;
    this.width = data.width;
    this.height = data.height;
  }
}
