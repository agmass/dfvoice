// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.27
// 


import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class MyRoomState extends Schema {
	@:type("map", OtherPlayer)
	public var players: MapSchema<OtherPlayer> = new MapSchema<OtherPlayer>();

}
