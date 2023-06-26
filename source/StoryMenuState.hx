package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
#if windows
import Discord.DiscordClient;
#end
import flixel.graphics.FlxGraphic;

using StringTools;

class StoryMenuState extends MusicBeatState {
	var weekData:Array<Dynamic> = [['Meaty', 'Burnin']];
	
	var scoreText:FlxText;
	var diffText:FlxText;
	var storyText:FlxText;
	var banner:FlxSprite;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	
	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	override function create() {
		transition('OUT');

		#if windows
		DiscordClient.changePresence("Story Mode Menu", null);
		#end

		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.time = 3000;
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 24, 0, "SCORE: 49324858", 28);
		scoreText.setFormat(Paths.font("meat-boy-font.ttf"), 28, FlxColor.WHITE, CENTER);
		scoreText.screenCenter(X);
		add(scoreText);

		diffText = new FlxText(0, scoreText.y + 36, 0, "HARD", 24);
		diffText.setFormat(Paths.font("meat-boy-font.ttf"), 24, FlxColor.WHITE, CENTER);
		diffText.screenCenter(X);
		add(diffText);

		var daBanner:String = 'banner';

		if (FlxG.random.int(1, 100) <= 8) {
			daBanner = 'bannerLOL';
		}

		banner = new FlxSprite().loadGraphic(Paths.image('storymenu/' + daBanner));
		banner.updateHitbox();
		banner.screenCenter();
		banner.antialiasing = true;
		add(banner);

		storyText = new FlxText(0, FlxG.height * 0.94, 0, "< Meatboy >", 24);
		storyText.setFormat(Paths.font("meat-boy-font.ttf"), 24, FlxColor.WHITE, CENTER);
		storyText.screenCenter(X);
		add(storyText);

		#if !switch
		intendedScore = Highscore.getWeekScore(0, 0);
		#end

		FlxG.camera.zoom += 0.015;
		
    #if mobile
    addVirtualPad(LEFT_FULL, A_B);
    #end
		
		super.create();
	}

	override function update(elapsed:Float) {
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE: " + lerpScore;
		
		scoreText.screenCenter(X);
		diffText.screenCenter(X);
		
		if (!movedBack) {
			if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek) {
			movedBack = true;
			transition('IN');
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				FlxG.switchState(new MainMenuState()); 
			});
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);

		super.update(elapsed);
	}

	function selectWeek() {
		if (stopspamming == false) {
			transition('GAMEIN');
			
			FlxFlicker.flicker(storyText, 1, 0.06, false, false);
			stopspamming = true;
		}

		selectedWeek = true;
		PlayState.storyPlaylist = weekData[0];
		PlayState.isStoryMode = true;
		PlayState.storyDifficulty = 0;
		PlayState.SONG = Song.loadFromJson(StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase(),
			StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase());
		PlayState.storyWeek = 0;
		PlayState.campaignScore = 0;
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			LoadingState.target = new PlayState();
			FlxG.switchState(new LoadingState());});
	}
}
