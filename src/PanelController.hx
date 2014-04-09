package;

import dungeons.MiscDungeonGenerator;
import flash.display.BitmapData;
import haxe.ui.toolkit.containers.TabView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.extended.Code;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.controls.Slider;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.Screen;
import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.events.UIEvent;
import utils.FileManager;
import utils.Utils;

class PanelController extends XMLController
{
	var visualizer:Visualizer;
	var tabview:TabView;
	var tab1:VBox;
	var tab2:VBox;
	
	public var codePopup(default, null):CodePopup;
	public var zoomSlider(default, null):Slider;
	
	public function new(visualizer:Visualizer)
	{
		super("assets/ui/visualizer.xml");
		this.visualizer = visualizer;
		
		tabview = getComponentAs("tabview", TabView);
		tabview.onChange = onTabChange;
		getComponentAs("gotoSourceCode", Button).onClick = onClickButton;
		zoomSlider = getComponentAs("zoomSlider", Slider);
		zoomSlider.onChange = onSliderChange;
		
		// TAB 1
		tab1 = getComponentAs("tab_01", VBox);
		tab1.findChild("generateBtn_01", Button, true).onClick = onClickButton;
		tab1.findChild("popupCSV", Button, true).onClick = onPopupCSV;
		tab1.findChild("popupASCII", Button, true).onClick = onPopupASCII;
		tab1.findChild("failSlider", Slider, true).onChange = onSliderChange;
		tab1.findChild("failInput", TextInput, true).onChange = onSliderInputChange;
		tab1.findChild("corridorSlider", Slider, true).onChange = onSliderChange;
		tab1.findChild("corridorInput", TextInput, true).onChange = onSliderInputChange;
		
		
		// TAB 2
		tab2 = getComponentAs("tab_02", VBox);
		tab2.findChild("generateBtn_02", Button, true).onClick = onClickButton;
		tab2.findChild("popupCSV", Button, true).onClick = onPopupCSV;
		tab2.findChild("popupASCII", Button, true).onClick = onPopupASCII;
		
		tab2.findChild("cellsXSlider", Slider, true).onChange = onSliderChange;
		tab2.findChild("cellsYSlider", Slider, true).onChange = onSliderChange;
		tab2.findChild("cellSizeSlider", Slider, true).onChange = onSliderChange;
		tab2.findChild("minRoomSizeSlider", Slider, true).onChange = onSliderChange;
		tab2.findChild("maxRoomSizeSlider", Slider, true).onChange = onSliderChange;
		
		tab2.findChild("cellsX", TextInput, true).onChange = onSliderInputChange;
		tab2.findChild("cellsY", TextInput, true).onChange = onSliderInputChange;
		tab2.findChild("cellSize", TextInput, true).onChange = onSliderInputChange;
		tab2.findChild("minRoomSize", TextInput, true).onChange = onSliderInputChange;
		tab2.findChild("maxRoomSize", TextInput, true).onChange = onSliderInputChange;
	}
	
	public function getAs<T>(id:String, type:Class<T>):Null<T>
	{
		if (tabview.selectedIndex == 0) {
			return tab1.findChild(id, type, true);
		}
		else if (tabview.selectedIndex == 1) {
			return tab2.findChild(id, type, true);
		}
		return null;
	}
	
	// don't work the way i want, it's called when changing values in it too...
	public function onTabChange(e:UIEvent):Void
	{
		var tabview:TabView = getComponentAs("tabview", TabView);
		//trace(tabview.selectedIndex);
	}
	
