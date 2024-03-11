package;

import Microphone.AudioCompression;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.crypto.BaseCode;
import haxe.io.Bytes;
import haxe.ui.Toolkit;
import haxe.ui.components.HorizontalSlider;
import io.colyseus.Client;
import io.colyseus.Room;
import io.colyseus.error.HttpException;
import lime.utils.Float32Array;
import openfl.display.BitmapData;

class PlayState extends FlxState
{
	public static var roome:Room<MyRoomState>;

	var client = new Client(MenuState.ip);
	var mic:Microphone;

	public static var timesincelast = 0.0;

	var q:Array<Float32Array> = [];
	var sliders:FlxSpriteGroup = new FlxSpriteGroup();

	public static var mintime = 0.8;

	var plr:NetPlayer = new NetPlayer();
	var channel:Int = 0;

	var otherPlayers:FlxTypedGroup<NetPlayer> = new FlxTypedGroup<NetPlayer>();

	public static var plrx = 0.0;
	public static var plry = 0.0;
	public static var ttr = 0.0;

	var standing:FlxSprite = new FlxSprite();

	public static var sendOut = true;

	public var timeSinceLastPacket:Float = 0;

	var button:FlxButton = new FlxButton(FlxG.width - 120, 20, "Mute Mic", () ->
	{
		sendOut = !sendOut;
	});

	public static var plrz = 0.0;
	public static var plrang = 0.0;

	var connected:FlxText = new FlxText();

	override public function create()
	{
		standing.alpha = 0;
		connected.scrollFactor.set();
		new FlxTimer().start(1, (tmr) ->
		{
			mic = Microphone.getMicrophone(-1);
		});

		FlxG.camera.follow(plr);
		plr.makeGraphic(16, 16, FlxColor.WHITE);
		super.create();
		add(plr);

		add(otherPlayers);
		add(connected);
		add(button);
		button.scrollFactor.set(0, 0);
		client.getAvailableRooms("myRoom", (err, rooms) ->
		{
			for (i in rooms)
			{
				if (i.metadata.plot == MenuState.id)
				{
					client.joinById(i.roomId, ["mc" => MenuState.username], MyRoomState, function(err, room)
					{
						roome = room;
						epic(err, room);
					});
					return;
				}
			}
			client.create("myRoom", ["id" => MenuState.id, "mc" => MenuState.username], MyRoomState, function(err, room)
			{
				roome = room;
				epic(err, room);
			});
		});
	}

