package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.colyseus.Client;
import io.colyseus.Room;
import io.colyseus.error.HttpException;
import lime.utils.Float32Array;

class PlayState extends FlxState
{
	public static var roome:Room<MyRoomState>;

	var client = new Client(MenuState.ip);
	var mic:Microphone;
	var plr:NetPlayer = new NetPlayer();

	var otherPlayers:FlxTypedGroup<NetPlayer> = new FlxTypedGroup<NetPlayer>();

	public static var plrx = 0;
	public static var plry = 0;
	public static var plrz = 0;

	override public function create()
	{
		new FlxTimer().start(1, (tmr) ->
		{
			mic = Microphone.getMicrophone(-1);
		});

		FlxG.camera.follow(plr);
		plr.makeGraphic(16, 16, FlxColor.GREEN);
		super.create();
		add(plr);
		client.joinById("myRoom", [], MyRoomState, function(err, room)
		{
			roome = room;
			epic(err, room);
		});
	}

	function epic(err:HttpException, room:Room<MyRoomState>)
	{
		roome = room;
		if (err != null)
		{
			trace("JOIN ERROR: " + err);
			return;
		}
		room.state.players.onAdd((item, k) ->
		{
			if (k != room.sessionId)
			{
				var op:NetPlayer = new NetPlayer();
				otherPlayers.add(op);
				op.key = k;
				item.listen("x", (c, p) ->
				{
					op.x = c;
				});
				item.listen("y", (c, p) ->
				{
					op.y = c;
				});
				item.listen("z", (c, p) ->
				{
					op.z = c;
				});
			}
		});
		room.onMessage("voiceChat", function(x)
		{
			if (x.sessionId == roome.sessionId)
			{
				return;
			}
			// Convert string to array of numbers
			var s:String = x.input;
			var dataArray:Array<String> = s.split(",");
			var floatArray:Array<Float> = dataArray.map(Std.parseFloat);

			// Convert array of numbers to Float32Array
			var float32Array:Float32Array = new Float32Array(floatArray);
			var distance = calculateDistance(plr.x, plr.y, x.x, x.y, plr.z, x.z);
			var maxDistance = 1000.0; // Adjust this value based on your scene scale
			var volume = 1.0 - (distance / maxDistance); // Invert volume based on distance

			for (oplr in otherPlayers)
			{
				if (oplr.key == x.sessionId)
				{
					trace("b");
					mic.playAudio(float32Array, volume, oplr.source, x.x, x.y, x.z);
				}
			}
		});
	}

	function calculateDistance(x1:Float, y1:Float, x2:Float, y2:Float, z1, z2):Float
	{
		var dx = x2 - x1;
		var dy = y2 - y1;
		var dz = z2 - z1;
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
