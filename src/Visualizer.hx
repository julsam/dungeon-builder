package ;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.Lib;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.InputText;
import ru.stablex.ui.widgets.Slider;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Widget;

/**
 * ...
 * @author Julien Samama
 */
class Visualizer extends Sprite
{
	private static var MIN_WIDTH(default, null):Int		= 20;
	private static var MAX_WIDTH(default, null):Int 	= 1000;
	private static var MIN_HEIGHT(default, null):Int 	= 20;
	private static var MAX_HEIGHT(default, null):Int 	= 1000;
	private static var MIN_ROOMS(default, null):Int 	= 3;
	private static var MAX_ROOMS(default, null):Int 	= 1000;
	
	private var dungeonSprite:Sprite;
	private var dungeonWidth:Int;
	private var dungeonHeight:Int;
	private var fail:Int;
	private var corridorBias:Int;
	private var maxRooms:Int;
	
	private var mapData:String;
	
	public function new() 
	{
		super();
		
		UIBuilder.init('assets/ui/defaults.xml');
		flash.Lib.current.addChild(UIBuilder.buildFn('assets/ui/ui.xml')());
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
	}
	
	private function onAdded(event:Event):Void
	{
        removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(Event.ENTER_FRAME, update);
		
		// dungeon sprite
		dungeonSprite = new Sprite();
		var scale:Float = UIBuilder.getAs("zoomSlider", Slider).value;
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
		var zoomSLider:Slider = UIBuilder.getAs("zoomSlider", Slider);
		if ( e.delta < 0 ) {
			zoomSLider.value -= 1;
		} else {
			zoomSLider.value += 1;
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
	
	private function generateNewDungeon():Void
	{
		// get width
		var inputDungeonWidth:InputText = UIBuilder.getAs("dungeonWidth", InputText);
		dungeonWidth = Std.int(Utils.clamp(Std.parseInt(inputDungeonWidth.text), MIN_WIDTH, MAX_WIDTH));
		inputDungeonWidth.text = Std.string(dungeonWidth);
		
		// get height
		var inputDungeonHeight:InputText = UIBuilder.getAs("dungeonHeight", InputText);
		dungeonHeight = Std.int(Utils.clamp(Std.parseInt(inputDungeonHeight.text), MIN_HEIGHT, MAX_HEIGHT));
		inputDungeonHeight.text = Std.string(dungeonHeight);
		
		// get fail
		var sliderFail:Slider = UIBuilder.getAs("fail", Slider);
		fail = Std.int(sliderFail.value);
		
		// get corridor bias
		var sliderCorridorBias:Slider = UIBuilder.getAs("corridorBias", Slider);
		corridorBias = Std.int(sliderCorridorBias.value);
		
		// max rooms
		var inputMaxRooms:InputText = UIBuilder.getAs("maxRooms", InputText);
		maxRooms = Std.int(Utils.clamp(Std.parseInt(inputMaxRooms.text), MIN_ROOMS, MAX_ROOMS));
		inputMaxRooms.text = Std.string(maxRooms);
		
		// generate dungeon
		var dungeonBuild:DungeonBuilder = new DungeonBuilder();
		dungeonBuild.generate(dungeonWidth, dungeonHeight, fail, corridorBias, maxRooms);
		//dungeonBuild.print();
		
		UIBuilder.getAs("roomsCount", Text).text = "Number of rooms : " + dungeonBuild.roomList.length;
		UIBuilder.getAs("corridorsCount", Text).text = "Number of corridors : " + dungeonBuild.cList.length;
	
		if (dungeonSprite.numChildren >= 1) {
			dungeonSprite.removeChildAt(0);
		}
		var bd:BitmapData = new BitmapData(dungeonWidth, dungeonHeight);
		
		mapData = "";
		for (y in Utils.range([dungeonHeight])) {
			var line = "";
			for (x in Utils.range([dungeonWidth])) {
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
			}
			//trace(line);
			mapData += line + '\n';
		}
		
		var bitmap:Bitmap = new Bitmap(bd);
		dungeonSprite.addChild(bitmap);
	}
	
	private function changeScale(value:Float):Void
	{
		Utils.scaleFromCenter(dungeonSprite, value, value);
	}
	
	private function goToSourceCode():Void
	{
		Utils.openURL("http://github.com/julsam/dungeon-builder");
	}
	
	private function saveFile():Void
	{
		var file:FileReference = new FileReference();
		file.save(mapData, Date.now().getTime() + ".txt");
	}
}