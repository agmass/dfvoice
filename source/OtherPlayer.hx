// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.27
// 


import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class OtherPlayer extends Schema {
	@:type("number")
	public var x: Dynamic = 0;

	@:type("number")
	public var y: Dynamic = 0;

	@:type("number")
	public var z: Dynamic = 0;

	@:type("number")
	public var angle: Dynamic = 0;

	@:type("number")
	public var muted: Dynamic = 0;

	@:type("number")
	public var curchannel: Dynamic = 0;

	@:type("string")
	public var key: String = "";

	@:type("string")
	public var mc: String = "";

	@:type("string")
	public var standingOn: String = "";

}
