package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
#if cpp
import sys.thread.Thread;
#end

using StringTools;

class TitleState extends MusicBeatState {
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;

	var wackyImage:FlxSprite;

	override public function create():Void 
	{
    #if android
    FlxG.android.preventDefaultKeys = [BACK];
    #end
		Init.Initialize();
		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}

		super.create();

		new FlxTimer().start(1, function(tmr:FlxTimer) {
			startIntro();
		});
	}

	var bg:FlxSprite;
	var logo:FlxSprite;
	var saw:FlxSprite;
	var fart:FlxSprite;
	var barThing:FlxSprite;
	var pressStart:FlxSprite;
	var sawExist:Bool = false;

	function startIntro() {
		if (!initialized) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(140);
		persistentUpdate = true;

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('daMeatBG'));
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		logo = new FlxSprite(400, 160).loadGraphic(Paths.image('logo/logo'));
		logo.setGraphicSize(Std.int(logo.width * 0.6));
		logo.antialiasing = true;
		logo.updateHitbox();

		saw = new FlxSprite(450, 160).loadGraphic(Paths.image('logo/saw'));
		saw.setGraphicSize(Std.int(saw.width * 0.6));
		saw.antialiasing = true;
		saw.updateHitbox();

		fart = new FlxSprite(320, 250).loadGraphic(Paths.image('logo/fart'));
		fart.setGraphicSize(Std.int(fart.width * 0.6));
		fart.antialiasing = true;
		fart.updateHitbox();

		add(fart);
		add(saw);
		sawExist = true;
		add(logo);

		barThing = new FlxSprite(0, 0).loadGraphic(Paths.image('title/barThingy'));
		barThing.antialiasing = true;
		barThing.updateHitbox();
		barThing.screenCenter();
		add(barThing);

		pressStart = new FlxSprite(0, FlxG.height * 0.825);
		pressStart.frames = Paths.getSparrowAtlas('title/pressStart');
		pressStart.screenCenter(X);
		pressStart.animation.addByPrefix('idle', "idle", 24);
		pressStart.animation.play('idle');
		pressStart.antialiasing = false;
		pressStart.updateHitbox();
		add(pressStart);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;
		
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro) {
			transition('IN');
			FlxFlicker.flicker(pressStart, 1, 0.06, false, false, function(flick:FlxFlicker) {
				FlxG.switchState(new MainMenuState()); 
			});

			transitioning = true;
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);

		if (sawExist) {
			Sys.sleep(0.01);
			saw.angle += 4;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String) {
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText() {
		while (textGroup.members.length > 0) {
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit() {
		super.beatHit();

		FlxG.camera.zoom += 0.015;

		switch (curBeat) {
			case 4:
				addMoreText('Super');
			case 5:
				addMoreText('Meat');
			case 6:
				addMoreText('Funkin');
			case 7:
				deleteCoolText();
			case 8:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void {
		if (!skippedIntro) {
			remove(credGroup);
			skippedIntro = true;
		}
	}
}