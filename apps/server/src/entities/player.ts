import type { MapManager } from "@/managers/map-manager";
import {
  type Collidable,
  type Entity,
  MOVE_DOWN,
  MOVE_LEFT,
  MOVE_NONE,
  MOVE_RIGHT,
  MOVE_UP,
  type MoveInput,
  type Positionable,
  Rect2,
  type RoomPlayerData,
  Vector2,
} from "@repo/common/common";

export class Player implements Entity, Positionable, Collidable {
  private roomPlayerData: RoomPlayerData;
  private mapManager: MapManager;

  private position = new Vector2();
  private moveInput: MoveInput = MOVE_NONE;

  static speed = 2;
  static collisionHitbox = new Rect2({ x: 0, y: 0, w: 32, h: 32 });

  constructor(roomPlayerData: RoomPlayerData, mapManager: MapManager) {
    this.roomPlayerData = roomPlayerData;
    this.mapManager = mapManager;
  }

  tick(deltaMs: number) {
    const prevPosition = this.position;

    const moveVec = new Vector2({
      x: this.moveInput & MOVE_LEFT ? -1 : this.moveInput & MOVE_RIGHT ? 1 : 0,
      y: this.moveInput & MOVE_UP ? -1 : this.moveInput & MOVE_DOWN ? 1 : 0,
    });

    moveVec.multiply(Player.speed * deltaMs);

    this.position.add(moveVec);

    if (this.mapManager.isColliding(this)) {
      this.position = prevPosition;
    }
  }

  getPosition() {
    return this.position;
  }

  setPosition(newPosition: Vector2) {
    this.position = newPosition;
  }

  getHitbox() {
    return Player.collisionHitbox;
  }

  setMoveInput(newInput: MoveInput) {
    this.moveInput = newInput;
  }
}
