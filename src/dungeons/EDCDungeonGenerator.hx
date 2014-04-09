/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Alexander Fast
 * Copyright (c) 2014 Julien Samama
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package dungeons;

import utils.Utils;

using utils.Utils;

/**
 * Dungeon Generator
 * Originally written in python by Alexander Fast (https://github.com/mizipzor/roguelike-dungeon-generator).
 * Ported to Haxe by Julien Samama
 */
class EDCDungeonGenerator //EvenlyDistributedCells EDCDungeon 
{
	public var cellsX(default, null):Int;
	public var cellsY(default, null):Int;
	public var cellSize(default, null):Int;
	public var minRoomSize(default, null):Int;
	public var maxRoomSize(default, null):Int;
	public var tiles(default, null):Array<Array<String>>;
	
	public var mapWidth(default, null):Int;
	public var mapHeight(default, null):Int;
	
	private var cells:Array<Array<Cell>>;
	private var rooms:Array<Array<TileTuple>>;
	private var lastCell:Cell;
	private var firstCell:Cell;

	public function new() 
	{
		
	}
	
	public function generate(cellsX:Int=5, cellsY:Int=5, cellSize:Int=8, minRoomSize:Int=3, maxRoomSize:Int=8)
	{
		this.cellsX = cellsX;
		this.cellsY = cellsY;
		this.cellSize = cellSize;
		this.minRoomSize = minRoomSize;
		this.maxRoomSize = maxRoomSize;
		
		// 1. Divide the map into a grid of evenly sized cells.
		createCells();
		
		// 2. Pick a random cell as the current cell and mark it as connected.
		var current:Cell = Utils.choice(Utils.choice(cells));
		lastCell = current;
		firstCell = current;
		current.connected = true;
		
		// 3. While the current cell has unconnected neighbor cells:
		connectUnconnectedNeighbors(current);
		
		// 4. While there are unconnected cells:
		connectAllCellsTogether();
		
		// 5. Pick 0 or more pairs of adjacent cells that are not connected and connect them.
		makeOptionnalConnections();
		
		// 6. Within each cell, create a room of random shape
		createRooms();
		
		// 7. For each connection between two cells:
		createCorridors();
		
		// 8. Place staircases in the cell picked in step 2 and the last cell visited in step 3b.
		var stairsUp = Utils.choice(firstCell.room);
		var stairsDown = Utils.choice(lastCell.room);
		
		
		/* 
		 * The generation is over, now we populate the 2d array with the data so it's more easy to read and export :
		 */
		
		// create tiles
		mapWidth = cellsX * cellSize;
		mapHeight = cellsY * cellSize;
		
		// fill all tiles with " "
		#if haxe3
			this.tiles = [for (y in 0...mapHeight) [for (x in 0...mapWidth) " "]];
		#else
			this.tiles = Utils.fillArray([mapHeight, mapWidth], " ");
		#end
		
		// fill the rooms with "."
		for (room in rooms) {
			for (tile in room) {
				tiles[tile.y][tile.x] = ".";
			}
		}
		
		// every tile adjacent to a floor is a wall
		for (y in 0...tiles.length) {
			for (x in 0...tiles[0].length) {
				var tile:String = tiles[y][x];
				if (tile != "." && Lambda.has(getNeighborTiles(x, y), '.')) {
					tiles[y][x] = "#";
				}
			}
		}
		
		// finally place the stairs
		tiles[stairsUp.y][stairsUp.x] = "<";
		tiles[stairsDown.y][stairsDown.x] = ">";
	}
	
	function createCells():Void
	{
		#if haxe3
			cells = [for (y in 0...cellsY) [for (x in 0...cellsX) null]];
		#else
			cells = Utils.fillArray([cellY, cellX], null);
		#end
		var cellsCount:Int = 0;
		for (y in 0...cellsY) {
			for (x in 0...cellsX) {
				var c:Cell = new Cell(x, y, cellsCount);
				cells[y][x] = c;
				cellsCount++;
			}
		}
	}
	
	/**
	 * Connect unconnected neighbors to the current cell
	 */
	function connectUnconnectedNeighbors(current:Cell):Void
	{
		while (true)
		{
			// get all neighbor cells not connected
			var unconnectedList:List<Cell> = Lambda.filter(getNeighborCells(current), function (x) return !x.connected);
			var unconnected:Array<Cell> = Lambda.array(unconnectedList);
			if (unconnected.length == 0) {
				break;
			}
			
			/* a. Connect to one of them. */
			var neighbor:Cell = Utils.choice(unconnected);
			current.connect(neighbor);
			
			/* b. Make that cell the current cell. */
			current = lastCell = neighbor;
		}
	}
	
