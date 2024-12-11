import tileset01Img from "@repo/common/assets/tilesets/tileset01.png";
import {
  type GameMapData,
  type GameSceneName,
  type JoinRoomCallback,
  type PublicRoomData,
  ROOM_MAX_PLAYER_COUNT,
  type RoomData,
} from "@repo/common/index";

interface UiScene {
  name: GameSceneName;
  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  onShow?(data?: any): void;
}

export class SceneManager {
  private scenes: UiScene[] = [];

  private gameUiContainer = document.getElementById(
    "game-ui",
  ) as HTMLDivElement;

  registerScene(scene: UiScene) {
    this.scenes.push(scene);
  }

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  showScene(sceneName: GameSceneName, data?: any) {
    for (const scene of this.scenes) {
      if (scene.name === "game") continue;
      const elm = this.getSceneElm(scene.name);
      elm.classList.remove("show");
    }

    // biome-ignore lint/style/noNonNullAssertion: <explanation>
    const scene = this.scenes.find((s) => s.name === sceneName)!;

    if (sceneName === "game") {
      this.gameUiContainer.style.display = "none";
      scene.onShow?.(data);
      return;
    }

    this.gameUiContainer.style.display = "absolute";
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
      li.innerHTML = `${room.playerCount} / ${room.maxPlayerCount}`;
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

  private publicRoomText = document.getElementById(
    "room-is-public",
  ) as HTMLSpanElement;
  private playerCountText = document.getElementById(
    "room-player-count",
  ) as HTMLSpanElement;
  private roomJoinCodeText = document.getElementById(
    "room-join-code",
  ) as HTMLSpanElement;
  private usernameText = document.getElementById(
    "room-change-username",
  ) as HTMLInputElement;
  private changeUsernameBtn = document.getElementById(
    "room-change-username-btn",
  ) as HTMLButtonElement;
  private teamAContainer = document.getElementById(
    "room-team-a-container",
  ) as HTMLUListElement;
  private teamBContainer = document.getElementById(
    "room-team-b-container",
  ) as HTMLUListElement;
  private moveToTeamABtn = document.getElementById(
    "room-move-to-team-a-btn",
  ) as HTMLButtonElement;
  private moveToTeamBBtn = document.getElementById(
    "room-move-to-team-b-btn",
  ) as HTMLButtonElement;
  private startGameBtn = document.getElementById(
    "room-start-game-btn",
  ) as HTMLButtonElement;

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

    globalThis.socket.on("roomGameStarted", () => {
      globalThis.sceneManager.showScene("game");
    });

    this.moveToTeamABtn.onclick = () => {
      globalThis.socket.emit("moveToTeamA");
    };

    this.moveToTeamBBtn.onclick = () => {
      globalThis.socket.emit("moveToTeamB");
    };

    this.changeUsernameBtn.onclick = () => {
      const username = this.usernameText.value.trim();

      if (username.length === 0) {
        alert("Please enter a username");
        return;
      }

      globalThis.socket.emit("changeUsername", username);
      this.usernameText.value = "";
    };

    this.startGameBtn.onclick = () => {
      globalThis.socket.emit("startGame");
    };
  }

  onShow(room: RoomData): void {
    this.room = room;
    console.log(`Joined room: id=${room.id}`);

    this.renderRoomInfo();
  }

  private renderRoomInfo() {
    this.publicRoomText.innerHTML = this.room.isPublic ? "Public" : "Private";
    this.playerCountText.innerHTML = `${this.room.players.length} / ${this.room.maxPlayerCount} players`;

    this.roomJoinCodeText.innerHTML = this.room.id;

    this.teamAContainer.innerHTML = "";
    this.teamBContainer.innerHTML = "";

    this.moveToTeamABtn.style.display = "none";
    this.moveToTeamBBtn.style.display = "none";
    this.startGameBtn.style.display = "none";

    const currentTeam = this.room.players.find(
      (p) => p.id === globalThis.socket.id,
    )?.team;
    const isOwner = this.room.ownerId === globalThis.socket.id;

    if (currentTeam === "A") {
      this.moveToTeamBBtn.style.display = "block";
    } else {
      this.moveToTeamABtn.style.display = "block";
    }

    if (isOwner) {
      this.startGameBtn.style.display = "block";
    }

    for (const player of this.room.players) {
      const li = document.createElement("li");

      const isCurrentPlayer = player.id === globalThis.socket.id;

      li.innerHTML = `${player.name}${isCurrentPlayer ? " (You)" : ""}`;
      if (player.team === "A") {
        this.teamAContainer.appendChild(li);
      } else {
        this.teamBContainer.appendChild(li);
      }
    }
  }
}

export class GameScene implements UiScene {
  name: GameSceneName = "game";

  private canvas = document.getElementById("app-canvas") as HTMLCanvasElement;
  private ctx = this.canvas.getContext("2d");

  private mapData: GameMapData | undefined;

  private tilesetImg: HTMLImageElement;
  private tilesPerTilesetRow: number | undefined;
  // const TILES_PER_ROW = this.tilesetImg.width / this.mapData.tileSize;

  constructor() {
    globalThis.socket.on("mapData", (mapData) => {
      this.mapData = mapData;
      this.tilesPerTilesetRow = this.tilesetImg.width / this.mapData.tileSize;

      requestAnimationFrame(() => {
        this.startDrawLoop();
      });
    });

    this.tilesetImg = new Image();
    this.tilesetImg.src = tileset01Img;
  }

  onShow() {
    console.log("showing game scene");
  }

  private startDrawLoop() {
    if (this.ctx && this.mapData) {
      this.ctx.fillStyle = "black";
      this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

      for (let r = 0; r < this.mapData.height; r++) {
        for (let c = 0; c < this.mapData.width; c++) {
          const bgTileId = this.mapData.backgroundTiles[r][c];
          const fgTileId = this.mapData.foregroundTiles[r][c];

          if (bgTileId !== 0) {
            const bgTileIndex = bgTileId - 1;
            this.drawTile(bgTileIndex, r, c);
          }
          if (fgTileId !== 0) {
            const fgTileIndex = fgTileId - 1;
            this.drawTile(fgTileIndex, r, c);
          }
        }
      }
    }

    requestAnimationFrame(() => {
      this.startDrawLoop();
    });
  }

  private drawTile(tileIdx: number, r: number, c: number) {
    if (!this.ctx || !this.mapData || !this.tilesPerTilesetRow) return;

    const tileRow = Math.floor(tileIdx / this.tilesPerTilesetRow);
    const tileCol = tileIdx % this.tilesPerTilesetRow;

    this.ctx.drawImage(
      this.tilesetImg,

      // x in tilesetImg
      tileCol * this.mapData.tileSize,
      tileRow * this.mapData.tileSize,
      this.mapData.tileSize,
      this.mapData.tileSize,

      // x on canvas
      c * this.mapData.tileSize,
      r * this.mapData.tileSize,
      this.mapData.tileSize,
      this.mapData.tileSize,
    );
  }
}
