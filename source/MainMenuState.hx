package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState {
	public static var curSelected:Int = 0;

	#if !switch
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'settings'];
	#else
	var optionShit:Array<String> = ['story_mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;

	var bg:FlxSprite;
	var barThing:FlxSprite;
	var logo:FlxSprite;
	var saw:FlxSprite;
	var fart:FlxSprite;
	var arrow:FlxSprite;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var sawExist:Bool = false;

	override function create() {
		transition('OUT');

		#if windows
		DiscordClient.changePresence("Main Menu", null);
		#end

		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.time = 3000;
		}
		
		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('daMeatBG'));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		barThing = new FlxSprite().loadGraphic(Paths.image('menu/barThingy'));
		barThing.updateHitbox();
		barThing.screenCenter();
		barThing.antialiasing = true;
		add(barThing);

		logo = new FlxSprite(710, 35).loadGraphic(Paths.image('logo/logo'));
		logo.setGraphicSize(Std.int(logo.width * 0.6));
		logo.antialiasing = true;
		logo.updateHitbox();

		saw = new FlxSprite(760, 35).loadGraphic(Paths.image('logo/saw'));
		saw.setGraphicSize(Std.int(saw.width * 0.6));
		saw.antialiasing = true;
		saw.updateHitbox();

		fart = new FlxSprite(630, 125).loadGraphic(Paths.image('logo/fart'));
		fart.setGraphicSize(Std.int(fart.width * 0.6));
		fart.antialiasing = true;
		fart.updateHitbox();

		add(fart);
		add(saw);
		sawExist = true;
		add(logo);

		arrow = new FlxSprite(755).loadGraphic(Paths.image('menu/arrow'));
		arrow.updateHitbox();
		add(arrow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length) {
			var menuItem:FlxSprite = new FlxSprite(800, FlxG.height * 1.6);
			menuItem.frames = Paths.getSparrowAtlas('menu/menuItems');
			menuItem.animation.addByPrefix('idle', optionShit[i], 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.updateHitbox();
			menuItem.y = 430 + (i * 60);
		}

		changeItem();

		FlxG.camera.zoom += 0.015;

    #if mobile
    addVirtualPad(UP_DOWN, A);
    #end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float) 
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin) {
			if (controls.UP_P)
				changeItem(-1);

			if (controls.DOWN_P)
				changeItem(1);

			if (controls.ACCEPT) {
				transition('IN');
				selectedSomethin = true;

				FlxFlicker.flicker(arrow, 1, 0.06, false, false);

				menuItems.forEach(function(spr:FlxSprite) {
					if (curSelected == spr.ID) {
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) { goToState(); });
					}
				});
			}
		}
		
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);

		if (sawExist) {
			Sys.sleep(0.01);
			saw.angle += 4;
		}

		super.update(elapsed);
	}
	
	function goToState() {
		var daChoice:String = optionShit[curSelected];

		switch (daChoice) {
			case 'story_mode':
				FlxG.switchState(new StoryMenuState());
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
			case 'settings':
				FlxG.switchState(new OptionsState());
		}
	}

	function changeItem(huh:Int = 0) {
		curSelected += huh;

		if (curSelected > 2)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 2;

		if (curSelected == 0)
			arrow.y = 423;
		else if (curSelected == 1)
			arrow.y = 483;
		else
			arrow.y = 543;
	}
}
