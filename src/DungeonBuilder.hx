package;

/**
 * ...
 * @author Julien Samama
 */

/**
 * Dungeon builder originally written in Python by Steve Wallace
 * (http://roguebasin.roguelikedevelopment.org/index.php?title=Dungeon_builder_written_in_Python)
 * Ported in Haxe by Julien Samama <julien@philpep.org>
 * 
 * Usage:
 * 		var map:DungeonBuilder = new DungeonBuilder();
		map.generate(80, 40, 110, 50, 60);
		map.print();
 */
class DungeonBuilder
{
	public var roomList:Array<Array<Int>>;
	public var cList:Array<Array<Int>>;
	public var mapArr(default, null):Array<Dynamic>;
	
	public var mapWidth(default, null):Int;
	public var mapHeight(default, null):Int;
	
	public function new() 
	{
		roomList = new Array<Array<Int>>();
		cList = new Array<Array<Int>>();
	}
	
	/**
	 * Generate random layout of rooms, corridors and other features.
	 * @param   xsize       Width of the map area.
	 * @param   ysize       Height of the map area.
	 * @param	fail        A value from 1 upwards. The higer the value of fail, the greater the chance of larger dungeons being created. A low value (>10) tends to produce only a few rooms, a high value (<50) raises the chance that the whole map area will be used to create rooms (up to the value of mrooms).
	 * @param	b1          corridor bias. This is a value from 0 to 100 and represents the %chance a feature will be a corridor instead of a room. A value of 0 will produce rooms only, a value of 100 will produce corridors only.
	 * @param	mrooms	    Maximum number of rooms to create. This, combined with fail, can be used to create a specific number of rooms.
	 */
	public function generate(xsize:Int, ysize:Int, fail:Int, b1:Int, mrooms:Int):Void
	{
		mapWidth = xsize;
		mapHeight = ysize;
		
		mapArr = Utils.fillArray([ysize, xsize], 1);
		
		var mkr = makeRoom();
		var w = mkr.rwide, l = mkr.rlong, t = mkr.rtype;
		
		while (roomList.length == 0)
		{
			var y = Utils.randrange(0, ysize - 1 - l) + 1;
			var x = Utils.randrange(0, xsize - 1 - w) + 1;
			var p = placeRoom(l, w, x, y, xsize, ysize, 6, 0);
		}
		var failed = 0;
		while (failed < fail) // The lower the value that failed< , the smaller the dungeon
		{
			var chooseRoom = Utils.randrange(0, roomList.length);
			//trace("chooseRoom " + chooseRoom + " roomList.length " + roomList.length);
			// make exit
			var mer = makeExit(chooseRoom);
			var ex = mer.rx, ey = mer.ry, ex2 = mer.rx2, ey2 = mer.ry2, et = mer.rw;
			
			var feature = Utils.randrange(0, 100);
			if (feature < b1) { // Begin feature choosing (more features to be added here)
				var mcr = makeCorridor();
				w = mcr.w;
				l = mcr.l;
				t = mcr.t;
			} else {
				mkr = makeRoom();
				w = mkr.rwide;
				l = mkr.rlong;
				t = mkr.rtype;
			}
			
			var roomDone = placeRoom(l, w, ex2, ey2, xsize, ysize, t, et);
			
			//If placement failed increase possibility map is full
			if (roomDone == 0) {
				failed += 1;
			}
			// Possiblilty of linking rooms
			else if (roomDone == 2) {
				if (mapArr[ey2][ex2] == 0) {
					if (Utils.randrange(0, 100) < 7) {
						makePortal(ex, ey);
					}
					failed += 1;
				}
			}
			// Otherwise, link up the 2 rooms
			else {
				makePortal(ex, ey);
				failed = 0;
				if (t < 5) {
					var tc = [roomList.length - 1, ex2, ey2, t];
					cList.push(tc);
					joinCorridor(roomList.length - 1, ex2, ey2, t, 50);
				}
			}
			
			if (roomList.length == mrooms) {
				failed = fail;
			}
		}
		finalJoins();
	}
	
	public function print():Void
	{
		trace("Number of rooms: " + roomList.length);
		trace("Number of corridors: " + cList.length);
		for (y in Utils.range([mapHeight])) {
		   var line = "";
		   for (x in Utils.range([mapWidth])) {
			  if (mapArr[y][x]==0)
				 line += ".";
			  if (mapArr[y][x]==1)
				 line += " ";
			  if (mapArr[y][x]==2)
				 line += "#";
			  if (mapArr[y][x]==3 || mapArr[y][x]==4)
				 line += "=";
			  if (mapArr[y][x]==5)
				 line += "~";
		   }
		   trace(line);
		}
	}
	
