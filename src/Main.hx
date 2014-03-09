package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

class Main extends Sprite 
{
	var inited:Bool;
	var bg:Sprite;
	
	public static function main() 
	{
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
		
		bg = new Sprite();
		drawBg();
		addChild(bg);
		
		addChild(new Visualizer());
	}
	
	function resize(e:Event):Void 
	{
		if (!inited) {
			init();
		} else {
			drawBg();
		}
	}
	
	function drawBg():Void
	{
		bg.graphics.beginFill(0x252222);
		bg.graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		bg.graphics.endFill();
	}
	
	function init():Void
	{
		if (inited) return;
		inited = true;

		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
	}
}
