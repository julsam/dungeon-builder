/* 
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Steve Wallace
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

typedef MiscDungeonOptions = { // make it a class & Options Interface
	?mapWidth:Int,
	?mapHeight:Int,
	?fail:Int,
	?corridorBias:Int,
	?maxRooms:Int,
	
	?stepped:Bool,
	?minRoomWidth:Int,
	?maxRoomWidth:Int,
	?minRoomHeight:Int,
	?maxRoomHeight:Int
}

/**
 * Dungeon builder originally written in Python by Steve Wallace
 * (http://roguebasin.roguelikedevelopment.org/index.php?title=Dungeon_builder_written_in_Python)
 * Ported to Haxe by Julien Samama
 * 
 * Usage:
 * 		var map:DungeonBuilder = new DungeonBuilder();
		map.generate(80, 40, 110, 50, 60);
		map.print();
 */
class MiscDungeonGenerator
{
	/**
	 * This is a list of every room (inc. corridors) and roomList[n] will be a list 
	 * in the form of [y size of room, x size of room, x coord, y coord] ie a value of [4,5,2,6]
	 * will be a room 5 across and 4 down with its top left floor tile at coord 2,6. This shouldn't 
	 * be edited as any changes made after its created will NOT reflect on the map, 
	 * its purely a reference to the floor area of the map.
	 */
	public var roomList:Array<Array<Int>>;
	
	/**
	 * This is similar to roomList, but it purely contains the corridors only and is used for connecting corridors. 
	 * Its value will be in the format [ref. no to roomList, start x coord, start y coord, direction it travels]. 
	 * The reference number will give the index to its entry in roomList, x and y start coords will be the 
	 * coordinate where the corridor actually starts (NOTE this may not be the same as its x and y pos) and 
	 * direction travelled is a number from 0 to 3 (0-north, 1-east, 2-south,3-west). cList is purely a set of 
	 * hints supplied to the joinCorridor() function, although it could be used to generate a list of 
	 * only corridors for use in monster/item/etc placement. Alternatively its ref no could be used to 
	 * exclude it from roomList to generate a list of rooms only. As with roomList, do not edit after its creation. 
	 */
	public var cList:Array<Array<Int>>;
	
	/**
	 * This is the main array that stores the map data, being values from 0 to 5 
	 * (0-walkable floor, 1-blank/undiscovered, 2-wall, 3-open door, 4-closed door, 5-secret door) 
	 */
	public var mapArr(default, null):Array<Dynamic>;
	
	/**
	 * Width of the map area.
	 */
	public var mapWidth(default, null):Int;
	
	/**
	 * Height of the map area.
	 */
	public var mapHeight(default, null):Int;
	
	
	public function new() 
	{
		roomList = new Array<Array<Int>>();
		cList = new Array<Array<Int>>();
	}
	
