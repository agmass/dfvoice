package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIInputText;
import flixel.ui.FlxButton;

class MenuState extends FlxState
{
	var field:FlxUIInputText = new FlxUIInputText(0, 0, 256, "Plot ID");
	var user:FlxUIInputText = new FlxUIInputText(0, 0, 256, "Minecraft Username");
	var begin:FlxButton = new FlxButton(0, 0, "Begin", () ->
	{
		FlxG.switchState(new PlayState());
	});

	public static var ip:String = "ws://192.168.1.62:25566";
	public static var id:String = "ws://localhost:25566";
	public static var username:String = "ws://localhost:25566";

	override function create()
	{
		FlxG.autoPause = false;
		field.screenCenter();
		user.screenCenter();
		begin.screenCenter();
		add(field);
		add(user);
		add(begin);
		user.y -= 32;
		begin.y -= 64;
		super.create();
	}

	override function update(elapsed:Float)
	{
		id = field.text;
		username = user.text;
		super.update(elapsed);
	}
}
