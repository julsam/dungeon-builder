package utils;

import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.FileReference;
import flash.net.FileFilter;
import flash.utils.ByteArray;
import utils.FileManager.FileType;

enum FileType {
	ASCII;
	CSV;
}

class FileManager
{
	//******************************************************************************************
	// Singleton stuff
	//******************************************************************************************
	private static var _instance:FileManager;
	public static var instance(get_instance, null):FileManager;
	private static function get_instance():FileManager {
		if (_instance == null) {
			_instance = new FileManager();
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
	
	private var uploadFileRef:FileReference;
	private var _callbackOnFileLoaded:String->Void;
	
	private function init():Void
	{
		uploadFileRef = new FileReference();
		uploadFileRef.addEventListener(Event.SELECT, onFileSelected);
		uploadFileRef.addEventListener(Event.COMPLETE, onFileLoaded);
	}
	
	/**
	 * Save a file to user computer.
	 * @param	content
	 * @param	fileType
	 */
	public function saveFile(content:String, fileType:FileType):Void
	{
		content = StringTools.replace(content, "\r", "\n");
		var file:FileReference = new FileReference();
		switch (fileType) {
			case ASCII: file.save(content, Date.now().getTime() + ".txt");
			case CSV: file.save(content, Date.now().getTime() + ".csv");
		}
	}
	
	/**
	 * Get a file from user computer.
	 * @param	callbackFunction
	 * @param	fileType
	 */
	public function loadFile(callbackFunction:String->Void, fileType:FileType):Void
	{
		var fileFilter:FileFilter;
		switch (fileType) {
			case ASCII: fileFilter = new FileFilter("Text File", "*.txt");
			case CSV: fileFilter = new FileFilter("CSV File", "*.csv");
		}
		uploadFileRef.browse([fileFilter]);
		_callbackOnFileLoaded = callbackFunction;
	}
	
	private function onFileSelected(e:Event):Void
	{
		uploadFileRef.load();
	}
	
	private function onFileLoaded(e:Event):Void
	{
		var byteArray:ByteArray = uploadFileRef.data;
		var content:String = byteArray.readUTFBytes(byteArray.length);
		if (_callbackOnFileLoaded != null) {
			_callbackOnFileLoaded(content);
		}
	}
}
