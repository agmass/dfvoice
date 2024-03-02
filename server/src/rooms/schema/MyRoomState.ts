import { MapSchema,Schema, Context, type } from "@colyseus/schema";

export class OtherPlayer extends Schema {
  @type("number") x: number;
  @type("number") y: number;
  @type("number") z: number;
  @type("string") key: string;
  @type("string") mc: string;
}

export class MyRoomState extends Schema {

  @type({ map: OtherPlayer }) players = new MapSchema<OtherPlayer>();

}
