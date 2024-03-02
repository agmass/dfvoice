import flixel.ui.FlxVirtualPad;
import js.Browser;
import js.Promise;
import js.html.AudioElement;
import js.html.AudioStreamTrack;
import js.html.Blob;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.MediaDeviceInfo;
import js.html.MediaDeviceKind;
import js.html.MediaDevices;
import js.html.MediaRecorder;
import js.html.MediaStream;
import js.html.MediaStreamConstraints;
import js.html.MediaStreamTrack;
import js.html.MediaTrackConstraints;
import js.html.VideoElement;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.AudioNode;
import js.html.audio.PanningModelType;
import js.html.audio.ScriptProcessorNode;
import lime.media.AudioContext;
import lime.media.vorbis.VorbisFile;
import lime.utils.Float32Array;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.NetStatusEvent;
import openfl.media.SoundTransform;

class Microphone extends EventDispatcher
{
	@:isVar public var gain(get, set):Float;
	@:isVar public var rate(get, set):Int;
	@:isVar public var codec(get, set):String;
	@:isVar public var framesPerPacket(get, set):Int;
	@:isVar public var encodeQuality(get, set):Int;
	@:isVar public var noiseSuppressionLevel(get, set):Int;
	@:isVar public var enableVAD(get, set):Bool;
	@:isVar public var activityLevel(get, null):Float;
	@:isVar public var index(get, null):Int;
	@:isVar public var muted(get, null):Bool;
	@:isVar public var name(get, null):String;
	@:isVar public var silenceLevel(get, null):Float;
	@:isVar public var silenceTimeout(get, null):Int;
	@:isVar public var useEchoSuppression(get, null):Bool;
	@:isVar public var soundTransform(get, set):SoundTransform;

	// @:isVar public var enhancedOptions(get, set):MicrophoneEnhancedOptions;
	@:isVar public static var names(get, null):Array<String>;
	@:isVar public static var isSupported(get, null):Bool;

	static var mediaDevices:MediaDevices;
	static var devices = new Map<String, MediaDeviceInfo>();

	var stream:MediaStream;
	var audioElement:AudioElement;

	var audioContext = new js.html.audio.AudioContext();

	// Create an AudioBufferSourceNode
	var played = false;
	var times = 0;
	var cur:String = "";

	public var bitrate = 9.0;

	static function __init__()
	{
		mediaDevices = Reflect.getProperty(Browser.navigator, 'mediaDevices');
		findAvailableDevices(true);
	}

	private function new(index:Int)
	{
		super();

		this.index = index;
		if (index >= 0 && index < names.length)
			this.name = names[index];

		audioElement = Browser.document.createAudioElement();

		findAvailableDevices(findDevice);
	}

	static function findAvailableDevices(callback:Void->Void = null, updateNames:Bool = false)
	{
		if (mediaDevices == null)
		{
			return;
			trace("microphone input disabled; unsecure connection?");
		}
		var names:Array<String> = [];
		devices = new Map<String, MediaDeviceInfo>();

		mediaDevices.enumerateDevices().then(function(_devices:Array<MediaDeviceInfo>)
		{
			for (device in _devices)
			{
				if (device.kind == MediaDeviceKind.AUDIOINPUT)
				{
					names.push(device.label);
					devices.set(device.label, device);
				} // else {
				//    trace("device.label = " + device.label);
				//    trace("device = " + device);
				// }
			}
			if (updateNames)
				Microphone.names = names;
			if (callback != null)
				callback();
		});
	}

	function findDevice()
	{
		var deviceInfo:MediaDeviceInfo = null;
		if (name != null)
		{
			deviceInfo = devices.get(name);
		}

		var constraints:MediaStreamConstraints = {audio: true, video: false};
		if (deviceInfo != null)
		{
			var trackConstraints:MediaTrackConstraints = {
				deviceId: {exact: deviceInfo.deviceId},
			};
			constraints.audio = trackConstraints;
		}

		mediaDevices.getUserMedia(constraints).then(function(stream:MediaStream)
		{
			this.stream = stream;
			audioElement.srcObject = stream;
			// audioElement.play();
			var audioContext = new AudioContext();
			// Create a ScriptProcessorNode for processing
			var scriptNode = audioContext.web.createScriptProcessor(256, 1, 1); // Adjust buffer size accordingly

			// Set up the onaudioprocess event handler
			scriptNode.onaudioprocess = onAudioProcess;

			// Connect the script processor node to the destination (e.g., speakers)
			scriptNode.connect(audioContext.web.destination);

			// Connect the audio track to the script processor node
			var sourceNode = audioContext.web.createMediaStreamSource(stream);
			sourceNode.connect(scriptNode);

			trace("started");
			dispatchEvent(new Event("STATUS", false, false));
		}).catchError(function(error:Dynamic)
		{
				trace(error);
		});
	}

	function onAudioProcess(event:Dynamic):Void
	{
		var inputBuffer = event.inputBuffer;
		var inputData = inputBuffer.getChannelData(0); // Mono audio data

		if (PlayState.roome != null && inputData != null)
		{
			cur += inputData + "";
			times++;
			if (times >= 10)
			{
				times = 0;
				var w = 0.0;
				for (i in cur.split(","))
				{
					w += Std.parseFloat(i);
				}
				PlayState.roome.send("proximitychat", {aud: cur + "", vol: w});
				cur = "";
			}
		}
	}

