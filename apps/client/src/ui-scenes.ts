import type {
  GameSceneName,
  JoinRoomCallback,
  PublicRoomData,
  RoomData,
} from "@repo/common/index";

interface UiScene {
  name: GameSceneName;
  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  onShow?(data?: any): void;
}

export class SceneManager {
  private scenes: UiScene[] = [];

  registerScene(scene: UiScene) {
    this.scenes.push(scene);
  }

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  showScene(sceneName: GameSceneName, data?: any) {
    for (const scene of this.scenes) {
      const elm = this.getSceneElm(scene.name);
      elm.classList.remove("show");
    }
    // biome-ignore lint/style/noNonNullAssertion: <explanation>
    const scene = this.scenes.find((s) => s.name === sceneName)!;
    const elm = this.getSceneElm(scene.name);
    elm.classList.add("show");
    scene.onShow?.(data);
  }

  private getSceneElm(sceneName: GameSceneName) {
    const elm = document.getElementById(`game-scene-${sceneName}`);
    if (!elm) {
      throw new Error(`Could not find scene element with name: ${sceneName}`);
    }
    return elm;
  }
}

export class InitialUiScene implements UiScene {
  public name: GameSceneName = "initial";
  private msg = document.getElementById(
    "initial-message",
  ) as HTMLParagraphElement;

  setMessage(msg: string) {
    this.msg.innerHTML = msg;
  }
}

export class ConnectedUiScene implements UiScene {
  public name: GameSceneName = "connected";

  private createRoomBtn = document.getElementById(
    "create-room-btn",
  ) as HTMLButtonElement;
  private createRoomIsPublic = document.getElementById(
    "create-room-is-public",
  ) as HTMLInputElement;
  private joinRoomId = document.getElementById(
    "join-room-id",
  ) as HTMLInputElement;
  private joinRoomBtn = document.getElementById(
    "join-room-btn",
  ) as HTMLButtonElement;

  private publicRoomsContainer = document.getElementById(
    "public-rooms-container",
  ) as HTMLUListElement;

  private publicRooms: PublicRoomData[] = [];

  constructor() {
    this.createRoomBtn.addEventListener("click", () => {
      console.log("Creating room");
      const isPublic = this.createRoomIsPublic.checked;
      globalThis.socket.emit("createRoom", isPublic, (createdRoom) => {
        globalThis.sceneManager.showScene("room", createdRoom);
      });
    });

    this.joinRoomBtn.addEventListener("click", () => {
      const roomId = this.joinRoomId.value.trim();
      console.log("Joining room with code: ", roomId);
      globalThis.socket.emit("joinRoom", roomId, this.joinRoomCallback);
    });

    globalThis.socket.on("publicRoomCreated", (room) => {
      this.publicRooms.push(room);
      this.renderPublicRooms();
    });

    globalThis.socket.on("publicRoomUpdated", (room) => {
      this.publicRooms = this.publicRooms.map((r) => {
        if (r.id === room.id) {
          return room;
        }
        return r;
      });
      this.renderPublicRooms();
    });

    globalThis.socket.on("publicRoomDeleted", (roomId) => {
      this.publicRooms = this.publicRooms.filter((r) => r.id !== roomId);
      this.renderPublicRooms();
    });
  }

  onShow?() {
    console.log("Loading public rooms");
    globalThis.socket.emit("getPublicRooms", (rooms) => {
      this.publicRooms = rooms;
      this.renderPublicRooms();
    });
  }

  private renderPublicRooms() {
    this.publicRoomsContainer.innerHTML = "";

    if (this.publicRooms.length === 0) {
      this.publicRoomsContainer.innerHTML = "No public rooms";
    }

    for (const room of this.publicRooms) {
      const li = document.createElement("li");
      const btn = document.createElement("button");
      btn.classList.add("secondary");
      btn.innerHTML = "Join";
      btn.onclick = () => {
        globalThis.socket.emit("joinRoom", room.id, this.joinRoomCallback);
      };
      li.innerHTML = `${room.playerCount} / ${room.maxPlayerCount} players`;
      li.appendChild(btn);
      this.publicRoomsContainer.appendChild(li);
    }
  }

  private joinRoomCallback(resp: Parameters<JoinRoomCallback>[0]) {
    if ("error" in resp) {
      alert(resp.error);
      return;
    }
    globalThis.sceneManager.showScene("room", resp);
  }
}

export class RoomScene implements UiScene {
  public name: GameSceneName = "room";

  private room!: RoomData;

  private roomDataElm = document.getElementById(
    "room-data",
  ) as HTMLParagraphElement;

  constructor() {
    globalThis.socket.on("roomPlayerJoined", (playerData) => {
      this.room.players.push(playerData);
      this.renderRoomInfo();
    });
    globalThis.socket.on("roomPlayerUpdated", (playerData) => {
      this.room.players = this.room.players.map((p) => {
        if (p.id === playerData.id) {
          return playerData;
        }
        return p;
      });
      this.renderRoomInfo();
    });
    globalThis.socket.on("roomPlayerLeft", (playerId) => {
      this.room.players = this.room.players.filter((p) => p.id !== playerId);
      this.renderRoomInfo();
    });
    globalThis.socket.on("roomOwnerChanged", (newOwnerId) => {
      this.room.ownerId = newOwnerId;
      this.renderRoomInfo();
    });
  }

  onShow(room: RoomData): void {
    this.room = room;
    console.log("joined room!", room);

    this.renderRoomInfo();
  }

  private renderRoomInfo() {
    this.roomDataElm.innerHTML = JSON.stringify(this.room, null, 2);
  }
}
