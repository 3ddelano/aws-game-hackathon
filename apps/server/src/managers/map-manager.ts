import level01Data from "@repo/common/assets/maps/level01.json";
import { type Collidable, GameMapData, Rect2 } from "@repo/common/common";
import type { RawMapData } from "@repo/common/types";

export class MapManager {
  private maps: GameMapData[] = [];

  public static instance: MapManager;

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  private constructor(json: any) {
    if ((json as { type?: string })?.type !== "map") {
      throw new Error(`Could not create MapManager: Invalid map json: ${json}`);
    }

    const rawData = {
      ...(json as object),
      // biome-ignore lint/suspicious/noExplicitAny: <explanation>
      layers: json.layers.map((layer: any) => ({
        ...layer,
        data: layer.data.reduce((acc: number[][], elm: number, i: number) => {
          const row = Math.floor(i / layer.width);
          if (!acc[row]) {
            acc[row] = [];
          }
          acc[row].push(elm);
          return acc;
        }, [] as number[][]),
      })),
    } as RawMapData;

    const backgroundLayer = rawData.layers.find((l) => l.name === "background");
    const foregroundLayer = rawData.layers.find((l) => l.name === "foreground");
    const collisionLayer = rawData.layers.find((l) => l.name === "collision");

    if (!backgroundLayer) {
      throw new Error(
        "Could not create MapManager: 'background' layer not found.",
      );
    }

    if (!foregroundLayer) {
      throw new Error(
        "Could not create MapManager: 'foreground' layer not found.",
      );
    }

    if (!collisionLayer) {
      throw new Error(
        "Could not create MapManager: 'collision' layer not found.",
      );
    }

    const staticCollisionRects: Rect2[] = [];
    for (let r = 0; r < collisionLayer.data.length; r++) {
      for (let c = 0; c < collisionLayer.data[r].length; c++) {
        if (collisionLayer.data[r][c] === 0) continue;

        staticCollisionRects.push(
          new Rect2({
            x: c * rawData.tilewidth,
            y: r * rawData.tileheight,
            w: rawData.tilewidth,
            h: rawData.tileheight,
          }),
        );
      }
    }

    const map1 = new GameMapData({
      backgroundTiles: backgroundLayer.data,
      foregroundTiles: foregroundLayer.data,
      staticCollisionRects,
      tileSize: rawData.tilewidth,
      width: backgroundLayer.width,
      height: backgroundLayer.height,
    });

    this.maps.push(map1);
  }

  public static getInstance() {
    if (!MapManager.instance) {
      MapManager.instance = new MapManager(level01Data);
    }
    return MapManager.instance;
  }

  public isColliding(mapId: number, collidable: Collidable) {
    const map = this.maps[mapId];
    for (const collisionRect of map.staticCollisionRects) {
      if (collisionRect.isColliding(collidable.getHitbox())) return true;
    }
    return false;
  }

  public getMapData(mapIdx: number) {
    return this.maps[mapIdx];
  }
}
