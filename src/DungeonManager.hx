package ;

import DungeonManager.DungeonAlgorithm;
import dungeons.EDCDungeonWrapper;
import dungeons.IDungeonWrapper;
import dungeons.MiscDungeonWrapper;
import utils.FileManager.FileType;
import utils.Utils;

enum DungeonAlgorithm {
	EDC_ALGO;
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
	private static var edcTranslationTable:TranslationTable = { plainText: ['.', ' ', '#', '=', '>', '<'], csv: [0, 1, 2, 3, 4, 5] };
	
	private var currentTranslationTable(get, null):TranslationTable;
	function get_currentTranslationTable()
	{
		switch (currentAlgorithm)
		{
			case MISC_ALGO:
				return miscTranslationTable;
			default: // EDC_ALGO
				return edcTranslationTable;
		}
	}
	
	public var generatedDungeon(default, null):IDungeonWrapper;
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
			case MISC_ALGO:
				currentAlgorithm = MISC_ALGO;
				generatedDungeon = new MiscDungeonWrapper();
			default: // EDC_ALGO
				currentAlgorithm = EDC_ALGO;
				generatedDungeon = new EDCDungeonWrapper();
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
				return Utils.array2csv(getCsvReady(generatedDungeon.getRawMap()));
			} else {
				return Utils.array2csv(getCsvReady(importedDungeon));
			}
		}
		else
		{
			if (generatedDungeon != null) {
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
				var table = currentTranslationTable.plainText;
				for (i in 0...table.length ) {
					if (char == table[i]) {
						colArray.push(currentTranslationTable.csv[i]);
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
				var table = currentTranslationTable.csv;
				for (i in 0...table.length ) {
					if (char == table[i]) {
						colArray.push(currentTranslationTable.plainText[i]);
						break;
					}
				}
			}
			converted.push(colArray);
		}
		return converted;
	}
}
