import { MapSchema,Schema, Context, type } from "@colyseus/schema";

export class OtherPlayer extends Schema {
  @type("number") x: number;
  @type("number") y: number;
  @type("number") z: number;
  @type("number") angle: number;
  @type("number") muted: number;
  @type("number") curchannel: number;
  @type("string") key: string;
  @type("string") mc: string;
  @type("string") standingOn: string;
}

export class MyRoomState extends Schema {

  @type({ map: OtherPlayer }) players = new MapSchema<OtherPlayer>();

}
