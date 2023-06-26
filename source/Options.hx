package;

import lime.app.Application;
import flixel.FlxG;
import openfl.Lib;
import flixel.util.FlxTimer;

class Option {
	public function new() {
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public var acceptType:Bool = false;

	public var waitingType:Bool = false;

	public final function getDisplay():String {
		return display;
	}

	public final function getAccept():Bool {
		return acceptValues;
	}

	public final function getDescription():String {
		return description;
	}

	public function getValue():String {
		return updateDisplay();
	};

	public function onType(text:String) {}

	public function press():Bool {
		return true;
	}

	private function updateDisplay():String {
		return "";
	}

	public function left():Bool {
		return false;
	}

	public function right():Bool {
		return false;
	}
}

class ChangeKeyBindsOption extends Option {
	public function new() {
		super();
		description = "Edit your keybindings";
	}

	public override function press():Bool {
		OptionsState.instance.selectedCatIndex = 4;
		OptionsState.instance.switchCat(OptionsState.instance.options[4], false);
		return false;
	}

	private override function updateDisplay():String {
		return "Edit Keybindings";
	}
}

class UpKeybind extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String) {
		if (waitingType) {
			FlxG.save.data.upBind = text;
			waitingType = false;
		}
	}

	public override function press() {
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String {
		return "UP: " + (waitingType ? "> " + FlxG.save.data.upBind + " <" : FlxG.save.data.upBind) + "";
	}
}

class DownKeybind extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String) {
		if (waitingType) {
			FlxG.save.data.downBind = text;
			waitingType = false;
		}
	}

	public override function press() {
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String {
		return "DOWN: " + (waitingType ? "> " + FlxG.save.data.downBind + " <" : FlxG.save.data.downBind) + "";
	}
}

class RightKeybind extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String) {
		if (waitingType) {
			FlxG.save.data.rightBind = text;
			waitingType = false;
		}
	}

	public override function press() {
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String {
		return "RIGHT: " + (waitingType ? "> " + FlxG.save.data.rightBind + " <" : FlxG.save.data.rightBind) + "";
	}
}

class LeftKeybind extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String) {
		if (waitingType) {
			FlxG.save.data.leftBind = text;
			waitingType = false;
		}
	}

	public override function press() {
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String {
		return "LEFT: " + (waitingType ? "> " + FlxG.save.data.leftBind + " <" : FlxG.save.data.leftBind) + "";
	}
}

class ResetBind extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptType = true;
	}

	public override function onType(text:String) {
		if (waitingType) {
			FlxG.save.data.resetBind = text;
			waitingType = false;
		}
	}

	public override function press() {
		waitingType = !waitingType;

		return true;
	}

	private override function updateDisplay():String {
		return "RESET: " + (waitingType ? "> " + FlxG.save.data.resetBind + " <" : FlxG.save.data.resetBind) + "";
	}
}

class DownscrollOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Scroll: < " + (FlxG.save.data.downscroll ? "Downscroll" : "Upscroll") + " >";
	}
}

class GhostTapOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Ghost Tapping: < " + (FlxG.save.data.ghost ? "Enabled" : "Disabled") + " >";
	}
}

class TimeBar extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.timeBar = !FlxG.save.data.timeBar;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Time Bar: < " + (FlxG.save.data.timeBar ? "Enabled" : "Disabled") + " >";
	}
}

class ScrollSpeedOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool {
		return false;
	}

	private override function updateDisplay():String {
		return "Scroll Speed: < " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed, 1) + " >";
	}

	override function right():Bool {
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String {
		return "Scroll Speed: < " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed, 1) + " >";
	}

	override function left():Bool {
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}

class FreeplayCutscenesOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.cutscenesInFreeplay = !FlxG.save.data.cutscenesInFreeplay;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Freeplay Cutscenes: < " + (!FlxG.save.data.cutscenesInFreeplay ? "Disabled" : "Enabled") + " >";
	}
}

class AccuracyOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Accuracy Display: < " + (!FlxG.save.data.accuracyDisplay ? "Disabled" : "Enabled") + " >";
	}
}

class ResetButtonOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Reset Button: < " + (!FlxG.save.data.resetButton ? "Disabled" : "Enabled") + " >";
	}
}

class OverlayOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Overlay: < " + (!FlxG.save.data.fps ? "Disabled" : "Enabled") + " >";
	}
}