	function epic(err:HttpException, room:Room<MyRoomState>)
	{
		roome = room;
		if (err != null)
		{
			trace("JOIN ERROR: " + err);
			MenuState.error = err.message;
			return;
		}
		room.onError += (i, s) ->
		{
			MenuState.error = s;
			FlxG.switchState(new MenuState());
		};
		plrx = plr.fx;
		plry = plr.fy;
		plrz = plr.fz;
		room.state.players.onAdd((item, k) ->
		{
			if (k != room.sessionId)
			{
				var op:NetPlayer = new NetPlayer();
				otherPlayers.add(op);
				op.makeGraphic(16, 16, FlxColor.BLUE);
				var playerNm:FlxText = new FlxText(0, 0, 0, "", 16);
				playerNm.text = item.mc;
				add(playerNm);
				op.key = k;
				var name = new FlxText();
				name.x = 0;
				name.y = (((sliders.length / 2) * (24 + 8)) + 16) + 18;
				name.text = item.mc;
				sliders.add(name);
				add(name);
				var slider = new HorizontalSlider();
				slider.x = 0;
				slider.value = 50;
				slider.y = (((sliders.length / 2) * (24 + 8)) + 8) + 18;

				name.scrollFactor.set(0, 0);
				slider.scrollFactor.set(0, 0);
				sliders.scrollFactor.set(0, 0);
				sliders.add(slider);
				add(slider);
				var i = 0;
				for (s in sliders)
				{
					if (i % 2 == 1)
					{ // if slider
						s.y = (((i / 2) * (24 + 8)) + 8) + 18;
					}
					else
					{ /// if txt
						s.y = (((i / 2) * (24 + 8)) + 16) + 18;
					}
					i++;
				}

				item.onRemove(() ->
				{
					sliders.remove(name);
					sliders.remove(slider);
					remove(slider);
					remove(name);
					otherPlayers.remove(op);
					op.destroy();
					remove(playerNm);
					playerNm.destroy();
					var i = 0;
					for (s in sliders)
					{
						if (i % 2 == 1)
						{ // if slider
							s.y = (((i / 2) * (24 + 8)) + 8) + 18;
						}
						else
						{ /// if txt
							s.y = (((i / 2) * (24 + 8)) + 16) + 18;
						}
						i++;
					}
				});
				new FlxTimer().start(0.1, (t) ->
				{
					op.clientVolume = (slider.value - 50) / 50;
					op.alpha = calculateDistance(plr.fx, plr.fy, op.fx, op.fy, plr.fz, op.fz);
				}, 0);
				item.listen("z", (c, p) ->
				{
					FlxTween.tween(op, {fz: c}, 2);
					FlxTween.tween(op, {y: (c * 8)}, 2);
					FlxTween.tween(playerNm, {y: (c * 8) + (op.width - playerNm.width) / 2}, 2);
				});
				item.listen("x", (c, p) ->
				{
					FlxTween.tween(op, {fx: c}, 2);
					FlxTween.tween(playerNm, {x: (c * 8) + (op.width - playerNm.width) / 2}, 2);
					FlxTween.tween(op, {x: (c * 8)}, 2);
				});
				item.listen("y", (c, p) ->
				{
					FlxTween.tween(op, {fy: c}, 2);
				});
			}
			else
			{
				standing.alpha = 0.75;
				item.listen("z", (c, p) ->
				{
					FlxTween.tween(plr, {fz: c}, 2);
					plr.y = c * 8;
				});
				item.listen("x", (c, p) ->
				{
					FlxTween.tween(plr, {fx: c}, 2);
					plr.x = c * 8;
				});
				item.listen("y", (c, p) ->
				{
					FlxTween.tween(plr, {fy: c}, 2);
				});
				item.listen("curchannel", (c, p) ->
				{
					channel = c;
				});

				item.listen("angle", (c, p) ->
				{
					FlxTween.tween(plr, {angle: c}, 2);
					plrang = c;
				});
			}
		});
		room.onMessage("voiceChat", function(x)
		{
			timeSinceLastPacket = 0;
			if (x.sessionId == roome.sessionId)
			{
				return;
			}

			if (x.muted != 3)
			{
				if (x.muted == 1)
				{
					return;
				}
				if (channel > 0 && channel != x.channel)
				{
					return;
				}
				if (x.channel > 0 && channel != x.channel)
				{
					return;
				}
				if (x.muted == 2 && channel != x.channel)
				{
					return;
				}
			}

			// Convert string to array of numbers
			var s:String = x.input;
			var float32Array:Float32Array = AudioCompression.decompress(s);

			for (oplr in otherPlayers)
			{
				if (oplr.key == x.sessionId)
				{
					// oplr.q.push(float32Array);
					var distance = calculateDistance(plr.fx, plr.fy, oplr.fx, oplr.fy, plr.fz, oplr.fz);
					var maxDistance = 24.0; // Adjust this value based on your scene scale
					var volume = 1.0 - (distance / maxDistance); // Invert volume based on distance
					if (distance > 24)
					{
						volume = 0;
					}
					if (x.channel != 0)
					{
						if (channel == x.channel)
						{
							volume = 1;
						}
					}

					if (x.muted == 3)
					{
						volume = 1;
					}

					mic.playAudio(float32Array, volume + oplr.clientVolume, oplr.source, oplr.gainNode, plr.fx, plr.fy, plr.fz);
				}
			}
		});
		Toolkit.init();
	}

	override function destroy()
	{
		mic.scriptNode.disconnect();
		if (roome != null)
			roome.leave();
		super.destroy();
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
		timeSinceLastPacket += elapsed;
		if (timeSinceLastPacket > 4)
		{
			FlxG.switchState(new PlayState());
		}
		if (sendOut)
		{
			plr.color = FlxColor.GREEN;
		}
		else
		{
			plr.color = FlxColor.RED;
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			MenuState.error = "Connection Closed By User\n(ESCP key)";
			FlxG.switchState(new MenuState());
		}
		ttr += elapsed;

		timesincelast += elapsed;

		if (timesincelast > mintime)
		{
			connected.color = FlxColor.RED;
		}
		if (timesincelast < mintime)
		{
			connected.color = FlxColor.GREEN;
		}
		connected.text = "Connected: " + otherPlayers.length;
		super.update(elapsed);
	}
}

class LowPassFilter
{
	// Define the filter parameters
	var alpha:Float; // Filter coefficient (0 < alpha < 1)
	var output:Float;

	// Constructor
	public function new(alpha:Float)
	{
		this.alpha = alpha;
		this.output = 0.0;
	}

	// Apply the low-pass filter to a single sample
	public function filter(sample:Float):Float
	{
		output = alpha * sample + (1 - alpha) * output;
		return output;
	}

	// Apply the low-pass filter to a Float32Array of audio data
	public function filterArray(data:Float32Array):Float32Array
	{
		var result:Float32Array = new Float32Array(data.length);

		for (i in 0...data.length)
		{
			result[i] = filter(data[i]);
		}

		return result;
	}
}
