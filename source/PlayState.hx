package;

import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import flixel.system.FlxAssets;
import lime.utils.Assets;
#if windows
import Discord.DiscordClient;
#end

using StringTools;

class PlayState extends MusicBeatState {
	public static var instance:PlayState = null;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;

	#if windows
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;
	private var P1vocals:FlxSound;
	private var P2vocals:FlxSound;
	private var SepVocalsNull:Bool = false;

	public var bfOnlyEvent:FlxSprite;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var notesBgDad:FlxSprite;
	public var notesBgBoyfriend:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	public var camZooming:Bool = false;

	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1;

	private var combo:Int = 0;

	public var topBar:FlxSprite;
	public var bottomBar:FlxSprite;

	public static var misses:Int = 0;

	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;

	private var camGame:FlxCamera;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	var fc:Bool = true;
	
	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var RatingCounter:FlxText;
	var timer:FlxText;
	var secondsTotal:Int;
	var timeBarBG:FlxSprite;
	var timeBar:FlxBar;
	var flashyWashy:FlxSprite;
	
	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	private var triggeredAlready:Bool = false;
	private var allowedToHeadbang:Bool = false;

	private var botPlayState:FlxText;

	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	var dodgeSaw:FlxSprite;

	public var hideGf:Bool = false;

	public var bfScared:Bool = false;

	//forest bg stuff
	var bg:FlxSprite;
	var stuff:FlxSprite;
	var ground:FlxSprite;
	var bushes:FlxSprite;
	
	var bgFire:FlxSprite;
	var stuffFire:FlxSprite;
	var groundFire:FlxSprite;
	var bushesFire:FlxSprite;
	var fire:FlxSprite;

	// ranking
	var thing:FlxSprite;
	public var daRank:FlxSprite;

	public var manImDead:Bool = false;
	
