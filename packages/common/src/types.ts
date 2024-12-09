export type RawLayerData = {
  id: number;
  name: string;

  width: number;
  height: number;

  data: number[][];
};

export type RawMapData = {
  width: number;
  height: number;
  tilewidth: number;
  tileheight: number;
  layers: RawLayerData[];
};
