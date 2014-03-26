package;

import haxe.ui.toolkit.containers.TabView;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.extended.Code;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.controls.Slider;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.events.UIEvent;

class PanelController extends XMLController
{
	var visualizer:Visualizer;
	var tabview:TabView;
	var tab1:VBox;
	
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
		//attachEvent()
		
		tab1 = getComponentAs("tab_01", VBox);
		tab1.findChild("generateBtn_01", Button, true).onClick = onClickButton;
		tab1.findChild("popupCSV", Button, true).onClick = onPopupCSV;
		tab1.findChild("popupASCII", Button, true).onClick = onPopupASCII;
		tab1.findChild("failSlider", Slider, true).onChange = onSliderChange;
		tab1.findChild("failInput", TextInput, true).onChange = onSliderInputChange;
		tab1.findChild("corridorSlider", Slider, true).onChange = onSliderChange;
		tab1.findChild("corridorInput", TextInput, true).onChange = onSliderInputChange;
		
		
		var tab2:VBox = getComponentAs("tab_02", VBox);
		//tab2.findChild("generateBtn_01", Button, true).onClick = parentClass.onClickButton;
		
	}
	
	public function getAs<T>(id:String, type:Class<T>):Null<T>
	{
		if (tabview.selectedIndex == 0) {
			return tab1.findChild(id, type, true);
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
		
		if (button.id == "generateBtn_01") {
			visualizer.generateNewDungeon();
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
		trace(e.getComponentAs(TextInput).id);
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
		makePopup("ASCII", "Edit as ASCII", new PopupButtonInfo(PopupButton.CUSTOM, "Import this map", importMapASCII));
	}
	
	function onPopupCSV(e:UIEvent):Void
	{
		makePopup("CSV", "Edit as CSV", new PopupButtonInfo(PopupButton.CUSTOM, "Import this map", importMapCSV));
	}
	
	function makePopup(type:String, title:String, importButton:PopupButtonInfo):Void
	{
		codePopup = new CodePopup(visualizer, type);
		var config:Dynamic = { };
		config.buttons = [importButton, PopupButton.CANCEL];
		//config.modal = false;
		config.width = 780;
		config.height = 600;
			
		PopupManager.instance.showCustom(codePopup.view, title, config, function (b) {
			if (b == PopupButton.CUSTOM) {
				// import button clicked, kind of hacky...
				importButton.fn(null);
			}
		});
	}
	
	function importMapASCII(e:UIEvent):Void
	{
		visualizer.importASCIIMap();
	}
	
	function importMapCSV(e:UIEvent):Void
	{
		visualizer.importCSVMap();
	}
	
	function onCustomPopupButtonClick(e:UIEvent):Void
	{
		trace("Callback : Custom button clicked !");
	}
	
	function gotoSourceCode():Void
	{
		Utils.openURL("https://github.com/julsam/dungeon-builder");
	}
}

class CodePopup extends XMLController
{
	var visualizer:Visualizer;
	
	public function new(visualizer:Visualizer, type:String)
	{
		super("assets/ui/editor.xml");
		this.visualizer = visualizer;
		
		var editor:Code = getComponentAs("editor-content", Code);
		if (type == "CSV") {
			editor.text = visualizer.mapDataCSV;
		} else {
			editor.text = visualizer.mapDataASCII;
		}
		
		getComponentAs("popup_save_button", Button).onClick = function (e) {
			if (type == "CSV") {
				visualizer.exportAsCSV();
			} else {
				visualizer.exportAsASCII();
			}
		};
		getComponentAs("popup_load_button", Button).onClick = function (e) {
			if (type == "CSV") {
				visualizer.loadCSVFile();
			} else {
				visualizer.loadASCIIFile();
			}
		};
		
	}
}