	public function onClickButton(e:UIEvent):Void
	{
		var button = e.getComponentAs(Button);
		
		if (button.id == "generateBtn_01")
		{
			// 1. Choose the algorithm to use
			DungeonManager.instance.create(MISC_ALGO);
			
			var options:MiscDungeonOptions = { };
			
			// get width
			var mapWidth:TextInput = getAs("mapWidth", TextInput);
			options.mapWidth = Std.int(Utils.clamp(Std.parseInt(mapWidth.text), 20, 500));
			mapWidth.text = Std.string(options.mapWidth);
			
			// get height
			var mapHeight:TextInput = getAs("mapHeight", TextInput);
			options.mapHeight = Std.int(Utils.clamp(Std.parseInt(mapHeight.text), 20, 500));
			mapHeight.text = Std.string(options.mapHeight);
			
			// get fail
			options.fail = Std.int(getAs("failSlider", Slider).value);
			
			// get corridor bias
			options.corridorBias = Std.int(getAs("corridorSlider", Slider).value);
			
			// max rooms
			var inputMaxRooms:TextInput = getAs("maxRooms", TextInput);
			options.maxRooms = Std.int(Utils.clamp(Std.parseInt(inputMaxRooms.text), 3, 5000));
			inputMaxRooms.text = Std.string(options.maxRooms);
			
			// 2. Generate dungeon with given options
			DungeonManager.instance.generate(options);
			
			// 3. Update UI infos
			getAs("roomsCount", Text).text = Std.string(DungeonManager.instance.generatedDungeon.roomCount);
			getAs("corridorsCount", Text).text = Std.string(DungeonManager.instance.generatedDungeon.corridorCount);
			
			// 4. display the dungeon map
			visualizer.buildMap(options.mapWidth, options.mapHeight, DungeonManager.instance.currentDungeon);
		}
		
		if (button.id == "generateBtn_02")
		{
			// 1. Choose the algorithm to use
			DungeonManager.instance.create(EDC_ALGO);
			
			var options:Dynamic = { };
			
			// get horizontal amount of cells
			options.cellsX = Std.int(getAs("cellsXSlider", Slider).value);
			
			// get vertical amount of cells
			options.cellsY = Std.int(getAs("cellsYSlider", Slider).value);
			
			// get cells size
			options.cellSize = Std.int(getAs("cellSizeSlider", Slider).value);
			
			// get min room size
			options.minRoomSize = Std.int(getAs("minRoomSizeSlider", Slider).value);
			
			// get max room size
			options.maxRoomSize = Std.int(getAs("maxRoomSizeSlider", Slider).value);
			
			// 2. Generate dungeon with given options
			try {
				DungeonManager.instance.generate(options);
			} catch (e:Dynamic) {
				var config:Dynamic = { };
				config.buttons = [PopupButton.OK];
				config.width = 600;
				config.height = 400;
				PopupManager.instance.showSimple("Sorry it crashed with this error :\n\n\"" + e + "\"\n\nTry again with smaller numbers maybe ?\n\n", "Crash", config);
				return;
			}
			
			// 3. Update UI infos
			getAs("roomsCount", Text).text = Std.string(DungeonManager.instance.generatedDungeon.roomCount);
			getAs("corridorsCount", Text).text = Std.string(DungeonManager.instance.generatedDungeon.corridorCount);
			
			// 4. display the dungeon map
			var width = Std.int(options.cellsX * options.cellSize);
			var height = Std.int(options.cellsY * options.cellSize);
			visualizer.buildMap(width, height, DungeonManager.instance.currentDungeon);
		}
		
		if (button.id == "gotoSourceCode") {
			gotoSourceCode();
		}
	}
	
