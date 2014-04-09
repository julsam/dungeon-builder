package dungeons;

import dungeons.EDCDungeonGenerator;


class EDCDungeonWrapper implements IDungeonWrapper
{
	var dungeonBuild:EDCDungeonGenerator;
	
	public function new() 
	{
		dungeonBuild = new EDCDungeonGenerator();
		setDefaultOptionValues();
		options = { };
	}
	
	function setDefaultOptionValues():Void
	{
		defaultOptions = { cellsX: 5, cellsY: 5, cellSize: 8, minRoomSize: 3, maxRoomSize: 8 };
		defaultOptions.stepped = false;
	}
	
	/* INTERFACE dungeons.IDungeonWrapper */
	
	public var options(default, default):Dynamic;
	public var defaultOptions(default, null):Dynamic;
	
	public var roomCount(default, null):Int;
	public var corridorCount(default, null):Int;
	
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
		
		dungeonBuild.generate(options.cellsX, options.cellsY, options.cellSize, options.minRoomSize, options.maxRoomSize);
		
		this.corridorCount = 0;
		this.roomCount = Std.int(options.cellsX * options.cellsY);
	}
	
	public function getRawMap():Dynamic
	{
		return dungeonBuild.tiles.copy();
	}
}