	/**
	 * Randomly produce room size.
	 * @return Return an Anonymous Struct/Object
	 *          rwide       Width
	 *          rlong       Height
	 *          rtype       Type
	 */
	private function makeRoom():Dynamic
	{
		return { rwide : Utils.randrange(0, 8) + 3, rlong : Utils.randrange(0, 8) + 3, rtype : 5 };
	}
	
	/**
	 * Randomly produce corridor length and heading
	 * @return Return an Anonymous Struct/Object
	 *          w       Width
	 *          l       Height
	 *          t       Heading (0 = North, 1 = East, 2 = South, 3 = West)
	 */
	private function makeCorridor():Dynamic
	{
		var clength = Utils.randrange(0, 18) + 3;
		var heading = Utils.randrange(0, 4);
		var wd = 0, lg = 0;
		if (heading == 0) { // North
			wd = 1;
			lg = -clength;
		} else if (heading == 1) { // East
			wd = clength;
			lg = 1;
		} else if (heading == 2) { // South
			wd = 1;
			lg = clength;
		} else if (heading == 3) { // West
			wd = -clength;
			lg = 1;
		}
		return { w : wd, l : lg, t : heading };
	}
	
	/**
	 * Place feature if enough space and return canPlace as true or false.
	 * @param	ll          Height of the room
	 * @param	ww          Width of the room
	 * @param	xposs       X position of the room
	 * @param	yposs       Y position of the room
	 * @param	xsize       Map Width
	 * @param	ysize       Map Height
	 * @param	rty	        Type of room; can be a normal room or a corridor. 0 to 3 = corridor, 5 = normal room, 6 = starting room
	 * @param	ext         Exit Heading (0 = North wall, 1 = East wall, 2 = South wall, 3 = West wall)
	 * @return  Return whether placed is true/false if a room was placed of not.
	 */
	private function placeRoom(ll:Int, ww:Int, xposs:Int, yposs:Int, xsize:Int, ysize:Int, rty:Int, ext:Int):Int // int but should be bool
	{
		// Arrange for heading
		var xpos = xposs;
		var ypos = yposs;
		if (ll < 0) {
			ypos += ll + 1;
			ll = Std.int(Math.abs(ll));
		}
		if (ww < 0) {
			xpos += ww + 1;
			ww = Std.int(Math.abs(ww));
		}
		
		// Make offset if type is room
		if (rty == 5) {
			if (ext == 0 || ext == 2) {
				var offset = Utils.randrange(0, ww);
				xpos -= offset;
			} else {
				var offset = Utils.randrange(0, ll);
				ypos -= offset;
			}
		}
		
		// Then check if there is space
		var canPlace = 1;
		if (ww + xpos + 1 > xsize - 1 || ll + ypos + 1 > ysize) {
			canPlace = 0;
			return canPlace;
		} else if (xpos < 1 || ypos < 1) {
			canPlace = 0;
			return canPlace;
		} else {
			for (j in Utils.range([ll])) {
				for (k in Utils.range([ww])) {
					
					if (mapArr[ypos + j][xpos + k] != 1) {
						canPlace = 2;
					}
				}
			}
		}
		
		// If there is space, add to list of rooms
		if (canPlace == 1) {
			var temp = [ll, ww, xpos, ypos];
			roomList.push(temp);
			for (j in Utils.range([ll + 2])) { // then build walls
				for (k in Utils.range([ww + 2])) {
					mapArr[ypos - 1 + j][xpos - 1 + k] = 2;
				}
			}
			for (j in Utils.range([ll])) { // then build floors
				for (k in Utils.range([ww])) {
					mapArr[ypos + j][xpos + k] = 0;
				}
			}
		}
		
		return canPlace; // Return whether placed is true/false
	}
	
	/**
	 * Pick random wall and random point along that wall.
	 * @return	Return an Anonymous Struct/Object
	 *          rx      X position on the wall
	 *          ry      Y position
	 *          rx2     X position inside the room (1 step away from the exit)
	 *          ry2     Y position inside the room (1 step away from the exit)
	 *          rw      Heading (0 = North wall, 1 = East wall, 2 = South wall, 3 = West wall)
	 */
	private function makeExit(rn:Int):Dynamic
	{
		var room = roomList[rn];
		var rx:Int = 0, ry:Int = 0, rx2:Int = 0, ry2:Int = 0;
		var rw:Int = 0;
		while (true) {
			rw = Utils.randrange(0, 4);
			if (rw == 0) { // North wall
				rx = Utils.randrange(0, room[1]) + room[2];	// random x position on the north wall
				ry = room[3] - 1;							// y position don't change
				rx2 = rx;
				ry2 = ry - 1;
			} else if (rw == 1) { // East wall
				ry = Utils.randrange(0, room[0]) + room[3];
				rx = room[2] + room[1];
				rx2 = rx + 1;
				ry2 = ry;
			} else if (rw == 2) { // South wall
				rx = Utils.randrange(0, room[1]) + room[2];
				ry = room[3] + room[0];
				rx2 = rx;
				ry2 = ry + 1;
			} else if (rw == 3) { // West wall
				ry = Utils.randrange(0, room[0]) + room[3];
				rx = room[2] - 1;
				rx2 = rx - 1;
				ry2 = ry;
			}
			if (mapArr[ry][rx] == 2) { // if space is a wall, exit
				break;
			}
		}
		return { rx : rx, ry : ry, rx2 : rx2, ry2 : ry2, rw : rw }
	}
	