	function connectAllCellsTogether():Void
	{
		while (Lambda.filter(cells.values(), function (x) return !x.connected).length > 0)
		{
			/* Pick a random connected cell with unconnected neighbors and connect to one of them. */
			var candidates:Array<Dynamic> = [];
			for (cell in Lambda.filter(cells.values(), function (x) return x.connected))
			{
				var neighbors:List<Cell> = Lambda.filter(getNeighborCells(cell), function (x) return !x.connected);
				if (neighbors.length == 0) {
					continue;
				}
				candidates.push([cell, neighbors]);
			}
			var candidateData:Array<Dynamic> = Utils.choice(candidates);
			var cell:Cell = candidateData[0];
			var neighbors:Array<Cell> = Lambda.array(candidateData[1]);
			cell.connect(Utils.choice(neighbors));
		}
	}
	
	function makeOptionnalConnections():Void
	{
		var extraConnections:Int = Utils.randint(Std.int((cellsX + cellsY) / 4), Std.int((cellsX + cellsY) / 1.2));
		var maxRetries:Int = 10;
		while (extraConnections > 0 && maxRetries > 0)
		{
			var cell:Cell = Utils.choice(cells.values());
			var neighbor:Cell = Utils.choice(getNeighborCells(cell));
			if (Lambda.has(neighbor.connectedTo, cell))
			{
				maxRetries -= 1;
				continue;
			}
			cell.connect(neighbor);
			extraConnections -= 1;
		}
	}
	
	/**
	 * Within each cell, create a room of random shape
	 */
	function createRooms():Void
	{
		rooms = [];
		for (cell in cells.values())
		{
			var width = Utils.randint(this.minRoomSize, this.maxRoomSize - 2);
			var height = Utils.randint(this.minRoomSize, this.maxRoomSize - 2);
			var x = (cell.x * cellSize) + Utils.randint(1, cellSize - width - 1);
			var y = (cell.y * cellSize) + Utils.randint(1, cellSize - height - 1);
			var floorTiles:Array<TileTuple> = [];
			for (i in 0...width) {
				for (j in 0...height) {
					floorTiles.push( { x: x + i, y: y + j } );
				}
			}
			cell.room = floorTiles;
			rooms.push(floorTiles);
		}
	}
	
	function createCorridors():Void
	{
		var connections:Map<String, Dynamic> = new Map<String, Dynamic>();
		for (c in cells.values()) {
			for (other in c.connectedTo) {
				// TODO: removing the sort() produce some interesting results:
				var sort:Array<Int> = Utils.sorted([c.id, other.id]);
				connections[sort[0] + " " + sort[1]] = [c.room, other.room];
				//connections[c.id + " " + other.id] = [c.room, other.room];
				//connections[other.id + " " + c.id] = [c.room, other.room];
			}
		}
		for (el in connections)
		{
			// a. Create a random corridor between the rooms in each cell.
			var a = el[0]; // room a
			var b = el[1]; // room b
			var start:TileTuple = Utils.choice(a);
			var end:TileTuple = Utils.choice(b);
			
			var corridor = [];
			var astar = new _AStar();
			var path = astar.search(start, end);
			for (tile in path)
			{
				if (!hasIn(a, tile) && !hasIn(b, tile)) {
					corridor.push(tile);
				}
			}
			rooms.push(corridor);
		}
	}
	
	
	/******************************************************************************
	 * Utils methods start here :
	 ******************************************************************************/
	
	function getNeighborCells(cell:Cell):Array<Cell>
	{
		var neighbors = [];
		// Loop through possible exits
		for (el in [[ -1, 0], [0, -1], [1, 0], [0, 1]]) {
			var x = el[0];
			var y = el[1];
			// check that we are not trying to access an index of the array
			if (cell.y + y >= 0 && cell.y + y < cells.length && cell.x + x >= 0 && cell.x + x < cells[0].length) {
				neighbors.push(cells[cell.y + y][cell.x + x]);
			}
		}
		return neighbors;
	}
	
