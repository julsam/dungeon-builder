package ;

import DungeonManager.DungeonAlgorithm;
import dungeons.IDungeonWrapper;
import dungeons.MiscDungeonWrapper;
import utils.FileManager.FileType;
import utils.Utils;

enum DungeonAlgorithm {
	ALGO_1;    // temp
	MISC_ALGO;
	NULL;
}

typedef TranslationTable = {
	var plainText:Array<String>;
	var csv:Array<Int>;
}

class DungeonManager
{
	//******************************************************************************************
	// Singleton stuff
	//******************************************************************************************
	private static var _instance:DungeonManager;
	public static var instance(get_instance, null):DungeonManager;
	private static function get_instance():DungeonManager {
		if (_instance == null) {
			_instance = new DungeonManager();
			_instance.init();
		}
		return _instance;
	}
	
	private function new()
	{
		
	}
	
	//******************************************************************************************
	// Interesting stuff start here
	//******************************************************************************************
	
	private static var miscTranslationTable:TranslationTable = { plainText: ['.', ' ', '#', '=', '=', '~'], csv: [0, 1, 2, 3, 4, 5] };
	
	private var generatedDungeon(default, null):IDungeonWrapper;
	private var importedDungeon(default, null):Array<Array<Dynamic>>;
	
	private var currentAlgorithm(default, null):DungeonAlgorithm;
	
	public var currentDungeon(get, null):Array<Array<Dynamic>>;
	function get_currentDungeon() {
		if (generatedDungeon != null) {
			return getPlainTextReady(generatedDungeon.getRawMap());
		} else if (importedDungeon != null) {
			return getPlainTextReady(importedDungeon);
		} else {
			return null;
		}
	}
	
	function init():Void
	{
		reset();
	}
	
	function reset():Void
	{
		generatedDungeon = null;
		currentAlgorithm = NULL;
		importedDungeon = null;
	}
	
	public function create(algorithm:DungeonAlgorithm):Void
	{
		reset();
		switch (algorithm)
		{
			case ALGO_1:
			default:
				generatedDungeon = new MiscDungeonWrapper();
			case MISC_ALGO:
				generatedDungeon = new MiscDungeonWrapper();
		}
	}
	
	public function generate(options:Dynamic=null):Void
	{
		generatedDungeon.generate(options);
	}
	
	public function importDungeon(array:Array<Array<Dynamic>>):Void
	{
		reset();
		
		importedDungeon = array;
	}
	
	/**
	 * Helper to get the data into string for a GUI Text component.
	 * @return
	 */
	public function getTextReady(ftype:FileType):String
	{
		if (ftype.equals(FileType.CSV))
		{	
			if (generatedDungeon != null) {
				return Utils.array2csv(generatedDungeon.getRawMap());
			} else {
				//var converted = currentDungeon.conversionInverted();
				//return Utils.array2csv(converted);
				return Utils.array2csv(getCsvReady(importedDungeon));
			}
		}
		else
		{
			if (generatedDungeon != null) {
				//var converted = generatedDungeon.converted();
				//return Utils.array2ascii(converted);
				return Utils.array2ascii(getPlainTextReady(generatedDungeon.getRawMap()));
			} else {
				return Utils.array2ascii(getPlainTextReady(importedDungeon));
			}
		}
	}
	
	/**
	 * Get an array that is CSV ready. Use the translation table to convert it from plain text.
	 * @param	source
	 * @return
	 */
	private function getCsvReady(source:Array<Array<Dynamic>>):Array<Array<Int>>
	{
		if (source == null && source.length < 1 && source[0].length < 1) {
			return null;
		}
		// if already decimal format
		if (Std.is(source[0][0], Int)) {
			return cast source;
		}
		var converted:Array<Array<Int>> = [];
		var row = source.length;
		for (y in 0...row)
		{
			var colArray = [];
			var col = source[y].length;
			for (x in 0...col)
			{
				var char:String = source[y][x];
				var table = miscTranslationTable.plainText;
				for (i in 0...table.length ) {
					if (char == table[i]) {
						colArray.push(miscTranslationTable.csv[i]);
						break;
					}
				}
			}
			converted.push(colArray);
		}
		return converted;
	}
	
	/**
	 * Get an array that is plain text (ascii) ready. Use the translation table to convert it from csv.
	 * @param	source
	 * @return
	 */
	private function getPlainTextReady(source:Array<Array<Dynamic>>):Array<Array<String>>
	{
		if (source == null && source.length < 1 && source[0].length < 1) {
			return null;
		}
		// if already decimal format
		if (Std.is(source[0][0], String)) {
			return cast source;
		}
		var converted:Array<Array<String>> = [];
		var row = source.length;
		for (y in 0...row)
		{
			var colArray = [];
			var col = source[y].length;
			for (x in 0...col)
			{
				var char:Int = source[y][x];
				var table = miscTranslationTable.csv;
				for (i in 0...table.length ) {
					if (char == table[i]) {
						colArray.push(miscTranslationTable.plainText[i]);
						break;
					}
				}
			}
			converted.push(colArray);
		}
		return converted;
	}
}