	override public function create() {
		instance = this;
		FlxG.mouse.visible = false;

		if (!Assets.exists(Paths.P1voice(PlayState.SONG.song)) || !Assets.exists(Paths.P2voice(PlayState.SONG.song)))
			SepVocalsNull = true;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		#if windows
		storyDifficultyText = "Hard";

		iconRPC = SONG.player2;

		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay";

		detailsPausedText = "Paused - " + detailsText;
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " Rank: " + Ratings.GenerateLetterRank(accuracy),
			"Acc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		curStage = SONG.stage;
		
		if(SONG.stage == null || SONG.stage.length < 1) {
			curStage = 'stage';
		}
		SONG.stage = curStage;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		songLength = FlxG.sound.music.length;

		switch (curStage) {
			case 'forest':
				defaultCamZoom = 0.7;
				
				bgFire = new FlxSprite(-500, -200).loadGraphic(Paths.image('bgs/' + curStage + 'Fire/backgroundtrees', 'shared'));
				bgFire.antialiasing = true;
				bgFire.scrollFactor.set(0.7, 0.8);
				add(bgFire);
				
				fire = new FlxSprite(-380, 200);
				fire.frames = Paths.getSparrowAtlas('bgs/' + curStage + 'Fire/IDontDieInTheFire'); 
				fire.animation.addByPrefix('burn', 'burn');
				fire.animation.play('burn');
				fire.antialiasing = true;
				fire.scrollFactor.set(1, 1);
				add(fire);

				stuffFire = new FlxSprite(-420, -270).loadGraphic(Paths.image('bgs/' + curStage + 'Fire/foregroundtrees', 'shared'));
				stuffFire.antialiasing = true;
				stuffFire.scrollFactor.set(0.9, 0.9);
				add(stuffFire);

				groundFire = new FlxSprite(-380, 280).loadGraphic(Paths.image('bgs/' + curStage + 'Fire/grassnstuff', 'shared'));
				groundFire.antialiasing = true;
				groundFire.scrollFactor.set(1, 1);
				add(groundFire);

				bushesFire = new FlxSprite(-560, 490).loadGraphic(Paths.image('bgs/' + curStage + 'Fire/bushes', 'shared'));
				bushesFire.antialiasing = true;
				bushesFire.scrollFactor.set(1.1, 0.9);
				bushesFire.alpha = 0.0001;

				bg = new FlxSprite(-500, -200).loadGraphic(Paths.image('bgs/' + curStage + '/backgroundtrees', 'shared'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.7, 0.8);
				add(bg);

				stuff = new FlxSprite(-420, -270).loadGraphic(Paths.image('bgs/' + curStage + '/foregroundtrees', 'shared'));
				stuff.antialiasing = true;
				stuff.scrollFactor.set(0.9, 0.9);
				add(stuff);

				ground = new FlxSprite(-380, 280).loadGraphic(Paths.image('bgs/' + curStage + '/grassnstuff', 'shared'));
				ground.antialiasing = true;
				ground.scrollFactor.set(1, 1);
				add(ground);

				bushes = new FlxSprite(-560, 490).loadGraphic(Paths.image('bgs/' + curStage + '/bushes', 'shared'));
				bushes.antialiasing = true;
				bushes.scrollFactor.set(1.1, 0.9);

				hideGf = true;
			case 'forestFire':
				defaultCamZoom = 0.7;
				
				bgFire = new FlxSprite(-500, -200).loadGraphic(Paths.image('bgs/' + curStage + '/backgroundtrees', 'shared'));
				bgFire.antialiasing = true;
				bgFire.scrollFactor.set(0.7, 0.8);
				add(bgFire);
				
				fire = new FlxSprite(-380, 200);
				fire.frames = Paths.getSparrowAtlas('bgs/' + curStage + '/IDontDieInTheFire'); 
				fire.animation.addByPrefix('burn', 'burn');
				fire.animation.play('burn');
				fire.antialiasing = true;
				fire.scrollFactor.set(1, 1);
				add(fire);

				stuffFire = new FlxSprite(-420, -270).loadGraphic(Paths.image('bgs/' + curStage + '/foregroundtrees', 'shared'));
				stuffFire.antialiasing = true;
				stuffFire.scrollFactor.set(0.9, 0.9);
				add(stuffFire);

				groundFire = new FlxSprite(-380, 280).loadGraphic(Paths.image('bgs/' + curStage + '/grassnstuff', 'shared'));
				groundFire.antialiasing = true;
				groundFire.scrollFactor.set(1, 1);
				add(groundFire);

				bushesFire = new FlxSprite(-560, 490).loadGraphic(Paths.image('bgs/' + curStage + '/bushes', 'shared'));
				bushesFire.antialiasing = true;
				bushesFire.scrollFactor.set(1.1, 0.9);

				hideGf = true;
			default:
				defaultCamZoom = 0.9;
				
				bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('bgs/' + curStage + '/stageback', 'shared'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('bgs/' + curStage + '/stagefront', 'shared'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('bgs/' + curStage + '/stagecurtains', 'shared'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				add(stageCurtains);

				hideGf = true;
		}

		var gfVersion:String = SONG.gfVersion;

		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage) {
				default:
					gfVersion = 'gf';
			}

			SONG.gfVersion = gfVersion;
		}

		gf = new Character(400, 130, gfVersion);
		setCharacterPos(gf);

		dad = new Character(100, 100, SONG.player2);
		setCharacterPos(dad, true);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2) {
			case 'gf':
				gf.visible = false;
				if (isStoryMode) {
					camPos.x += 600;
				}
			case 'meatboy':
				camPos.x += 220;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		setCharacterPos(boyfriend);

		if (!hideGf)
			add(gf);
		add(dad);

		bfOnlyEvent = new FlxSprite(0, 0).makeGraphic(3000, 3000, FlxColor.BLACK);
		bfOnlyEvent.alpha = 0.000001;
		add(bfOnlyEvent);

		add(boyfriend);

		if (curStage.startsWith('forest')) {
			add(bushes);
			add(bushesFire);
		}
		
		Conductor.songPosition = 0;

		topBar = new FlxSprite(0, -170).makeGraphic(1280, 120, FlxColor.BLACK);
		bottomBar = new FlxSprite(0, 720).makeGraphic(1280, 120, FlxColor.BLACK);
		add(topBar);
		add(bottomBar);

		if (FlxG.save.data.bgNotesAlpha != 0) {
			notesBgBoyfriend = new FlxSprite(717, 0).makeGraphic(490, FlxG.height, FlxColor.BLACK);
			notesBgBoyfriend.cameras = [camHUD];
			notesBgBoyfriend.alpha = 0.00001;
			notesBgBoyfriend.screenCenter(Y);
			if (FlxG.save.data.middleScroll)
				notesBgBoyfriend.x = 400;
			add(notesBgBoyfriend);

			if (!FlxG.save.data.middleScroll) {
				notesBgDad = new FlxSprite(77, 0).makeGraphic(490, FlxG.height, FlxColor.BLACK);
				notesBgDad.cameras = [camHUD];
				notesBgDad.alpha = 0.00001;
				notesBgDad.screenCenter(Y);
				add(notesBgDad);
			}
		}

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		var noteSplash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash);
		noteSplash.alpha = 0.00001;

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (60 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('bar/BG'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.x += 100;
		healthBarBG.scrollFactor.set();
		if (!FlxG.save.data.hidehud)
			add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, RIGHT_TO_LEFT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createImageBar(Paths.image('bar/HP' + dad.barPic), Paths.image('bar/HP' + boyfriend.barPic));
		if (!FlxG.save.data.hidehud)
			add(healthBar);

		timeBarBG = new FlxSprite(0, FlxG.height * 0.1 - 105).loadGraphic(Paths.image('bar/TimeBG'));
		if (FlxG.save.data.downscroll)
			timeBarBG.y = 50;
		timeBarBG.screenCenter(X);
		timeBarBG.scrollFactor.set();
		if (FlxG.save.data.timeBar)
			add(timeBarBG);
		
		timeBar = new FlxBar(0, FlxG.height * 0.1 - 95, LEFT_TO_RIGHT, 538, 65, this, 'secondsTotal', 0, 100000);
		if (FlxG.save.data.downscroll)
			timeBar.y = 55;
		timeBar.scrollFactor.set();
		timeBar.createImageBar(Paths.image('bar/TIMEBlack'), Paths.image('bar/TIME'));
		timeBar.numDivisions = 1000;
		timeBar.screenCenter(X);
		add(timeBar);

		timer = new FlxText(0, FlxG.height * 0.1 - 70, 0, '', 20);
		timer.setFormat(Paths.font("meat-boy-font.ttf"), 22, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		if (FlxG.save.data.downscroll)
			timer.y = 75;
		timer.borderSize = 1;
		timer.borderQuality = 2;
		timer.scrollFactor.set();
		if (FlxG.save.data.timeBar)
			add(timer);

		RatingCounter = new FlxText(20, 0, 0, '', 20);
		RatingCounter.setFormat(Paths.font("meat-boy-font.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		RatingCounter.borderSize = 1;
		RatingCounter.borderQuality = 2;
		RatingCounter.scrollFactor.set();
		RatingCounter.cameras = [camHUD];
		if (FlxG.save.data.ratingCounter && !FlxG.save.data.botplay)
			add(RatingCounter);

		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("meat-boy-font.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.borderSize = 2;
		botPlayState.borderQuality = 2;
		botPlayState.scrollFactor.set();

		if (FlxG.save.data.botplay)
			add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.setGraphicSize(Std.int(iconP1.width * 0.7));
		iconP1.y = healthBar.y - (iconP1.height / 2) + 10;
		if (!FlxG.save.data.hidehud)
			add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.setGraphicSize(Std.int(iconP2.width * 0.7));
		iconP2.y = healthBar.y - (iconP2.height / 2) + 10;
		if (!FlxG.save.data.hidehud)
			add(iconP2);
		
		// v1.1!!!!!!!
		thing = new FlxSprite(-45, 560).loadGraphic(Paths.image('ranks/thing'));
		thing.setGraphicSize(Std.int(thing.width * 0.7));
		thing.antialiasing = true;
		if (!FlxG.save.data.hidehud)
			add(thing);
		
		daRank = new FlxSprite(0, 530).loadGraphic(Paths.image('ranks/' + Ratings.GenerateLetterRank(60)));
		daRank.setGraphicSize(Std.int(daRank.width * 0.7));
		daRank.antialiasing = true;
		if (!FlxG.save.data.hidehud)
			add(daRank);

		flashyWashy = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.WHITE);
		flashyWashy.alpha = 0.000001;
		add(flashyWashy);

		topBar.cameras = [camHUD];
		bottomBar.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		timer.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		botPlayState.cameras = [camHUD];
		flashyWashy.cameras = [camHUD];
		thing.cameras = [camHUD];
		daRank.cameras = [camHUD];
		#if mobile
		addMobileControls(false);
    mobileControls.visible = false;
		#end

		startSong();

		super.create();
	}
	
	public function changeChar(newCharacter:String, type:Int, ?daGF:Bool = false) {
		switch(type) {
			case 0:
				if(boyfriend.curCharacter != newCharacter) {
					if(!boyfriendMap.exists(newCharacter)) {
						var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
						boyfriendMap.set(newCharacter, newBoyfriend);
						add(newBoyfriend);
						setCharacterPos(newBoyfriend);
						newBoyfriend.alpha = 0.00001;
					}

					var lastAlpha:Float = boyfriend.alpha;
					boyfriend.alpha = 0.00001;
					boyfriend = boyfriendMap.get(newCharacter);
					boyfriend.alpha = lastAlpha;
					iconP1.changeIcon(newCharacter);
					healthBar.createImageBar(Paths.image('bar/HP' + dad.barPic), Paths.image('bar/HP' + boyfriend.barPic));
					healthBar.updateBar();
					timeBar.createImageBar(Paths.image('bar/TIMEBlack'), Paths.image('bar/TIME'));
					timeBar.updateBar();
				}

			case 1:
				if(dad.curCharacter != newCharacter) {
					if(!dadMap.exists(newCharacter)) {
						var newDad:Character = new Character(0, 0, newCharacter);
						dadMap.set(newCharacter, newDad);
						add(newDad);
						setCharacterPos(newDad, false, daGF);
						newDad.alpha = 0.00001;
					}

					var lastAlpha:Float = dad.alpha;
					dad.alpha = 0.00001;
					dad = dadMap.get(newCharacter);
					dad.alpha = lastAlpha;
					iconP2.changeIcon(newCharacter);
					healthBar.createImageBar(Paths.image('bar/HP' + dad.barPic), Paths.image('bar/HP' + boyfriend.barPic));
					healthBar.updateBar();
					timeBar.createImageBar(Paths.image('bar/TIMEBlack'), Paths.image('bar/TIME'));
					timeBar.updateBar();
				}

			case 2:
				if(!hideGf) {
					if(gf.curCharacter != newCharacter) {
						if(gf != null && !gfMap.exists(newCharacter)) {
							var newGf:Character = new Character(0, 0, newCharacter);
							newGf.scrollFactor.set(0.95, 0.95);
							gfMap.set(newCharacter, newGf);
							add(newGf);
							setCharacterPos(newGf);
							newGf.alpha = 0.00001;
						}

						var lastAlpha:Float = gf.alpha;
						gf.alpha = 0.00001;
						gf = gfMap.get(newCharacter);
						gf.alpha = lastAlpha;
					}
				}
		}
	}

	var perfectMode:Bool = false;

	function setCharacterPos(char:Character, ?gfCheck:Bool = false, ?daGF:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf') || daGF) {
			char.setPosition(gf.x, gf.y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}

		char.x += char.positionX;
		char.y += char.positionY;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	var songStarted = false;

	function startSong():Void 
	{
    #if mobile
    mobileControls.visible = true;
    #end
		inCutscene = false;
		canPause = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		songStarted = true;
		canPause = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
	
		FlxG.sound.music.onComplete = endSong;
		if (SepVocalsNull)
			vocals.play();
		else
			for (vocals in [P1vocals, P2vocals])
				vocals.play();
			
		songLength = FlxG.sound.music.length;
		
		switch (curSong) {
			default:
				allowedToHeadbang = false;
		}
		
		transition('GAMEOUT');

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " Rank: " + Ratings.GenerateLetterRank(accuracy),
			"Acc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void {
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			if (SepVocalsNull) {
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			} else {
				P1vocals = new FlxSound().loadEmbedded(Paths.P1voice(PlayState.SONG.song));
				P2vocals = new FlxSound().loadEmbedded(Paths.P2voice(PlayState.SONG.song));
			}
		else
			vocals = new FlxSound();

		if (SepVocalsNull)
			FlxG.sound.list.add(vocals);
		else
			for (vocals in [P1vocals, P2vocals])
				FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0;
		for (section in noteData) {
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes) {
				var daStrumTime:Float = songNotes[0];
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength)) {
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2;
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void {
		for (i in 0...4) {
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (SONG.noteStyle) {
				case 'normal':
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i)) {
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i)) {
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player) {
				case 0:
					cpuStrums.add(babyArrow);
					if (FlxG.save.data.middleScroll)
						babyArrow.visible = false;
				case 1:
					playerStrums.add(babyArrow);
					if (FlxG.save.data.middleScroll)
						babyArrow.x -= (FlxG.width / 4.75);
			}

			babyArrow.animation.play('static');
			if (FlxG.save.data.middleScroll)
				babyArrow.x += ((FlxG.width / 2) * player) + 50;
			else
				babyArrow.x += ((FlxG.width / 2) * player) + 97;

			cpuStrums.forEach(function(spr:FlxSprite) {
				spr.centerOffsets();
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function middleScrollEventBf(appear:Bool) {
		if (appear) {
			if (!FlxG.save.data.middleScroll) {
				playerStrums.forEach(function(spr:FlxSprite) {
					FlxTween.tween(playerStrums.members[0], {x: 420}, 1, {ease: FlxEase.cubeInOut});
					FlxTween.tween(playerStrums.members[1], {x: 532}, 1.2, {ease: FlxEase.cubeInOut});
					FlxTween.tween(playerStrums.members[2], {x: 643}, 1.4, {ease: FlxEase.cubeInOut});
					FlxTween.tween(playerStrums.members[3], {x: 755}, 1.6, {ease: FlxEase.cubeInOut});
				});

				cpuStrums.forEach(function(spr:FlxSprite) {
					FlxTween.tween(spr, {alpha: 0}, 1, {ease: FlxEase.sineOut});
				});
				
				if (FlxG.save.data.bgNotesAlpha != 0) {
					FlxTween.tween(notesBgBoyfriend, {x: 400}, 1.3, {ease: FlxEase.sineOut});
					FlxTween.tween(notesBgDad, {alpha: 0}, 1, {ease: FlxEase.sineOut});
				}
			}
		} else {
			if (!FlxG.save.data.middleScroll) {
				playerStrums.forEach(function(spr:FlxSprite) {
					FlxTween.tween(playerStrums.members[0], {x: 740}, 0.8, {ease: FlxEase.cubeInOut});
					FlxTween.tween(playerStrums.members[1], {x: 852}, 0.7, {ease: FlxEase.cubeInOut});
					FlxTween.tween(playerStrums.members[2], {x: 963}, 0.6, {ease: FlxEase.cubeInOut});
					FlxTween.tween(playerStrums.members[3], {x: 1075}, 0.5, {ease: FlxEase.cubeInOut});
				});
	
				cpuStrums.forEach(function(spr:FlxSprite) {
					FlxTween.tween(spr, {alpha: 1}, 0.6, {ease: FlxEase.sineIn});
				});
				
				if (FlxG.save.data.bgNotesAlpha != 0) {
					FlxTween.tween(notesBgBoyfriend, {x: 720}, 1.3, {ease: FlxEase.sineOut});
					var daAlpha:Float = FlxG.save.data.bgNotesAlpha;
					FlxTween.tween(notesBgDad, {alpha: daAlpha}, 1, {ease: FlxEase.sineOut});
				}
			}
		}
	}
	
	function middleScrollEventDad(appear:Bool) {
		if (appear) {
			if (!FlxG.save.data.middleScroll) {
				cpuStrums.forEach(function(spr:FlxSprite) {
					FlxTween.tween(cpuStrums.members[0], {x: 420}, 1, {ease: FlxEase.cubeInOut});
					FlxTween.tween(cpuStrums.members[1], {x: 532}, 1.2, {ease: FlxEase.cubeInOut});
					FlxTween.tween(cpuStrums.members[2], {x: 643}, 1.4, {ease: FlxEase.cubeInOut});
					FlxTween.tween(cpuStrums.members[3], {x: 755}, 1.6, {ease: FlxEase.cubeInOut});
				});

				playerStrums.forEach(function(spr:FlxSprite) {
					FlxTween.tween(spr, {alpha: 0}, 1, {ease: FlxEase.sineOut});
				});
				
				if (FlxG.save.data.bgNotesAlpha != 0) {
					FlxTween.tween(notesBgDad, {x: 400}, 1.3, {ease: FlxEase.sineOut});
					FlxTween.tween(notesBgBoyfriend, {alpha: 0}, 1, {ease: FlxEase.sineOut});
				}
			}
		} else {
			if (!FlxG.save.data.middleScroll) {
				cpuStrums.forEach(function(spr:FlxSprite) {
					FlxTween.tween(cpuStrums.members[0], {x: 150}, 0.8, {ease: FlxEase.cubeInOut});
					FlxTween.tween(cpuStrums.members[1], {x: 262}, 0.7, {ease: FlxEase.cubeInOut});
					FlxTween.tween(cpuStrums.members[2], {x: 374}, 0.6, {ease: FlxEase.cubeInOut});
					FlxTween.tween(cpuStrums.members[3], {x: 485}, 0.5, {ease: FlxEase.cubeInOut});
				});
	
				playerStrums.forEach(function(spr:FlxSprite) {
					FlxTween.tween(spr, {alpha: 1}, 0.6, {ease: FlxEase.sineIn});
				});
				
				if (FlxG.save.data.bgNotesAlpha != 0) {
					FlxTween.tween(notesBgDad, {x: 80}, 1.3, {ease: FlxEase.sineOut});
					var daAlpha:Float = FlxG.save.data.bgNotesAlpha;
					FlxTween.tween(notesBgBoyfriend, {alpha: daAlpha}, 1, {ease: FlxEase.sineOut});
				}
			}
		}
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				if (SepVocalsNull)
					vocals.pause();
				else
					for (vocals in [P1vocals, P2vocals])
						vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " Rank: " + Ratings.GenerateLetterRank(accuracy),
				"Acc: " + HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null)
				resyncVocals();

			paused = false;

			#if windows
			DiscordClient.changePresence(detailsText
				+ " "
				+ SONG.song
				+ " Rank: " + Ratings.GenerateLetterRank(accuracy),
				"Acc: " + HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC, true, songLength - Conductor.songPosition);
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void {
		if (SepVocalsNull)
			vocals.pause();
		else
			for (vocals in [P1vocals, P2vocals])
				vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (SepVocalsNull) {
			vocals.time = Conductor.songPosition;
			vocals.play();
		} else
			for (vocals in [P1vocals, P2vocals]) {
				vocals.time = Conductor.songPosition;
				vocals.play();
			}

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " Rank: " + Ratings.GenerateLetterRank(accuracy),
			"Acc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var canPause:Bool = true;

	public static var songRate = 1.5;

	override public function update(elapsed:Float) {
		#if !debug
		perfectMode = false;
		#end
		
		remove(timeBar);
	
		var length:Float = songLength / 1000;
		timeBar = new FlxBar(0, FlxG.height * 0.1 - 95, LEFT_TO_RIGHT, 538, 65, this, 'secondsTotal', 0, length);
		if (FlxG.save.data.downscroll)
			timeBar.y = 55;
		timeBar.scrollFactor.set();
		timeBar.createImageBar(Paths.image('bar/TIMEBlack'), Paths.image('bar/TIME'));
		timeBar.numDivisions = 1000;
		timeBar.screenCenter(X);
			
		if (FlxG.save.data.timeBar) {
			add(timeBar);
			timeBar.cameras = [camHUD];
		}
		
		secondsTotal = Math.floor(Conductor.songPosition / 1000);
		if (secondsTotal < 0)
			secondsTotal = 0;

		var daSecondsTotal:Int = Math.floor((songLength - Conductor.songPosition) / 1000);
		if (daSecondsTotal < 0)
			daSecondsTotal = 0;
		
		timer.text = FlxStringUtil.formatTime(daSecondsTotal, false);
		timer.screenCenter(X);

		if (FlxG.save.data.ratingCounter) {
			RatingCounter.text = 'Sicks: ${sicks}\nGoods: ${goods}\nBads: ${bads}\nShits: ${shits}\nMisses: ${misses}';
			RatingCounter.screenCenter(Y);
		}
		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0) {
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
		}

		super.update(elapsed);

		if (FlxG.keys.justPressed.C)
		{
			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				if (key.contains('assets'))
				{
					trace('key: ' + key + " is on mem");
				}
			}
		}

		if (FlxG.keys.justPressed.ENTER #if mobile || FlxG.android.justReleased.BACK #end && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN) {
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			transition('INDAMNED');
			new FlxTimer().start(1, function(tmr:FlxTimer) {FlxG.switchState(new ChartingState()); });
		}

		if (FlxG.keys.justPressed.NINE) {
			#if windows
			DiscordClient.changePresence("Animation Debug", null, null, true);
			#end
			transition('INDAMNED');
			new FlxTimer().start(1, function(tmr:FlxTimer) {FlxG.switchState(new AnimationDebug()); });
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(125, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(125, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		Conductor.songPosition += FlxG.elapsed * 1000;

		if (!paused) {
			songTime += FlxG.game.ticks - previousFrameTime;
			previousFrameTime = FlxG.game.ticks;
			if (Conductor.lastSongPos != Conductor.songPosition) {
				songTime = (songTime + Conductor.songPosition) / 2;
				Conductor.lastSongPos = Conductor.songPosition;
			}
		}

		if (generatedMusic && SONG.notes[Math.floor(curStep / 16)] != null) {
			if (camFollow.x != dad.getMidpoint().x + 150 && !SONG.notes[Math.floor(curStep / 16)].mustHitSection) {
				var offsetX = 0;
				var offsetY = 0;
				switch (SONG.player2) {
					case 'meatboy':
						offsetX = -220;
						offsetY = 100;
				}

				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
			}

			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100) {
				var offsetX = 0;
				var offsetY = 0;
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
			}		
		}

		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0) {
			if (!manImDead) {
				transition('GAMEIN');

				if (SepVocalsNull)
					vocals.stop();
				else
					for (vocals in [P1vocals, P2vocals])
						vocals.stop();
				
				FlxG.sound.music.stop();

				manImDead = true;
			}

			new FlxTimer().start(1, function(tmr:FlxTimer) {
				boyfriend.stunned = true;
	
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				FlxG.resetState(); 
			});
		}

		if (!inCutscene && FlxG.save.data.resetButton) {
			var resetBind = FlxKey.fromString(FlxG.save.data.resetBind);
			var gpresetBind = FlxKey.fromString(FlxG.save.data.gpresetBind);
			if ((FlxG.keys.anyJustPressed([resetBind]))) {
				health = 0;
			}
		}

		if (unspawnNotes[0] != null) {
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic) {
			//if (curSong.toLowerCase() == 'meaty') {
			//	if (FlxG.keys.justPressed.SPACE && !boyfriend.animation.curAnim.name.startsWith('jump'))
			//		boyfriend.playAnim('jump', true);
			
				// if (boyfriend.overlaps(dodgeSaw)) {
				// }
			//}
		
			//if (curSong.toLowerCase() == 'burnin') {
				//if (FlxG.keys.justPressed.SPACE && !boyfriend.animation.curAnim.name.startsWith('jump'))
				//	boyfriend.playAnim('jump', true);
		
				// if (boyfriend.overlaps(dodgeSaw)) {
				// }
			//}

			if (!inCutscene) {
				keyShit();
			}

			if (bfScared && !boyfriend.animation.curAnim.name.startsWith('scared'))
				boyfriend.playAnim('scared');

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.tooLate) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}
				if (FlxG.save.data.downscroll) {
					if (daNote.mustPress) 
						daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y 
							+ 0.45 * (Conductor.songPosition - daNote.strumTime)
							* FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
					else 
						daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y 
							+ 0.45 * (Conductor.songPosition - daNote.strumTime)
							* FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
					
					if (daNote.isSustainNote) {
						daNote.x += daNote.width / 2 + 20;
						daNote.y -= daNote.height / 2 - 50;
						if (daNote.animation.name.endsWith('end'))
							daNote.y -= daNote.height / 2 - 67.5;

						if (!FlxG.save.data.botplay) {
							if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2)) {
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						} else {
							var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
							swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				} else {
					if (daNote.mustPress) 
						daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y 
							- 0.45 * (Conductor.songPosition - daNote.strumTime) 
							* FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
					else 
						daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y 
							- 0.45 * (Conductor.songPosition - daNote.strumTime) 
							* FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
					
					if (daNote.isSustainNote) {
						daNote.y -= daNote.height / 2;

						if (!FlxG.save.data.botplay) {
							if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2)) {
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						} else {
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit) {
					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null) {
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData)) {
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
					}

					cpuStrums.forEach(function(spr:FlxSprite) {
						if (Math.abs(daNote.noteData) == spr.ID) {
							spr.animation.play('confirm', true);
						}
						if (spr.animation.curAnim.name == 'confirm') {
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						} else
							spr.centerOffsets();
					});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						if (SepVocalsNull)
							vocals.volume = 1;
						else
							for (vocals in [P1vocals, P2vocals])
								vocals.volume = 1;

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress) {
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				} else if (!daNote.wasGoodHit) {
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}

				if (daNote.isSustainNote) {
					daNote.x += daNote.width / 2 + 20;
					daNote.y += daNote.height / 2;
				}

				if ((daNote.mustPress && daNote.tooLate && !FlxG.save.data.downscroll || daNote.mustPress && daNote.tooLate && FlxG.save.data.downscroll)
					&& daNote.mustPress) {
					if (daNote.isSustainNote && daNote.wasGoodHit) {
						daNote.kill();
						notes.remove(daNote, true);
					} else {
						health -= 0.075;
						if (SepVocalsNull)
							vocals.volume = 0;
						else
							P1vocals.volume = 0;

						if (theFunne)
							noteMiss(daNote.noteData, daNote);
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		cpuStrums.forEach(function(spr:FlxSprite) {
			if (spr.animation.finished) {
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});
	}

	function endSong():Void 
	{
    #if mobile
    mobileControls.visible = false;
    #end
		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		canPause = false;
		FlxG.sound.music.stop();
		if (SepVocalsNull)
			vocals.stop();
		else
			for (vocals in [P1vocals, P2vocals])
				vocals.stop();
		if (SONG.validScore) {
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			
			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			#end
		}

		if (isStoryMode) {
			campaignScore += Math.round(songScore);

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0) {
				transition('INDAMNED');
				new FlxTimer().start(1, function(tmr:FlxTimer) {FlxG.switchState(new StoryMenuState()); });

				if (SONG.validScore) {
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}
				FlxG.save.flush();
				
				if (SepVocalsNull)
					vocals.stop();
				else
					for (vocals in [P1vocals, P2vocals])
						vocals.stop();
				
				FlxG.sound.music.stop();
				
				if (!FlxG.sound.music.playing) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					FlxG.sound.music.time = 3000;
				}
			} else {
				var nextSongLowercase = StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase();

				var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(nextSongLowercase, PlayState.storyPlaylist[0]);
				
				if (SepVocalsNull)
					vocals.stop();
				else
					for (vocals in [P1vocals, P2vocals])
						vocals.stop();
				
				FlxG.sound.music.stop();

				transition('GAMEIN');
				new FlxTimer().start(1, function(tmr:FlxTimer) {FlxG.switchState(new PlayState()); });
			}
		} else {
			if (SepVocalsNull)
				vocals.stop();
			else
				for (vocals in [P1vocals, P2vocals])
					vocals.stop();
			
			FlxG.sound.music.stop();
			
			transition('INDAMNED');
			new FlxTimer().start(1, function(tmr:FlxTimer) {Main.switchState(new FreeplayState()); });

			if (!FlxG.sound.music.playing) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.sound.music.time = 3000;
			}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];

	private function popUpScore(daNote:Note):Void {
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
		if (SONG.needsVoices)
			if (SepVocalsNull)
				vocals.volume = 1;
			else
				for (vocals in [P1vocals, P2vocals])
					vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;
		var daRating = daNote.rating;

		switch (daRating) {
			case 'shit':
				score = -300;
				health -= 0.2;
				ss = false;
				shits++;
				totalNotesHit += 0.25;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06;
				ss = false;
				bads++;
				totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (health < 2)
					health += 0.04;
				totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.1;
				totalNotesHit += 1;
				sicks++;
		}

		if (daRating == 'sick' && FlxG.save.data.noteSplashes) {
			var noteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			noteSplash.setupNoteSplash(daNote.x, strumLine.y, daNote.noteData);
			grpNoteSplashes.add(noteSplash);
		}

		if (daRating != 'shit' || daRating != 'bad') {
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			rating.loadGraphic(Paths.image(daRating, 'shared'));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit) {
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo', 'shared'));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			if (!FlxG.save.data.botplay)
				add(rating);

			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
			comboSpr.updateHitbox();
			rating.updateHitbox();
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 1) {
				seperatedScore.push(0);
				seperatedScore.push(0);
			} else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length) {
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore) {
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween) {
						numScore.destroy();
					}, startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			};

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					coolText.destroy();
					comboSpr.destroy();
					rating.destroy();
				}, startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool {
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void {
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];

		if (FlxG.save.data.botplay) {
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}
		
		if (holdArray.contains(true) && generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		} else if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.dadVar && (!holdArray.contains(true) || FlxG.save.data.botplay)) {
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && !boyfriend.animation.curAnim.name.startsWith('jump'))
				boyfriend.dance();
		}

		if (pressArray.contains(true) && generatedMusic) {
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var directionsAccounted:Array<Bool> = [false, false, false, false];

			notes.forEachAlive(function(daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					if (!directionsAccounted[daNote.noteData]) {
						if (directionList.contains(daNote.noteData)) {
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes) {
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
									dumbNotes.push(daNote);
									break;
								} else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						} else {
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				}
			});

			for (note in dumbNotes) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...pressArray.length) {
				if (pressArray[i] && !directionList.contains(i))
					dontCheck = true;
			}

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0 && !dontCheck) {
				if (!FlxG.save.data.ghost) {
					for (shit in 0...pressArray.length) {
						if (pressArray[shit] && !directionList.contains(shit))
							noteMiss(shit, null);
					}
				}
				for (coolNote in possibleNotes) {
					if (pressArray[coolNote.noteData]) {
						if (mashViolations != 0)
							mashViolations--;
						goodNoteHit(coolNote);
					}
				}
			} else if (!FlxG.save.data.ghost) {
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit, null);
			}

			if (dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost && !FlxG.save.data.botplay) {
				if (mashViolations > 8) {
					noteMiss(0, null);
				} else
					mashViolations++;
			}
		}

		notes.forEachAlive(function(daNote:Note) {
			if (FlxG.save.data.downscroll && daNote.y > strumLine.y || !FlxG.save.data.downscroll && daNote.y < strumLine.y) {
				if (FlxG.save.data.botplay && daNote.canBeHit && daNote.mustPress || FlxG.save.data.botplay && daNote.tooLate && daNote.mustPress) {
					goodNoteHit(daNote);
					boyfriend.holdTimer = daNote.sustainLength;
				}
			}
		});

		playerStrums.forEach(function(spr:FlxSprite) {
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm') {
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			} else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void {
		if (!boyfriend.stunned) {
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad')) {
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, 'shared'), FlxG.random.float(0.1, 0.2));

			switch (direction) {
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			updateAccuracy();
		}
	}

	function updateAccuracy() {
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);

		daRank.loadGraphic(Paths.image('ranks/' + Ratings.GenerateLetterRank(accuracy)));
	}

	function getKeyPresses(note:Note):Int {
		var possibleNotes:Array<Note> = [];

		notes.forEachAlive(function(daNote:Note) {
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate) {
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void {
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);

		if (controlArray[note.noteData]) {
			goodNoteHit(note, (mashing > getKeyPresses(note)));
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void {
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit) {
			if (!note.isSustainNote) {
				popUpScore(note);
				combo += 1;
				if (FlxG.save.data.hitsoundsVolume != 0)
					FlxG.sound.play(Paths.sound('hitsound', 'preload'), FlxG.save.data.hitsoundsVolume);
			} else
				totalNotesHit += 1;

			switch (note.noteData) {
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 0:
					boyfriend.playAnim('singLEFT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite) {
				if (Math.abs(note.noteData) == spr.ID)
					spr.animation.play('confirm', true);
			});

			note.wasGoodHit = true;
			if (SONG.needsVoices)
				if (SepVocalsNull)
					vocals.volume = 1;
				else
					for (vocals in [P1vocals, P2vocals])
						vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}

	function cinematicBars(appear:Bool) {
		if (appear) {
			FlxTween.tween(topBar, {y: 0}, 1, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 600}, 1, {ease: FlxEase.quadOut});
		} else {
			FlxTween.tween(topBar, {y: -170}, 1, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 720}, 1, {ease: FlxEase.quadOut});
		}
	}

	override function stepHit() {
		super.stepHit();

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		if (curSong.toLowerCase() == "meaty") {
			if (curStep == 128) {
				if (FlxG.save.data.bgNotesAlpha != 0) {
					FlxTween.tween(notesBgBoyfriend, {alpha: FlxG.save.data.bgNotesAlpha}, 1, {ease: FlxEase.quadInOut});
					FlxTween.tween(notesBgDad, {alpha: FlxG.save.data.bgNotesAlpha}, 1, {ease: FlxEase.quadInOut});
				}
			}

			if (curStep == 764) {
				middleScrollEventBf(true);
				FlxTween.tween(bfOnlyEvent, {alpha: 1}, 1, {ease: FlxEase.quadOut});
				defaultCamZoom = 1;
			}
	
			if (curStep == 896) {
				FlxTween.tween(bfOnlyEvent, {alpha: 0.25}, 8, {ease: FlxEase.quartInOut});
				defaultCamZoom = 0.8;
			}

			if (curStep == 1020) {
				middleScrollEventBf(false);
				FlxTween.tween(bfOnlyEvent, {alpha: 0}, 1, {ease: FlxEase.quartInOut});
				defaultCamZoom = 0.7;
			}
		}

		if (curSong.toLowerCase() == 'burnin') {
			if (curStep == 256) {
				FlxTween.tween(bfOnlyEvent, {alpha: 1}, 4.8, {ease: FlxEase.quartInOut});
				FlxTween.tween(FlxG.camera, {zoom: 1.05}, 4.8, {ease: FlxEase.quadInOut});
				if (FlxG.save.data.bgNotesAlpha != 0) {
					FlxTween.tween(notesBgBoyfriend, {alpha: FlxG.save.data.bgNotesAlpha}, 4.8, {ease: FlxEase.quadInOut});
					if (FlxG.save.data.middleScroll)
						FlxTween.tween(notesBgDad, {alpha: FlxG.save.data.bgNotesAlpha}, 4.8, {ease: FlxEase.quadInOut});
				}
				camZooming = true;

				bfScared = true;
			}

			if (curStep == 320) {
				FlxTween.tween(bfOnlyEvent, {alpha: 0}, 0.1, {ease: FlxEase.quartInOut});
				changeChar('drfetus', 1);
				changeChar('meatboyonfire', 0);
				flashyWashy.alpha = 1;
				FlxTween.tween(flashyWashy, {alpha: 0}, 1.5, {ease: FlxEase.cubeInOut});
				camZooming = false;
				
				//haha penis
				for (i in [bg, stuff, ground, bushes])
					i.alpha = 0.001;
				bushesFire.alpha = 1;
				
				defaultCamZoom = 0.7;

				bfScared = false;
			}

			if (curStep == 576) {
				defaultCamZoom = 0.9;
			}

			if (curStep == 704) {
				defaultCamZoom = 0.8;
			}

			if (curStep == 834) {
				defaultCamZoom = 0.7;
				cinematicBars(true);
			}

			if (curStep == 1344) {
				defaultCamZoom = 0.9;
				cinematicBars(false);
			}

			if (curStep == 1856) {
				defaultCamZoom = 0.8;
			}

			if (curStep == 2112) {
				defaultCamZoom = 0.7;
				cinematicBars(true);
			}

			if (curStep == 2128) {
				defaultCamZoom = 0.85;
			}

			if (curStep == 2368) {
				defaultCamZoom = 0.75;
			}

			if (curStep == 2624) {
				defaultCamZoom = 0.7;
				cinematicBars(false);
			}

			if (curStep == 2879) {
				defaultCamZoom = 0.9;
			}
		}

		#if windows
		songLength = FlxG.sound.music.length;
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " Rank: " + Ratings.GenerateLetterRank(accuracy),
			"Acc: " + HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	override function beatHit() {
		super.beatHit();

		if (generatedMusic)
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		if (SONG.notes[Math.floor(curStep / 16)] != null) {
			if (!camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
		}

		if (curSong.toLowerCase() == 'meaty') {
			if (curStep >= 256 && curStep <= 768 && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
	
				camZooming = true;
			}

			if (curStep >= 1024 && curStep <= 1548 && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
	
				camZooming = true;
			}

			if (curStep == 768 || curStep == 1548)
				camZooming = false;
		}

		if (curSong.toLowerCase() == 'burnin') {
			if (curStep >= 832 && curStep <= 1344 && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
	
				camZooming = true;
			}

			if (curStep >= 1472 && curStep <= 1600 && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
	
				camZooming = true;
			}

			if (curStep >= 1854 && curStep <= 2112 && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
	
				camZooming = true;
			}

			if (curStep >= 2128 && curStep <= 2368 && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.035;
	
				camZooming = true;
			}

			if (curStep >= 2384 && curStep <= 2624 && FlxG.camera.zoom < 1.35) {
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.035;
	
				camZooming = true;
			}

			if (curStep == 1344 || curStep == 1600 || curStep == 2112 || curStep == 2368 || curStep == 2624)
				camZooming = false;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		
		if (!hideGf && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
			gf.dance();
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned && !bfScared)
			boyfriend.dance();
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
			dad.dance();
	}
}