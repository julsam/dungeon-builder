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
		//tab2.findChild("generateBtn_02", Button, true).onClick = parentClass.onClickButton;
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
			var bd:BitmapData = new BitmapData(options.mapWidth, options.mapHeight);
			visualizer.buildMap(options.mapWidth, options.mapHeight, DungeonManager.instance.currentDungeon);
		}
		
		if (button.id == "gotoSourceCode") {
			gotoSourceCode();
		}
	}
	
	function onSliderChange(e:UIEvent):Void
	{
		var slider:Slider = e.getComponentAs(Slider);
		
		// if failSlider -> update failInput
		if (slider.id == "failSlider") {
			getComponentAs("failInput", TextInput).text = slider.value;
		}
		// if corridorSlider -> update corridorInput
		if (slider.id == "corridorSlider") {
			getComponentAs("corridorInput", TextInput).text = slider.value;
		}
		// if zoom -> update scale
		if (slider.id == "zoomSlider") {
			visualizer.changeScale(slider.value);
		}
	}
	
	function onSliderInputChange(e:UIEvent):Void
	{
		var textinput:TextInput = e.getComponentAs(TextInput);
		
		// if failInput -> update failSlider
		if (textinput.id == "failInput") {
			getComponentAs("failSlider", Slider).value = textinput.text;
		}
		// if corridorInput -> update corridorSlider
		if (textinput.id == "corridorInput") {
			getComponentAs("corridorSlider", Slider).value = textinput.text;
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