	function onSliderChange(e:UIEvent):Void
	{
		var slider:Slider = e.getComponentAs(Slider);
		
		/* TAB 01 */
		
		// if failSlider -> update failInput
		if (slider.id == "failSlider") {
			getComponentAs("failInput", TextInput).text = slider.value;
		}
		// if corridorSlider -> update corridorInput
		if (slider.id == "corridorSlider") {
			getComponentAs("corridorInput", TextInput).text = slider.value;
		}
		
		/* TAB 02 */
		
		// if cellsXSlider -> update cellsX
		if (slider.id == "cellsXSlider") {
			getComponentAs("cellsX", TextInput).text = slider.value;
		}
		// if cellsYSlider -> update cellsY
		if (slider.id == "cellsYSlider") {
			getComponentAs("cellsY", TextInput).text = slider.value;
		}
		if (slider.id == "cellSizeSlider")
		{
			// update the text input
			getComponentAs("cellSize", TextInput).text = slider.value;
			
			// update siblings sliders
			if (slider.value >= 10)
			{
				var cellsXSlider = getComponentAs("cellsXSlider", Slider);
				updateSliderMaxValue(cellsXSlider, 8 + 20 - slider.value);
				var cellsYSlider = getComponentAs("cellsYSlider", Slider);
				updateSliderMaxValue(cellsYSlider, 8 + 20 - slider.value);
			}
			else
			{
				getComponentAs("cellsXSlider", Slider).max = 20;
				getComponentAs("cellsYSlider", Slider).max = 20;
			}
			
			// update min & max room so they don't overlap this slider's max value
			var maxRoomSlider = getComponentAs("maxRoomSizeSlider", Slider);
			updateSliderMaxValue(maxRoomSlider, slider.value);
			var minRoomSlider = getComponentAs("minRoomSizeSlider", Slider);
			updateSliderMaxValue(minRoomSlider, slider.value);
		}
		if (slider.id == "minRoomSizeSlider") {
			getComponentAs("minRoomSize", TextInput).text = slider.value;
		}
		if (slider.id == "maxRoomSizeSlider") {
			getComponentAs("maxRoomSize", TextInput).text = slider.value;
		}
		
		/* OTHER */
		
		// if zoom -> update scale
		if (slider.id == "zoomSlider") {
			visualizer.changeScale(slider.value);
		}
	}
	
	function onSliderInputChange(e:UIEvent):Void
	{
		var textinput:TextInput = e.getComponentAs(TextInput);
		
		/* TAB 01 */
		
		// if failInput -> update failSlider
		if (textinput.id == "failInput") {
			getComponentAs("failSlider", Slider).value = textinput.text;
		}
		// if corridorInput -> update corridorSlider
		if (textinput.id == "corridorInput") {
			getComponentAs("corridorSlider", Slider).value = textinput.text;
		}
		
		/* TAB 02 */
		
		// if cellsX input -> update cellsXSlider
		if (textinput.id == "cellsX") {
			getComponentAs("cellsXSlider", Slider).value = textinput.text;
		}
		// if cellsY input -> update cellsYSlider
		if (textinput.id == "cellsY") {
			getComponentAs("cellsYSlider", Slider).value = textinput.text;
		}
		if (textinput.id == "cellSize") {
			getComponentAs("cellSizeSlider", Slider).value = textinput.text;
		}
		if (textinput.id == "minRoomSize") {
			getComponentAs("minRoomSizeSlider", Slider).value = textinput.text;
		}
		if (textinput.id == "maxRoomSize") {
			getComponentAs("maxRoomSizeSlider", Slider).value = textinput.text;
		}
	}
	
	function updateSliderMaxValue(slider:Slider, value:Float):Void
	{
		slider.max = value;
		if (slider.pos > slider.max) {
			slider.pos = slider.max;
		}
	}
	
	/**
	 * TODO: remove if not used.
	 */
	function updateSliderSiblings(availableTotal:Int, callerValue:Float, slidersName:Array<String>):Void
	{
		var slidersList:Array<Slider> = new Array<Slider>();
		for (name in slidersName) {
			slidersList.push(getComponentAs(name, Slider));
		}
		var total:Int = 0;
		for (slider in slidersList) {
			total += Std.int(slider.value);
		}
		total += Std.int(callerValue);
		
		var delta:Int = availableTotal - total;
		
		for (slider in slidersList) {
			var value:Int = Std.int(slider.value);
			
			var newValue = Std.int(value + (delta / 2));
			if (newValue < 0) {
				newValue = 0;
			}
			slider.max = newValue;
		}
	}
	
