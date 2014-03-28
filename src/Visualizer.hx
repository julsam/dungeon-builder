package ;

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

enum BuildType {
	GEN;
	CSV;
	ASCII;
}

class Visualizer extends Sprite
{
	private static inline var MIN_WIDTH:Int 	= 20;
	private static inline var MAX_WIDTH:Int 	= 1000;
	private static inline var MIN_HEIGHT:Int 	= 20;
	private static inline var MAX_HEIGHT:Int 	= 1000;
	private static inline var MIN_ROOMS:Int 	= 3;
	private static inline var MAX_ROOMS:Int 	= 1000;
	
	private var dungeonBuild:DungeonBuilder;
	private var dungeonSprite:Sprite;
	private var dungeonWidth:Int;
	private var dungeonHeight:Int;
	private var fail:Int;
	private var corridorBias:Int;
	private var maxRooms:Int;
	
	private var nextBuild:BuildType;
	public var mapDataASCII:String;
	public var mapDataCSV:String;
	
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
		// get width
		var mapWidth:TextInput = panel.getAs("mapWidth", TextInput);
		dungeonWidth = Std.int(Utils.clamp(Std.parseInt(mapWidth.text), MIN_WIDTH, MAX_WIDTH));
		mapWidth.text = Std.string(dungeonWidth);
		
		// get height
		var mapHeight:TextInput = panel.getAs("mapHeight", TextInput);
		dungeonHeight = Std.int(Utils.clamp(Std.parseInt(mapHeight.text), MIN_HEIGHT, MAX_HEIGHT));
		mapHeight.text = Std.string(dungeonHeight);
		
		// get fail
		var failSlider:Slider = panel.getAs("failSlider", Slider);
		fail = Std.int(failSlider.value);
		
		// get corridor bias
		var corridorSlider:Slider = panel.getAs("corridorSlider", Slider);
		corridorBias = Std.int(corridorSlider.value);
		
		// max rooms
		var inputMaxRooms:TextInput = panel.getAs("maxRooms", TextInput);
		maxRooms = Std.int(Utils.clamp(Std.parseInt(inputMaxRooms.text), MIN_ROOMS, MAX_ROOMS));
		inputMaxRooms.text = Std.string(maxRooms);
		
		/* generate dungeon */
		dungeonBuild = new DungeonBuilder();
		dungeonBuild.generate(dungeonWidth, dungeonHeight, fail, corridorBias, maxRooms);
		//dungeonBuild.print();
		
		panel.getAs("roomsCount", Text).text = Std.string(dungeonBuild.roomList.length);
		panel.getAs("corridorsCount", Text).text = Std.string(dungeonBuild.cList.length);
	
