import type { GameSceneName, RoomData } from "@repo/common/index";

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

  private publicRooms: RoomData[] = [];

  constructor() {
    globalThis.socket.on("roomCreated", (room) => {
      console.log("Room created!");
      globalThis.sceneManager.showScene("room", room);
    });
    globalThis.socket.on("roomJoined", (room) => {
      console.log("Room joined!");
      globalThis.sceneManager.showScene("room", room);
    });

    this.createRoomBtn.addEventListener("click", () => {
      console.log("Creating room");
      const isPublic = this.createRoomIsPublic.checked;
      globalThis.socket.emit("createRoom", isPublic);
    });

    this.joinRoomBtn.addEventListener("click", () => {
      const roomId = this.joinRoomId.value.trim();
      console.log("Joining room with code: ", roomId);
      globalThis.socket.emit("joinRoom", roomId);
    });
  }

  onShow?() {
    console.log("Loading public rooms");
    globalThis.socket.on("publicRooms", (rooms) => {
      this.publicRooms = rooms;
      this.renderPublicRooms();
    });
    globalThis.socket.emit("getPublicRooms");
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
        globalThis.socket.emit("joinRoom", room.id);
      };
      li.innerHTML = `${room.players.length} / ${room.maxPlayerCount} players`;
      li.appendChild(btn);
      this.publicRoomsContainer.appendChild(li);
    }
  }
}

export class RoomScene implements UiScene {
  public name: GameSceneName = "room";

  private roomDataElm = document.getElementById(
    "room-data",
  ) as HTMLParagraphElement;

  onShow(room: RoomData): void {
    console.log("joined room!", room);

    this.roomDataElm.innerHTML = JSON.stringify(room, null, 2);
  }
}
