package utils;

import flash.Lib;
import flash.net.URLRequest;

/**
 * ...
 * @author Julien Samama
 */

class Utils
{
	public static inline function openURL(url:String):Void
	{
		Lib.getURL(new URLRequest(url));
	}
	
	/**
	 * Returns a random Int between min <= Int <= max.
	 * @param	min
	 * @param	max
	 * @return	The random Int. Can include both endpoints.
	 */
	public static function randint(min:Int, max:Int):Int
	{
		return (Math.floor(Math.random() * (max - min + 1)) + min);
	}
	
	/**
	 * Returns a random Int between min <= Int < max.
	 * @param	min
	 * @param	max
	 * @return	The random Int.
	 */
	public static inline function randrange(min:Int, max:Int):Int
	{
		return (Math.floor(Math.random() * (max - min)) + min);
	}
	
	/**
	 * Random choice in an array.
	 */
	public static inline function choice<T>(array:Array<T>):T 
	{
		return array[Std.random(array.length)];
	}
	
	/**
	 * Get all values from a 2D array and return them in a 1 dimensional array.
	 */
	public static inline function values<T>(array:Array<Array<T>>):Array<T>
	{
		var newArray:Array<T> = new Array<T>();
		for (y in 0...array.length) {
			for (x in 0...array[y].length) {
				newArray.push(array[y][x]);
			}
		}
		return newArray;
	}
	
	/**
	 * Sort array.
	 * @param   array   Array to sort.
	 * @return  Return a sorted copy of the given array.
	 */
	public static inline function sorted(array:Array<Int>):Array<Int>
	{
		var newArray = array.copy();
		newArray.sort(function (a:Int, b:Int) {
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		});
		return newArray;
	}
	
	/**
	 * Fills an array given a shape and a content. Default content is 0.
	 * @param	shape	The shape.
	 * @param	with	The content. Can be an Int, a Float, a String...
	 * @return	The array filled with content given the shape.
	 */
	public static function fillArray(shape:Array<Int>, with:Dynamic=0):Array<Dynamic>
	{
		var newArray:Array<Dynamic> = new Array<Dynamic>();
		
		if (shape.length < 1) return null;
		
		if (shape.length < 2)
		{
			for (i in 0...shape[0]) {
				newArray.push(with);
			}
			return newArray;
		}
		else if (shape.length < 3) {
			for (i in 0...shape[0]) {
				var newArray2:Array<Dynamic> = new Array<Dynamic>();
				for (i in 0...shape[1]) {
					newArray2.push(with);
				}
				newArray.push(newArray2);
			}
			return newArray;
		}
		return null;
	}
	
	/**
	 * Scale a DisplayObject (like Sprite) from the center.
	 * @param	dis     DisplayObject to scale.
	 * @param	sX      New x scale.
	 * @param	sY      New y scale.
	 */
	public static inline function scaleFromCenter(displayObject:Dynamic, sX:Float, sY:Float):Void
	{
		var prevW:Float = displayObject.width;
		var prevH:Float = displayObject.height;
		displayObject.scaleX = sX;
		displayObject.scaleY = sY;
		displayObject.x += (prevW - displayObject.width) / 2;
		displayObject.y += (prevH - displayObject.height) / 2;
	}
	
	/**
	 * Clamps the value within the minimum and maximum values. Stolen from haxepunk :)
	 * @param	value		The Float to evaluate.
	 * @param	min			The minimum range.
	 * @param	max			The maximum range.
	 * @return	The clamped value.
	 */
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
		if (max > min)
		{
			if (value < min) return min;
			else if (value > max) return max;
			else return value;
		}
		else
		{
			// Min/max swapped
			if (value < max) return max;
			else if (value > min) return min;
			else return value;
		}
	}
	
	/**
	 * Conversion from a CSV string to a 2d array
	 */
	public static function csv2array(csv:String):Array<Array<Int>>
	{
		return [for (el in csv.split('\n')) el.split(',').map(function(e) return Std.parseInt(e))];
	}
	
	/**
	 * Conversion from a ASCII string to a 2d array
	 */
	public static function ascii2array(ascii:String):Array<Array<String>>
	{
		return [for (el in ascii.split('\n')) el.split('')];
	}
	
	/**
	 * Conversion from a 2d array to a CSV string
	 */
	public static function array2csv(array2d:Array<Array<Dynamic>>):String
	{
		var str = "";
		for (y in 0...array2d.length)
		{
			var colLength = array2d[y].length;
			for (x in 0...colLength)
			{
				str += array2d[y][x];
				if (x < colLength - 1) {
					 str += ",";
				}
			}
			if (y < array2d.length - 1) {
				str += '\n';
			}
		}
		return str;
	}
	
	/**
	 * Conversion from a 2d array to a ASCII string
	 */
	public static function array2ascii(array2d:Array<Array<Dynamic>>):String
	{
		var str = "";
		for (y in 0...array2d.length)
		{
			var colLength = array2d[y].length;
			for (x in 0...colLength) {
				str += array2d[y][x];
			}
			if (y < array2d.length - 1) {
				str += '\n';
			}
		}
		return str;
	}
}