	function onPopupASCII(e:UIEvent):Void
	{
		var popupButtonInfo = new PopupButtonInfo(PopupButton.CUSTOM, "Import this map", importMapASCII);
		makePopup(FileType.ASCII, "Edit as ASCII", popupButtonInfo);
	}
	
	function onPopupCSV(e:UIEvent):Void
	{
		var popupButtonInfo = new PopupButtonInfo(PopupButton.CUSTOM, "Import this map", importMapCSV);
		makePopup(FileType.CSV, "Edit as CSV", popupButtonInfo);
	}
	
	function makePopup(type:FileType, title:String, importButton:PopupButtonInfo):Void
	{
		codePopup = new CodePopup(visualizer, type);
		var config:Dynamic = { };
		config.buttons = [importButton, PopupButton.CANCEL];
		//config.modal = false;
		config.width = Screen.instance.width - 60;
		config.height = Screen.instance.height - 100;
		
		PopupManager.instance.showCustom(codePopup.view, title, config, function (b) {
			if (b == PopupButton.CUSTOM) {
				// when 'import' button is clicked, kind of hacky...
				importButton.fn(null);
			}
		});
	}
	
	function importMapASCII(e:UIEvent):Void
	{
		var mapDataASCII:String = codePopup.getComponentAs("editor-content", Code).text;
		mapDataASCII = StringTools.replace(mapDataASCII, "\r", "\n");
		var arrayMap = Utils.ascii2array(mapDataASCII);
		
		DungeonManager.instance.importDungeon(arrayMap);
		
		visualizer.buildMap(arrayMap[0].length, arrayMap.length, DungeonManager.instance.currentDungeon);
		
		getAs("roomsCount", Text).text = "?";
		getAs("corridorsCount", Text).text = "?";
	}
	
	function importMapCSV(e:UIEvent):Void
	{
		var mapDataCSV:String = codePopup.getComponentAs("editor-content", Code).text;
		mapDataCSV = StringTools.replace(mapDataCSV, "\r", "\n");
		var arrayMap = Utils.csv2array(mapDataCSV);
		
		DungeonManager.instance.importDungeon(arrayMap);
		
		visualizer.buildMap(arrayMap[0].length, arrayMap.length, DungeonManager.instance.currentDungeon);
		
		getAs("roomsCount", Text).text = "?";
		getAs("corridorsCount", Text).text = "?";
	}
	
	function gotoSourceCode():Void
	{
		Utils.openURL("https://github.com/julsam/dungeon-builder");
	}
}

class CodePopup extends XMLController
{
	var visualizer:Visualizer;
	
	public function new(visualizer:Visualizer, type:FileType)
	{
		super("assets/ui/editor.xml");
		this.visualizer = visualizer;
		
		var editorContainer:VBox = getComponentAs("editor-container", VBox);
		editorContainer.height = Screen.instance.height - 200;
		
		// get the content into the editor
		var editor:Code = getComponentAs("editor-content", Code);
		switch (type) {
			case FileType.CSV:
				editor.text = DungeonManager.instance.getTextReady(FileType.CSV);
			case FileType.ASCII:
				editor.text = DungeonManager.instance.getTextReady(FileType.ASCII);
		}
		
		// events for save & load buttons
		getComponentAs("popup_save_button", Button).onClick = function (e) {
			FileManager.instance.saveFile(editor.text, type);
		};
		getComponentAs("popup_load_button", Button).onClick = function (e) {
			FileManager.instance.loadFile(replaceEditorContent, type);
		};
	}
	
	/**
	 * Called when a file has finished loading, replace the content of the editor by the content of the file.
	 * @param	content     Content of the file.
	 */
	function replaceEditorContent(content:String):Void
	{
		var editor:Code = getComponentAs("editor-content", Code);
		editor.text = content;
	}
}
