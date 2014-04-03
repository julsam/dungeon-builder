package ;

import dungeons.MiscDungeonGenerator;
import DungeonManager.DungeonAlgorithm;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import haxe.ui.toolkit.controls.extended.Code;
import haxe.ui.toolkit.controls.Slider;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.style.Style;
import haxe.ui.toolkit.style.StyleManager;
import openfl.Assets;
import utils.Utils;

class Visualizer extends Sprite
{
	private var dungeonSprite:Sprite;
	private var panel:PanelController;

	public function new()
	{
		super();
		
		Macros.addStyleSheet("assets/ui/style.css");
		var f = Assets.getFont("assets/fonts/Roboto-Regular.ttf");
		StyleManager.instance.addStyle("#title", new Style( { fontName: f.fontName, fontEmbedded: true } ));
        Toolkit.init();
        Toolkit.openFullscreen(function(root:Root) {
			panel = new PanelController(this);
			root.addChild(panel.view);
		});
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function onAdded(event:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.ENTER_FRAME, update);
		
		parent.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		// dungeon sprite
		dungeonSprite = new Sprite();
		var scale:Float = panel.zoomSlider.value;
		dungeonSprite.scaleX = scale;
		dungeonSprite.scaleY = scale;
		
		dungeonSprite.addEventListener(MouseEvent.MOUSE_DOWN, dungeonClicked);
		addChild(dungeonSprite);
		
		generateNewDungeon();
		
		dungeonSprite.x = (Lib.current.stage.width / 2) + 200 / 2 - dungeonSprite.width / 2;
		dungeonSprite.y = Lib.current.stage.height / 2 - dungeonSprite.height / 2;
	}
	
	private function onMouseWheel(e:MouseEvent):Void
	{
		panel.zoomSlider;
		if ( e.delta < 0 ) {
			panel.zoomSlider.value -= 1;
		} else {
			panel.zoomSlider.value += 1;
		}
	}
	
	private function update(e:Event):Void 
	{
		
	}
	
	private function dungeonClicked(e:MouseEvent):Void
	{
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, dungeonReleased);
		dungeonSprite.startDrag();
	}
	
	private function dungeonReleased(e:MouseEvent):Void
	{
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, dungeonReleased);
		dungeonSprite.stopDrag();
	}
	
	public function generateNewDungeon():Void
	{
		// 1. Choose the algorithm to use
		DungeonManager.instance.create(DungeonAlgorithm.MISC_ALGO);
		
		// 2. Generate dungeon with default options
		DungeonManager.instance.generate();
		
		// 3. Update UI infos
		panel.getAs("roomsCount", Text).text = Std.string(DungeonManager.instance.generatedDungeon.roomCount);
		panel.getAs("corridorsCount", Text).text = Std.string(DungeonManager.instance.generatedDungeon.corridorCount);
		
		// 4. display the dungeon map
		var options:MiscDungeonOptions = DungeonManager.instance.generatedDungeon.defaultOptions;
		var bd:BitmapData = new BitmapData(options.mapWidth, options.mapHeight);
		buildMap(options.mapWidth, options.mapHeight, DungeonManager.instance.currentDungeon);
	}
	
	public function createBitmap(bd:BitmapData):Void
	{
		if (dungeonSprite.numChildren >= 1) {
			dungeonSprite.removeChildAt(0);
		}
		var bitmap:Bitmap = new Bitmap(bd);
		dungeonSprite.addChild(bitmap);
	}
	
	public function buildMap(bdWidth:Int, bdHeight:Int, mapData:Array<Array<Dynamic>>):Void
	{
		var bd:BitmapData = new BitmapData(bdWidth, bdHeight);
		
		var row = mapData.length;
		for (y in 0...row)
		{
			var line = "";
			var col = mapData[y].length;
			for (x in 0...col)
			{
				if (mapData[y][x] == '.') {	// walkable tile
					bd.setPixel(x, y, 0xede9ac);
				}
				else if (mapData[y][x] == ' ') { // out of the dungeon
					bd.setPixel(x, y, 0x302f2d);
				}
				else if (mapData[y][x] == '#') { // wall
					bd.setPixel(x, y, 0xe93c40);
				}
				else if (mapData[y][x] == '=') { // opened door
					bd.setPixel(x, y, 0x1f8bc3);
				}
				else if (mapData[y][x] == '=') { // closed door
					bd.setPixel(x, y, 0x1f8bc3);
				}
				else if (mapData[y][x] == '~') { // secret door
					bd.setPixel(x, y, 0xeb970f);
				}
			}
		}
		createBitmap(bd);
	}
	
	public function changeScale(value:Float):Void
	{
		Utils.scaleFromCenter(dungeonSprite, value, value);
	}
}
