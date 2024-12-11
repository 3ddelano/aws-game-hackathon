import { Player } from "@/entities/player";
import { GAME_DURATION_MS, type RoomPlayerData } from "@repo/common";
import type {
  ClientToServerEvents,
  ServerToClientEvents,
  SocketChannelsType,
} from "@repo/common/events";
import type { Socket } from "socket.io";
import { MapManager } from "./map-manager";

export class GameSession {
  private id: string;

  private timeLeftMs: number;
  private gameEndTimerId: NodeJS.Timer;

  private sockets: Socket<ServerToClientEvents, ClientToServerEvents>[] = [];
  private players: Player[] = [];

  private mapManager = MapManager.getInstance();
  private mapId = 0; // we only have 1 map

  constructor(id: string) {
    this.id = id;
    this.timeLeftMs = GAME_DURATION_MS;

    const onGameEndTimer = () => {
      console.log(`Game has ended: id=${this.id}`);
    };

    this.gameEndTimerId = setTimeout(onGameEndTimer, GAME_DURATION_MS);
  }

  public tick(deltaMs: number) {
    const gameChannelName: SocketChannelsType = `game_${this.id}`;
    this.timeLeftMs -= deltaMs;
  }

  public onPlayerConnected(
    socket: Socket<ClientToServerEvents, ServerToClientEvents>,
    roomPlayerData: RoomPlayerData,
  ) {
    this.sockets.push(socket);

    const player = new Player(roomPlayerData, this.mapManager);
    this.players.push(player);

    const gameChannelName: SocketChannelsType = `game_${this.id}`;

    socket.emit("mapData", this.mapManager.getMapData(this.mapId));
    
    // globalThis.io.sockets.sockets.get(`game_${this.id}`)?.emit("gamePlayerJoined")
  }
}