	public function playAudio(audioData:Float32Array, volume:Float, source:AudioBufferSourceNode, x = 0.0, y = 0.0, z = 0.0):Void
	{
		if (source != null)
		{
			source.disconnect();
		}
		volume = 1;
		// Apply gain to the audio data
		if (volume <= 0)
		{
			volume = -0.3;
		}

		for (i in 0...audioData.length)
		{
			audioData[i] *= volume + 0.3;
		}

		source = audioContext.createBufferSource();
		var pannerNode = audioContext.createPanner();
		pannerNode.panningModel = PanningModelType.EQUALPOWER;
		var dx = x - PlayState.plrx;
		var dy = y - PlayState.plry;
		var dz = z - PlayState.plrz;
		if (dx < 100 && dx > -100 || dy < 100 && dy > -100 || dz < 100 && dz > -100)
		{
			dx = 0;
			dy = 0;
			dz = 0;
		}
		pannerNode.setPosition(dx / 100, dy / 100, dz / 100);
		pannerNode.setPosition(0, 0, 0);

		source.connect(pannerNode);

		pannerNode.connect(audioContext.destination);

		var buffer = audioContext.createBuffer(1, audioData.length, audioContext.sampleRate);
		buffer.copyToChannel(audioData, 0);

		source.buffer = buffer;

		source.start();
	}

	function set_rate(value:Int):Int
	{
		throw "this method not supported on this target yet";
		return rate = value;
	}

	function get_rate():Int
	{
		throw "this method not supported on this target yet";
		return rate;
	}

	function set_codec(value:String):String
	{
		throw "this method not supported on this target yet";
		return codec = value;
	}

	function get_codec():String
	{
		throw "this method not supported on this target yet";
		return codec;
	}

	function get_framesPerPacket():Int
	{
		throw "this method not supported on this target yet";
		return framesPerPacket;
	}

	function set_framesPerPacket(value:Int):Int
	{
		throw "this method not supported on this target yet";
		return framesPerPacket = value;
	}

	function get_encodeQuality():Int
	{
		throw "this method not supported on this target yet";
		return encodeQuality;
	}

	function set_encodeQuality(value:Int):Int
	{
		throw "this method not supported on this target yet";
		return encodeQuality = value;
	}

	function get_noiseSuppressionLevel():Int
	{
		throw "this method not supported on this target yet";
		return noiseSuppressionLevel;
	}

	function set_noiseSuppressionLevel(value:Int):Int
	{
		throw "this method not supported on this target yet";
		return noiseSuppressionLevel = value;
	}

	function get_enableVAD():Bool
	{
		throw "this method not supported on this target yet";
		return enableVAD;
	}

	function set_enableVAD(value:Bool):Bool
	{
		throw "this method not supported on this target yet";
		return enableVAD = value;
	}

	public function setSilenceLevel(silenceLevel:Float, timeout:Int = -1):Void
	{
		throw "this method not supported on this target yet";
	}

	public function setUseEchoSuppression(value:Bool):Void
	{
		throw "this method not supported on this target yet";
	}

	function get_activityLevel():Float
	{
		throw "this method not supported on this target yet";
		return activityLevel;
	}

	function get_gain():Float
	{
		throw "this method not supported on this target yet";
		return gain;
	}

	function set_gain(value:Float):Float
	{
		throw "this method not supported on this target yet";
		return gain = value;
	}

	function get_index():Int
	{
		return index;
	}

	function get_muted():Bool
	{
		throw "this method not supported on this target yet";
		return muted;
	}

	function get_name():String
	{
		return name;
	}

	function get_silenceLevel():Float
	{
		throw "this method not supported on this target yet";
		return silenceLevel;
	}

	function get_silenceTimeout():Int
	{
		throw "this method not supported on this target yet";
		return silenceTimeout;
	}

	function get_useEchoSuppression():Bool
	{
		throw "this method not supported on this target yet";
		return useEchoSuppression;
	}

	function setLoopBack(value:Bool = true):Void
	{
		throw "this method not supported on this target yet";
	}

	function get_soundTransform():SoundTransform
	{
		return soundTransform;
	}

	function set_soundTransform(value:SoundTransform):SoundTransform
	{
		soundTransform = value;
		audioElement.volume = soundTransform.volume;
		// audioElement.pan = soundTransform.pan; // pan currently not supported
		return soundTransform;
	}

	/*function get_enhancedOptions():MicrophoneEnhancedOptions
		{
			throw "this method not supported on this target yet";
			return enhancedOptions;
	}*/
	/*function set_enhancedOptions(value:MicrophoneEnhancedOptions):Void
		{
			throw "this method not supported on this target yet";
			return enhancedOptions = value;
	}*/
	public static function getMicrophone(value:Int = -1):Microphone
	{
		return new Microphone(value);
	}

	static function get_names():Array<String>
	{
		return names;
	}

	static function get_isSupported():Bool
	{
		throw "this method not supported on this target yet";
		return isSupported;
	}

	public static function getEnhancedMicrophone(value:Int = -1):Microphone
	{
		throw "this method not supported on this target yet";
		return null;
	}
}