	function getNeighborTiles(tx:Int, ty:Int):Array<String>
	{
		var neighbors = [];
		for (el in [[ -1, -1], [0, -1], [1, -1],
					[ -1, 0], [1, 0],
					[ -1, 1], [0, 1], [1, 1]])
		{
			var x = el[0];
			var y = el[1];
			// check that we are not trying to access an index of the array
			if (ty + y >= 0 && ty + y < tiles.length && tx + x >= 0 && tx + x < tiles[0].length) {
				neighbors.push(tiles[ty + y][tx + x]);
			}
		}
		return neighbors;
	}
	
	function isEqual(a:TileTuple, b:TileTuple):Bool
	{
		return a.x == b.x && a.y == b.y;
	}
	
	function hasIn(it:Array<Dynamic>, elt:TileTuple):Bool
	{
		for (el in it) {
			if (isEqual(el, elt)) {
				return true;
			}
		}
		return false;
	}
}

private typedef TileTuple = {
	var x:Int;
	var y:Int;
}

class Cell
{
	public var x:Int;
	public var y:Int;
	public var id:Int;
	public var connected:Bool;
	public var connectedTo:Array<Cell>;
	public var room:Array<TileTuple>;
	
	public function new(x:Int, y:Int, id:Int)
	{
		this.x = x;
		this.y = y;
		this.id = id;
		this.connected = false;
		this.connectedTo = new Array<Cell>();
		this.room = null;
	}
	
	public function connect(other:Cell):Void
	{
		connectedTo.push(other);
		other.connectedTo.push(this);
		connected = true;
		other.connected = true;
	}
	
	public inline function toString():String
	{
		return '(id: $id, x: $x, y: $y)';
	}
}

class _AStar
{
	private var start:TileTuple;
	private var goal:TileTuple;
	private var cameFrom:Map<String, TileTuple>;
	
	public function new() { }
	
	function isEqual(a:TileTuple, b:TileTuple):Bool
	{
		return a.x == b.x && a.y == b.y;
	}
	
	function hasIn(it:Map<Dynamic, Dynamic>, elt:TileTuple):Bool
	{
		for (el in it) {
			if (isEqual(el, elt)) {
				return true;
			}
		}
		return false;
	}
	
	function heuristic(a:TileTuple, b:TileTuple):Int
	{
		return Std.int(Math.abs(a.x - b.x) + Math.abs(a.y - b.y));
	}
	
	function reconstructPath(n:TileTuple):Array<TileTuple>
	{
		if (isEqual(n, start))
			return [n];
		return reconstructPath(cameFrom[Std.string(n)]).concat([n]);
	}
	
	function neighbors(n:TileTuple):Array<TileTuple>
	{
		return [ { x: n.x - 1, y: n.y }, { x: n.x + 1, y: n.y }, {x: n.x, y: n.y - 1}, { x: n.x, y: n.y + 1 } ];
	}
	
	public function search(start:TileTuple, goal:TileTuple):Array<TileTuple>
	{
		this.start = start;
		this.goal = goal;
		
		var closed = new Map<String, TileTuple>();
		var open:Map<String, TileTuple> = [ Std.string(this.start) => this.start ];
		cameFrom = new Map<String, TileTuple>();
		var gScore:Map<String, Int> = [ Std.string(this.start) => 0 ];
		var fScore:Map<String, Int> = [ Std.string(this.start) => heuristic(this.start, this.goal) ];
		
		while (Lambda.count(open) > 0)
		{
			var current:TileTuple = null;
			for (el in open)
			{
				if (current == null || fScore[Std.string(el)] < fScore[Std.string(current)]) {
					current = { x: el.x, y: el.y };
				}
			}
			
			if (isEqual(current, this.goal)) {
				return reconstructPath(this.goal);
			}
			open.remove(Std.string(current));
			closed[Std.string(current)] = current;
			
			for (neighbor in neighbors(current))
			{
				if (hasIn(closed, neighbor)) {
					continue;
				}
				
				if (!gScore.exists(Std.string(current))) {
					gScore[Std.string(current)] = 0;
				}
				var g:Int = gScore[Std.string(current)] + 1;
				
				if (!hasIn(open, neighbor) || g < gScore[Std.string(neighbor)])
				{
					cameFrom[Std.string(neighbor)] = current;
					gScore[Std.string(neighbor)] = g;
					fScore[Std.string(neighbor)] = gScore[Std.string(neighbor)] + heuristic(neighbor, this.goal);
					if (!hasIn(open, neighbor)) {
						open[Std.string(neighbor)] = neighbor;
					}
				}
			}
		}
		return new Array<TileTuple>();
	}
}

