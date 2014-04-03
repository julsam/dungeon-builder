package dungeons;

interface IDungeonWrapper
{
	public var options(default, default):Dynamic;
	public var defaultOptions(default, null):Dynamic;
	
	public var roomCount(default, null):Int;
	public var corridorCount(default, null):Int;
	
	private var dungeonBuild:MiscDungeonGenerator; // TODO replace with IDungeonGenerator when it's done
	
	public function generate(options:Dynamic=null):Void;
	public function getRawMap():Dynamic;
}