	/**
	 * Generate random layout of rooms, corridors and other features.
	 * @param   mapWidth    Width of the map area.
	 * @param   mapHeight   Height of the map area.
	 * @param	fail        A value from 1 upwards. The higer the value of fail, the greater the chance of larger dungeons being created. A low value (>10) tends to produce only a few rooms, a high value (<50) raises the chance that the whole map area will be used to create rooms (up to the value of mrooms).
	 * @param	b1          corridor bias. This is a value from 0 to 100 and represents the %chance a feature will be a corridor instead of a room. A value of 0 will produce rooms only, a value of 100 will produce corridors only.
	 * @param	mrooms	    Maximum number of rooms to create. This, combined with fail, can be used to create a specific number of rooms.
	 */
	public function generate(mapWidth:Int=80, mapHeight:Int=80, fail:Int=100, b1:Int=5, mrooms:Int=60):Void
	{
		this.mapWidth = mapWidth;
		this.mapHeight = mapHeight;
		
		// fills the 2D array with ones
		#if haxe3
		mapArr = [for (y in 0...mapHeight) [for (x in 0...mapWidth) 1]];
		#else
		mapArr = Utils.fillArray([mapHeight, mapWidth], 1);
		#end
		
		var startingRoom:RoomData = makeRoom();
		var roomWidth:Int = startingRoom.width,
		    roomHeight:Int = startingRoom.height,
		    roomType:Int = startingRoom.type;
		
		while (roomList.length == 0)
		{
			var y:Int = Utils.randrange(0, mapHeight - 1 - roomHeight) + 1;
			var x:Int = Utils.randrange(0, mapWidth - 1 - roomWidth) + 1;
			// TODO: fix. if the first room is placed in the top left corner, it's pretty much assured the dungeon will fully cover the map and the infinite loop in makeExit won't happen
			placeRoom(roomHeight, roomWidth, x, y, 6, 0); 
		}
		
		var failed:Int = 0;
		while (failed < fail) // The lower the fail value, the smaller the dungeon
		{
			var chooseRoom = Utils.randrange(0, roomList.length);
			
			// make room exit
			var exit:ExitData = makeExit(chooseRoom);
			var exitX:Int = exit.wallX,
			    exitY:Int = exit.wallY,
			    exitX2:Int = exit.outsideX,
			    exitY2:Int = exit.outsideY,
			    exitToward:Int = exit.heading;
			
			var feature = Utils.randrange(0, 100);
			if (feature < b1) { // Begin feature choosing (more features to be added here)
				var corridor:RoomData = makeCorridor();
				roomWidth = corridor.width;
				roomHeight = corridor.height;
				roomType = corridor.type;
			} else {
				var room:RoomData = makeRoom();
				roomWidth = room.width;
				roomHeight = room.height;
				roomType = room.type;
			}
			
			var roomDone = placeRoom(roomHeight, roomWidth, exitX2, exitY2, roomType, exitToward);
			
			//If placement failed increase possibility map is full
			if (roomDone == 0) {
				failed += 1;
			}
			// Possiblilty of linking rooms
			else if (roomDone == 2) {
				if (mapArr[exitY2][exitX2] == 0) {
					if (Utils.randrange(0, 100) < 7) { // tweak this number up and don't place doors if you want big open areas connected with huge entrance and corridors
						makePortal(exitX, exitY);
					}
					failed += 1;
				}
			}
			// Otherwise, link up the 2 rooms
			else {
				makePortal(exitX, exitY);
				failed = 0;
				if (roomType < 5) { // 0 to 3 = corridor I think, 4 is not assigned, 5 is a room and 6 is the starting room
					var tc = [roomList.length - 1, exitX2, exitY2, roomType];
					cList.push(tc);
					joinCorridor(roomList.length - 1, exitX2, exitY2, roomType, 50);
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
		for (y in 0...mapHeight) {
		   var line = "";
		   for (x in 0...mapWidth) {
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
	 * Produce a room of random size.
	 * @return Return a RoomData object containing the width, the height and the type of the room.
	 */
	private function makeRoom():RoomData
	{
		return { width : Utils.randrange(0, 8) + 3, height : Utils.randrange(0, 8) + 3, type : 5 };
	}
	
	/**
	 * Randomly produce corridor length and heading
	 * @return Return an Anonymous Struct/Object
	 *          w       Width
	 *          l       Height
	 *          t       Heading (0 = North, 1 = East, 2 = South, 3 = West)
	 */
	private function makeCorridor():RoomData
	{
		var corridorLength = Utils.randrange(0, 18) + 3;
		var heading = Utils.randrange(0, 4);
		var corridorWidth = 0, corridorHeight = 0;
		// North
		if (heading == 0)
		{
			corridorWidth = 1;
			corridorHeight = -corridorLength;
		}
		// East
		else if (heading == 1)
		{
			corridorWidth = corridorLength;
			corridorHeight = 1;
		}
		// South
		else if (heading == 2)
		{
			corridorWidth = 1;
			corridorHeight = corridorLength;
		}
		// West
		else if (heading == 3)
		{
			corridorWidth = -corridorLength;
			corridorHeight = 1;
		}
		return { width : corridorWidth, height : corridorHeight, type : heading };
	}
	
	/**
	 * Place feature if enough space and return `canPlace` which is equal to 0, 1, or 2. 
	 * 0 = fails, 1 = can be placed, 2 = can be placed and is connecting to an other room.
	 * @param	ll          Height of the room
	 * @param	ww          Width of the room
	 * @param	xposs       X position of the room
	 * @param	yposs       Y position of the room
	 * @param	rty	        Type of room; can be a normal room or a corridor. 0 to 3 = corridor, 5 = normal room, 6 = starting room
	 * @param	ext         Exit Toward (0 = North, 1 = East, 2 = South, 3 = West)
	 * @return  Return whether a room was placed or not.
	 */
	private function placeRoom(ll:Int, ww:Int, xposs:Int, yposs:Int, rty:Int, ext:Int):Int
	{
		// Arrange for heading because corridors can have negative width and height
		// (e.g. {x: 25, y: 20, w: -10, h: 2} for an horizontal corridor heading from right to left)
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
		//if (ww + xpos + 1 > mapWidth - 1 || ll + ypos + 1 > mapHeight) { // -1 is in original code, but it's useless unless you want some margin
		if (ww + xpos + 1 > mapWidth || ll + ypos + 1 > mapHeight) {
			canPlace = 0;
			return canPlace;
		} else if (xpos < 1 || ypos < 1) {
			canPlace = 0;
			return canPlace;
		} else {
			for (j in 0...ll) {
				for (k in 0...ww) {
					if (mapArr[ypos + j][xpos + k] != 1) { // check if it's connecting to an other room (if it's not a void tile it has to be a wall or door of an other room)
						canPlace = 2;
						break;
					}
				}
				if (canPlace == 2) break;
			}
		}
		
		// If there is space, add to list of rooms
		if (canPlace == 1) {
			var temp = [ll, ww, xpos, ypos];
			roomList.push(temp);
			for (j in 0...ll + 2) { // then build walls
				for (k in 0...ww + 2) {
					mapArr[ypos - 1 + j][xpos - 1 + k] = 2;
				}
			}
			for (j in 0...ll) { // then build floors
				for (k in 0...ww) {
					mapArr[ypos + j][xpos + k] = 0;
				}
			}
		}
		
		// Return whether placed is true/false
		// 0 = out of boundaries of the map,
		// 1 = there is space to place the room,
		// 2 = there is place and it's connecting to an other existing room
		return canPlace; 
	}
	
	/**
	 * Make an exit to a room by picking a random wall and a random point along that wall.
	 * TODO: fix the while(true) -> it crash in this infinite loop... (rarely happens tho)
	 * @return	Return an Anonymous Struct/Object
	 *          rx      X position on the room wall
	 *          ry      Y position on the room wall
	 *          rx2     X position 1 unit outside of the room wall (used to eventually help placing a room next to this one)
	 *          ry2     Y position 1 unit outside of the room wall (used to eventually help placing a room next to this one)
	 *          rw      Heading (0 = North wall, 1 = East wall, 2 = South wall, 3 = West wall)
	 */
	private function makeExit(rn:Int):ExitData
	{
		var room = roomList[rn];
		var rx:Int = 0, ry:Int = 0, rx2:Int = 0, ry2:Int = 0;
		var rw:Int = 0;
		while (true) {
			rw = Utils.randrange(0, 4);
			if (rw == 0) { // North wall
				rx = Utils.randrange(0, room[1]) + room[2];	// random x position on the north wall
				ry = room[3] - 1;							// y position - 1 -> on the wall
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
			if (mapArr[ry][rx] == 2) { // if space is a wall, exit the loop
				break;
			}
		}
		return { wallX : rx, wallY : ry, outsideX : rx2, outsideY : ry2, heading : rw }
	}
	
	/**
	 * Create doors in walls. Choose a random type of portal and palce it.
	 * @param	px      Portal's X position.
	 * @param	py      Portal's Y position.
	 */
	private function makePortal(px:Int, py:Int):Void
	{
		var portalType:Int = Utils.randrange(0, 100);
		
		// secret door
		if (portalType > 90) {
			mapArr[py][px] = 5;
		}
		// closed door
		else if (portalType > 75) {
			mapArr[py][px] = 4;
		}
		// open door
		else if (portalType > 40) {
			mapArr[py][px] = 3;
		}
		// hole in the wall
		else {
			mapArr[py][px] = 0;
		}
	}
	
	/**
	 * Check corridor endpoint and make an exit if it links to another room.
	 * @param	cno     Room number = actually it's the corridor's number itself (probably last room created in roomList)
	 * @param	xp      X position 
	 * @param	yp      Y position
	 * @param	ed      Exit direction / heading (0 = North wall, 1 = East wall, 2 = South wall, 3 = West wall)
	 * @param	psb     Chance of linking rooms
	 */
	private function joinCorridor(cno:Int, xp:Int, yp:Int, ed:Int, psb:Int):Void
	{
		var cArea = roomList[cno]; // the current room (which actually is a corridor)
		var endx = 0, endy = 0;
		
		// Find the corridor endpoint
		if (xp != cArea[2] || yp != cArea[3]) { // if xp or yp are on the BOTTOM side or RIGHT side
			// get the bottom right corner :
			endx = xp - (cArea[1] - 1);
			endy = yp - (cArea[0] - 1);
		} else { // else xp and yp are on the TOP side or LEFT side
			// get the top left corner :
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
			if (endx < mapWidth - 2) {
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
			if (endx < mapWidth - 2) {
				var coords = [endx + 2, endy, endx + 1, endy];
				checkExit.push(coords);
			}
			if (endy < mapHeight - 2) {
				var coords = [endx, endy + 2, endx, endy + 1];
				checkExit.push(coords);
			}
		}
		// South corridor
		else if (ed == 2) {
			if (endx < mapWidth - 2) {
				var coords = [endx + 2, endy, endx + 1, endy];
				checkExit.push(coords);
			}
			if (endy < mapHeight - 2) {
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
			if (endy < mapHeight - 2) {
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


/*****************************************
 * Not used yet :
 *****************************************/

// 0 to 3 = corridor I think, 4 is not assigned, 5 is a room and 6 is the starting room

enum CorridorHeading {
	NORTH;
	EAST;
	SOUTH;
	WEST;
}

enum RoomType {
	CORRIDOR_NORTH;
	CORRIDOR_EAST;
	CORRIDOR_SOUTH;
	CORRIDOR_WEST;
	DO_NOT_USE;		// temp, do not use it. ever. it's useless, only here to fill up the enum's 5th place
	ROOM;
	START_ROOM;
}

private typedef RoomData = {
	var width:Int;
	var height:Int;
	var type:Int; // RoomType
};

private typedef CorridorData = {
	var width:Int;
	var height:Int;
	var heading:Int; // CorridorHeading
};

private typedef ExitData = {
	var wallX:Int;
	var wallY:Int;
	var outsideX:Int;
	var outsideY:Int;
	var heading:Int; // CorridorHeading
};