		nextBuild = BuildType.GEN;
		createDungeonBitmap();
	}
	
	private function createDungeonBitmap():Void
	{
		if (dungeonSprite.numChildren >= 1) {
			dungeonSprite.removeChildAt(0);
		}
		var bd:BitmapData = new BitmapData(dungeonWidth, dungeonHeight);
		
		if (nextBuild.equals(BuildType.CSV)) {
			buildFromCSV(bd);
		} else if (nextBuild.equals(BuildType.ASCII)) {
			buildFromASCII(bd);
		} else {
			buildFromNewGeneration(bd);
		}
		
		var bitmap:Bitmap = new Bitmap(bd);
		dungeonSprite.addChild(bitmap);
	}
	
	private function buildFromNewGeneration(bd:BitmapData):Void
	{
		mapDataASCII = "";
		mapDataCSV = "";
		for (y in 0...dungeonBuild.mapHeight) {
			var line = "";
			for (x in 0...dungeonBuild.mapWidth) {
				if (dungeonBuild.mapArr[y][x] == 0) {	// walkable tile
					line += ".";
					bd.setPixel(x, y, 0xede9ac);
				}
				if (dungeonBuild.mapArr[y][x] == 1) {	// out of the dungeon
					line += " ";
					bd.setPixel(x, y, 0x302f2d);
				}
				if (dungeonBuild.mapArr[y][x] == 2) {	// wall
					line += "#";
					bd.setPixel(x, y, 0xe93c40);
				}
				if (dungeonBuild.mapArr[y][x] == 3) {	// opened door
					line += "=";
					bd.setPixel(x, y, 0x1f8bc3);
				}
				if (dungeonBuild.mapArr[y][x] == 4) {	// closed door
					line += "=";
					bd.setPixel(x, y, 0x1f8bc3);
				}
				if (dungeonBuild.mapArr[y][x] == 5) {	// secret door
					line += "~";
					bd.setPixel(x, y, 0xeb970f);
				}
				// csv endline check
				mapDataCSV += dungeonBuild.mapArr[y][x];
				if (x < dungeonWidth - 1) {
					 mapDataCSV += ",";
				}
			}
			mapDataASCII += line + '\n';
			if (y < dungeonHeight - 1) {
				mapDataCSV += '\n';
			}
		}
	}
	
	private function buildFromCSV(bd:BitmapData):Void
	{
		mapDataASCII = "";
		
		var row:Array<String> = mapDataCSV.split('\n'),
			rows:Int = row.length,
			col:Array<String>, cols:Int, x:Int, y:Int;
		for (y in 0...rows)
		{
			col = row[y].split(',');
			cols = col.length;
			var line = "";
			
			for (x in 0...cols)
			{
				if (col[x] == '0') {	// walkable tile
					line += ".";
					bd.setPixel(x, y, 0xede9ac);
				}
				if (col[x] == '1') {	// out of the dungeon
					line += " ";
					bd.setPixel(x, y, 0x302f2d);
				}
				if (col[x] == '2') {	// wall
					line += "#";
					bd.setPixel(x, y, 0xe93c40);
				}
				if (col[x] == '3') {	// opened door
					line += "=";
					bd.setPixel(x, y, 0x1f8bc3);
				}
				if (col[x] == '4') {	// closed door
					line += "=";
					bd.setPixel(x, y, 0x1f8bc3);
				}
				if (col[x] == '5') {	// secret door
					line += "~";
					bd.setPixel(x, y, 0xeb970f);
				}
			}
			mapDataASCII += line + '\n';
		}
	}
	
	private function buildFromASCII(bd:BitmapData):Void
	{
		mapDataCSV = "";
		
		var row:Array<String> = mapDataASCII.split('\n'),
			rows:Int = row.length,
			col:Array<String>, cols:Int, x:Int, y:Int;
		for (y in 0...rows)
		{
			col = row[y].split('');
			cols = col.length;
			
			for (x in 0...cols)
			{
				if (col[x] == '.') {	// walkable tile
					mapDataCSV += "0";
					bd.setPixel(x, y, 0xede9ac);
				}
				if (col[x] == ' ') {	// out of the dungeon
					mapDataCSV += "1";
					bd.setPixel(x, y, 0x302f2d);
				}
				if (col[x] == '#') {	// wall
					mapDataCSV += "2";
					bd.setPixel(x, y, 0xe93c40);
				}
				if (col[x] == '=') {	// opened door
					mapDataCSV += "3";
					bd.setPixel(x, y, 0x1f8bc3);
				}
				if (col[x] == '=') {	// closed door
					mapDataCSV += "4";
					bd.setPixel(x, y, 0x1f8bc3);
				}
				if (col[x] == '~') {	// secret door
					mapDataCSV += "5";
					bd.setPixel(x, y, 0xeb970f);
				}
				// csv endline check
				if (x < dungeonWidth - 1) {
					 mapDataCSV += ",";
				}
			}	
			if (y < dungeonHeight - 1) {
				mapDataCSV += '\n';
			}
		}
	}
	
	public function changeScale(value:Float):Void
	{
		Utils.scaleFromCenter(dungeonSprite, value, value);
	}
	
	/**
	 * Get the content of the editor and load it into the dungeon visualizer.
	 */
	public function importASCIIMap():Void
	{
		mapDataASCII = panel.codePopup.getComponentAs("editor-content", Code).text;
		mapDataASCII = StringTools.replace(mapDataASCII, "\r", "\n");
		
		nextBuild = BuildType.ASCII;
		createDungeonBitmap();
		
		panel.getAs("roomsCount", Text).text = "?";
		panel.getAs("corridorsCount", Text).text = "?";
	}
	
	/**
	 * Get the content of the editor and load it into the dungeon visualizer.
	 */
	public function importCSVMap():Void
	{
		mapDataCSV = panel.codePopup.getComponentAs("editor-content", Code).text;
		mapDataCSV = StringTools.replace(mapDataCSV, "\r", "\n");
		
		nextBuild = BuildType.CSV;
		createDungeonBitmap();
		
		panel.getAs("roomsCount", Text).text = "?";
		panel.getAs("corridorsCount", Text).text = "?";
	}
}
