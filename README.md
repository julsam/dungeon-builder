# Dungeon Builder
It's an Haxe port of the Dungeon builder written in python by Steve Wallace. See more infos here : http://roguebasin.roguelikedevelopment.org/index.php?title=Dungeon_builder_written_in_Python  
It builds a dungeon procedurally generated with rooms, corridors, and doors. 

## Try the demo 
https://dl.dropboxusercontent.com/u/100579483/dungeon-builder/DungeonBuilder-2.swf
	

Read DungeonBuilder.hx for more informations. It doesn't require any particular library to run and can easily be incorporated in your project. It only require Utils.hx  

Note that this code could be improved in many ways, any commit is welcome.  

## Dependencies to compile
(flash only for now)
```
haxe >= 3.1
openfl >= 1.3
actuate >= 1.7
hscript >= 2.0
haxeui >= 1.3.0
```

## Usage

Generate a new dungeon and print it:
``` haxe
// building and printing
var dungeonBuild:DungeonBuilder = new DungeonBuilder();
dungeonBuild.generate(80,  // map width
                      80,  // map height
                      200, // fail, the higer the value of fail, the greater the chance of larger dungeons being created
                      5,   // corridors
                      60); // max rooms
dungeonBuild.print();
```	

## Examples

Get a specific tile:
``` haxe
dungeonBuild.mapArr[y][x];
```

Loop through all tile to feed your Tilemap:
``` haxe
for (y in 0...dungeonBuild.mapHeight)
{
	for (x in 0...dungeonBuild.mapWidth)
	{
		if (dungeonBuild.mapArr[y][x] == 0) // walkable area
		{
			// setTile(x, y, 0);
		}
		else if (dungeonBuild.mapArr[y][x] == 1) // out of the dungeon
		{
			// setTile(x, y, 0);
		}
		else if (dungeonBuild.mapArr[y][x] == 2) // wall
		{
			// setTile(x, y, 0);
		}
		else if (dungeonBuild.mapArr[y][x] == 3) // opened door
		{
			// setTile(x, y, 0);
		}
		else if (dungeonBuild.mapArr[y][x] == 4) // closed door
		{
			// setTile(x, y, 0);
		}
		else if (dungeonBuild.mapArr[y][x] == 5) // secret door
		{
			// setTile(x, y, 0);
		}
	}
}
```

Go through each room:
``` haxe
for (room in dungeonBuild.roomList)
{
	room[0];	// room height
	room[1];	// room width
	room[2];	// room x position
	room[3];	// room y position
}
```
	
Go through each corridor:
``` haxe
for (corridor in dungeonBuild.cList)
{
	corridor[0];	// reference number to roomList
	corridor[1];	// start x position
	corridor[2];	// start y position 
	corridor[3];	// heading (0 = North, 1 = East, 2 = South, 3 = West) 
}
```
	
## Tips
 * Check the `makePortal()` function if you want to change or add more types of doors (hole in the wall, opened door, closed door, secret door).  
 * If you want the starting room, from where the algorithm built everything, it's the first room in the `mapArr` array. The array is sorted from the first room created to the last one.  



## Output example
	
![output in the Visualizer](http://i.imgur.com/67HZSAA.png)

is the same map as this printed output :

```
                                                            
                                                            
                                                            
                                                            
                                                   ######   
                                                   #....#   
                                                   #....#   
                                                   #....#   
                 #########                         #....#   
         #########.......#                         #....#   
         #.......#.......#              ############....#   
         #.......#.......########       #..........=....#   
         #......................#  ######=##########....#   
         #.......=.......=......#  #......#        ######   
         #.......##...####......#  #......##############    
         #.......##.....##......#  #......#.......#....#    
         #.......##.....##===.######..............#....#    
         #.......##.....##.........#......=.......~....#    
         ####.##=##.....##.........=......#.......~....#    
            #....##.....##.........#......#.......######    
            #....##.....############......###..#######      
            #....##.....#          #......##.........#      
            #....##.....#          ####=####.........#      
            #....#################  #...#  #.........#      
            #....#     #.....~...#  #...#  #.........#      
            #....#     #.........#  #...#  #.........#####  
            #....#######.....#...#  #...#  #.............#  
            ####=##..........###=####...##############...#  
              #........#.....# #...##...=.........#  #...#  
              #...#....#####~###...##...#.........#  #...#  
              #...#....# #.....#...##...#.........#  #...#  
              #...####=###.....#...######.........#  #...#  
              #...##.....#.....#...#    #########~########  
              #...##.....~.....##############...#.......#   
              #...##.....#.....#####........#...#.......#   
              #...##.....#.....#...#........#...#.......#   
              #...##.....#.....=............#...#.......#   
        #######=##########.....#...#........#...#.......#   
        #..........#     #=#########........=...#.......#   
        #..........#     #....#    #####=########.......#   
        #..........#     #....#     #....=.#    #.......#   
        #..........#     #....#     #....#.# ######=##.#####
        #..........#     #....#######....#.# #......##.....#
        #..........#     #....#.....#....#.# #......########
        #..........#     #..........#....#.# #......#       
        #..........#     #....#.....#....#.# #......#       
        #..........#     #....#.....#....#.# #......#       
        #####.##.==##  ####..##..........#.#####.=#=###     
           #...#....#  #.....##.....#....#............#     
           #...#....#  #.....###.~########.#..........#     
           #...#....#  #.....# #...##### #.#..........#     
           #...##.######.....# #...#...# #.=..........#     
           #...#......##.....# #...#...###=#=#.######.##### 
           #...#......##.....# #...=...#.......#..........# 
           #..........##.....# #...#...#.......#..........# 
           #...#......##.....# #...#...#.......#..........# 
           #...#......##.....# #...#...#.......#..........# 
           #...#########.....# #...#...#.......#..........# 
           #####       ####### #...#####.......#..........# 
                               #####   #################### 
```