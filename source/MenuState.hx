package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.ui.FlxUIInputText;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var field:FlxUIInputText = new FlxUIInputText(0, 0, 256, "Plot ID");
	var user:FlxUIInputText = new FlxUIInputText(0, 0, 256, "Minecraft Username");

	public static var error:String = "";

	var begin:FlxButton = new FlxButton(0, 0, "Begin", () ->
	{
		error = "";
		FlxG.switchState(new PlayState());
	});
	var warning:FlxText = new FlxText(0, 0, 0, "This is still in beta! It works better than before\nbut is still quite untested. Have fun!", 18);

	public static var ip:String = "wss://ws2.agmas.org";
	public static var id:String = "ws://localhost:25566";
	public static var username:String = "ws://localhost:25566";

	override function create()
	{
		FlxG.autoPause = false;
		field.screenCenter();
		user.screenCenter();
		begin.screenCenter();
		warning.color = FlxColor.RED;
		warning.text = error;
		add(warning);
		add(user);
		add(field);
		add(begin);
		user.y -= 32;
		begin.y -= 64;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(field))
		{
			field.text = "";
		}
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(user))
		{
			user.text = "";
		}
		id = field.text;
		username = user.text;
		super.update(elapsed);
	}
}
