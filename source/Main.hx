package;

import openfl.display.BlendMode;
import openfl.text.TextFormat;
import openfl.display.Application;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.system.System;

class Main extends Sprite {
	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var initialState:Class<FlxState> = TitleState;
	var zoom:Float = -1;
	var framerate:Int = 60;
	var skipSplash:Bool = true;
	var startFullscreen:Bool = false;

	var fpsCounter:Overlay;

	var game:FlxGame;

	public static function main():Void {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

    // Crash Handler by MAJigsaw
		SUtil.uncaughtErrorHandler();
		SUtil.checkFiles();

		if (stage != null) {
			init();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE)) {
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void {
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1) {
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		game = new FlxGame(gameWidth, gameHeight, initialState, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash, startFullscreen);

		addChild(game);

		fpsCounter = new Overlay(10, 3, gameWidth, gameHeight);
		addChild(fpsCounter);
		if (fpsCounter != null)
			fpsCounter.visible = FlxG.save.data.fps;
	}

	public function toggleFPS(fpsEnabled:Bool):Void {
		fpsCounter.visible = fpsEnabled;
	}

	public function setFPSCap(cap:Float) {
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float {
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float {
		return fpsCounter.currentFrames;
	}

	public static var persistentAssets:Array<FlxGraphic> = [];
	public static function dumpCache()
	{
		if (Main.dumping)
		{
			trace('removed ur mom');
			@:privateAccess
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null && !persistentAssets.contains(obj))
				{
					Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					openfl.Assets.cache.removeBitmapData(key);
				}
			}
			for (stuff in Assets.list(SOUND))
				Assets.cache.clear(stuff);
			System.gc();
		}
		Main.dumping = false;
	}

	public static var dumping:Bool = false;

	public static function switchState(target:FlxState)
	{
		dumping = true;
		FlxG.switchState(target);
	}
}