class NotesBGAlpha extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool {
		return false;
	}

	private override function updateDisplay():String {
		return "Notes BG Alpha: < " + FlxG.save.data.bgNotesAlpha + " >";
	}

	override function right():Bool {
		if (FlxG.save.data.bgNotesAlpha >= 1)
			FlxG.save.data.bgNotesAlpha = 1;
		else
			FlxG.save.data.bgNotesAlpha = FlxG.save.data.bgNotesAlpha + 0.1;

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.bgNotesAlpha <= 0)
			FlxG.save.data.bgNotesAlpha = 0;
		else
			FlxG.save.data.bgNotesAlpha = FlxG.save.data.bgNotesAlpha - 0.1;

		return true;
	}

	override function getValue():String {
		return updateDisplay();
	}
}

class HitSoundsVolume extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool {
		return false;
	}

	private override function updateDisplay():String {
		return "Hitsounds Volume: < " + FlxG.save.data.hitsoundsVolume + " >";
	}

	override function right():Bool {
		if (FlxG.save.data.hitsoundsVolume >= 1)
			FlxG.save.data.hitsoundsVolume = 1;
		else
			FlxG.save.data.hitsoundsVolume = FlxG.save.data.hitsoundsVolume + 0.1;

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.hitsoundsVolume <= 0)
			FlxG.save.data.hitsoundsVolume = 0;
		else
			FlxG.save.data.hitsoundsVolume = FlxG.save.data.hitsoundsVolume - 0.1;

		return true;
	}

	override function getValue():String {
		return updateDisplay();
	}
}

class FPSCapOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool {
		return false;
	}

	private override function updateDisplay():String {
		return "FPS Cap: < " + FlxG.save.data.fpsCap + " >";
	}

	override function right():Bool {
		if (FlxG.save.data.fpsCap >= 290) {
			FlxG.save.data.fpsCap = 290;
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
		} else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool {
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String {
		return updateDisplay();
	}
}

class CustomizeGameplay extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String {
		return "Customize Gameplay";
	}
}

class NoteSplashes extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.noteSplashes = !FlxG.save.data.noteSplashes;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Note Splashes: < " + (FlxG.save.data.noteSplashes ? "Enabled" : "Disabled") + " >";
	}
}

class RatingCounterOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.ratingCounter = !FlxG.save.data.ratingCounter;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Rating Counter: < " + (FlxG.save.data.ratingCounter ? "Enabled" : "Disabled") + " >";
	}
}

class HideHUD extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.hidehud = !FlxG.save.data.hidehud;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Hide HUD: < " + (FlxG.save.data.hidehud ? "Enabled" : "Disabled") + " >";
	}
}

class MiddleScrollOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.middleScroll = !FlxG.save.data.middleScroll;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Middle Scroll: < " + (FlxG.save.data.middleScroll ? "Enabled" : "Disabled") + " >";
	}
}
class MemoryInfo extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		FlxG.save.data.MEMInfo = !FlxG.save.data.MEMInfo;
		display = updateDisplay();
		return true;
	}

	public override function right():Bool {
		left();
		return true;
	}

	private override function updateDisplay():String {
		return "Memory Info: < " + (FlxG.save.data.MEMInfo ? "Enabled" : "Disabled") + " >";
	}
}


class ResetScoreOption extends Option {
	var confirm:Bool = false;

	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if (!confirm) {
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.songScores = null;
		for (key in Highscore.songScores.keys())
			Highscore.songScores[key] = 0;
		
		confirm = false;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		return confirm ? "Confirm Score Reset" : "Reset Score";
	}
}

class ResetSettings extends Option {
	var confirm:Bool = false;

	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if (!confirm) {
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.scrollSpeed = 1;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.cutscenesInFreeplay = null;
		FlxG.save.data.ratingCounter = null;
		FlxG.save.data.bgNotesAlpha = null;
		FlxG.save.data.noteSplashes = null;
		FlxG.save.data.MEMInfo = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.middleScroll = null;
		FlxG.save.data.timeBar = null;
		FlxG.save.data.hidehud = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.ghost = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.upBind = null;
		FlxG.save.data.downBind = null;
		FlxG.save.data.rightBind = null;
		FlxG.save.data.leftBind = null;
		FlxG.save.data.resetBind = null;
		FlxG.save.data.hitsoundsVolume = null;
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		FlxG.resetState();

		KadeEngineData.initSave();
		confirm = false;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		return confirm ? "Confirm Settings Reset" : "Reset Settings";
	}
}
