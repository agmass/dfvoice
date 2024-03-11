package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.GainNode;
import js.html.audio.PanningModelType;
import lime.utils.Float32Array;

class NetPlayer extends FlxSprite
{
	public var fz:Int = 0;
	public var fx:Int = 0;
	public var fy:Int = 0;
	public var q:Array<Float32Array> = [];

	public var clientVolume:Float = 0;

	public var gainNode:GainNode;

	var audioContext = new js.html.audio.AudioContext();

	public var key:String = "";

	public var source:AudioBufferSourceNode;

	function calculateDistance(x1:Float, y1:Float, x2:Float, y2:Float, z1:Float, z2:Float):Float
	{
		var dx = x2 - x1;
		var dy = y2 - y1;
		var dz = z2 - z1;
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
