package dungeons;

class MiscDungeonWrapper implements IDungeonWrapper
{
	public var options(default, default):Dynamic;
	public var defaultOptions(default, null):Dynamic;
	
	public var roomCount(default, null):Int;
	public var corridorCount(default, null):Int;
	
	var dungeonBuild:MiscDungeonGenerator;
	
	public function new() 
	{
		dungeonBuild = new MiscDungeonGenerator();
		setDefaultOptionValues();
		options = { };
	}
	
	public function generate(opt:Dynamic=null):Void 
	{
		options = { };
		if (opt != null)
		{
			for (field in Reflect.fields(defaultOptions)) {
				if (Reflect.hasField(opt, field)) {
					Reflect.setField(options, field, Reflect.field(opt, field));
				} else {
					Reflect.setField(options, field, Reflect.field(defaultOptions, field));
				}
			}
		}
		else
		{
			options = defaultOptions;
		}
		
		dungeonBuild.generate(options.mapWidth, options.mapHeight, options.fail, options.corridorBias, options.maxRooms);
		
		this.corridorCount = dungeonBuild.cList.length;
		this.roomCount = dungeonBuild.roomList.length;
	}
	
	/**
	 * Get a copy of the internal representation of the map. (here it's a 2d array)
	 * @return  Copied array.
	 */
	public function getRawMap():Dynamic
	{
		return dungeonBuild.mapArr.copy();
	}
	
	function setDefaultOptionValues():Void
	{
		defaultOptions = { mapWidth: 80, mapHeight:80, fail: 200, corridorBias: 5, maxRooms: 60 };
		defaultOptions.stepped = false;
	}
}