	/**
	 * Create doors in walls.
	 * @param	px      Portal's X position.
	 * @param	py      Portal's Y position.
	 */
	private function makePortal(px:Int, py:Int):Void
	{
		var ptype = Utils.randrange(0, 100);
		
		// secret door
		if (ptype > 90) {
			mapArr[py][px] = 5;
		}
		// closed door
		else if (ptype > 75) {
			mapArr[py][px] = 4;
		}
		// open door
		else if (ptype > 40) {
			mapArr[py][px] = 3;
		}
		// hole in the wall
		else {
			mapArr[py][px] = 0;
		}
	}
	
	/**
	 * Check corridor endpoint and make an exit if it links to another room.
	 * @param	cno     Room number (probably last room created in roomList)
	 * @param	xp      X position (is inside a room, one step away from the exit)
	 * @param	yp      Y position (is inside a room, one step away from the exit)
	 * @param	ed      Heading (0 = North wall, 1 = East wall, 2 = South wall, 3 = West wall)
	 * @param	psb     Chance of linking rooms
	 */
	private function joinCorridor(cno:Int, xp:Int, yp:Int, ed:Int, psb:Int):Void
	{
		var cArea = roomList[cno];
		var endx = 0, endy = 0;
		
		// Find the corridor endpoint
		if (xp != cArea[2] || yp != cArea[3]) {
			endx = xp - (cArea[1] - 1);
			endy = yp - (cArea[0] - 1);
		} else {
			endx = xp + (cArea[1] - 1);
			endy = yp + (cArea[0] - 1);
		}
		
		var checkExit = [];
		
		// North Corridor
		if (ed == 0) {
			if (endx > 1) {
				var coords = [endx - 2, endy, endx - 1, endy];
				checkExit.push(coords);
			}
			if (endy > 1) {
				var coords = [endx, endy - 2, endx, endy - 1];
				checkExit.push(coords);
			}
			if (endx < 78) {
				var coords = [endx + 2, endy, endx + 1, endy];
				checkExit.push(coords);
			}
		}
		// East corridor
		else if (ed == 1) {
			if (endy > 1) {
				var coords = [endx, endy - 2, endx, endy - 1];
				checkExit.push(coords);
			}
			if (endx < 78) {
				var coords = [endx + 2, endy, endx + 1, endy];
				checkExit.push(coords);
			}
			if (endy < 38) {
				var coords = [endx, endy + 2, endx, endy + 1];
				checkExit.push(coords);
			}
		}
		// South corridor
		else if (ed == 2) {
			if (endx < 78) {
				var coords = [endx + 2, endy, endx + 1, endy];
				checkExit.push(coords);
			}
			if (endy < 38) {
				var coords = [endx, endy + 2, endx, endy + 1];
				checkExit.push(coords);
			}
			if (endx > 1) {
				var coords = [endx - 2, endy, endx - 1, endy];
				checkExit.push(coords);
			}
		}
		// West corridor
		else if (ed == 3) {
			if (endx > 1) {
				var coords = [endx - 2, endy, endx - 1, endy];
				checkExit.push(coords);
			}
			if (endy > 1) {
				var coords = [endx, endy - 2, endx, endy - 1];
				checkExit.push(coords);
			}
			if (endy < 38) {
				var coords = [endx, endy + 2, endx, endy + 1];
				checkExit.push(coords);
			}
		}
		
		// Loop through possible exits
		for (i in 0...checkExit.length) {
			//trace(checkExit[i]);
			var xxx = checkExit[i][0];
			var yyy = checkExit[i][1];
			var xxx1 = checkExit[i][2];
			var yyy1 = checkExit[i][3];
			
			if (mapArr[yyy][xxx] == 0) { // if joins to a room
				if (Utils.randrange(0, 100) < psb) { // possibility of linking rooms
					makePortal(xxx1, yyy1);
				}
			}
		}
	}
	
	/**
	 * Final stage, loops through all the corridors to see if any can be joined to other rooms.
	 */
	private function finalJoins():Void
	{
		for (el in cList) {
			joinCorridor(el[0], el[1], el[2], el[3], 10);
		}
	}	
}
