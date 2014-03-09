package ;
import flash.Lib;
import flash.net.URLRequest;

/**
 * ...
 * @author Julien Samama
 */

class Utils
{
	public static function openURL(url:String):Void
	{
		Lib.getURL(new URLRequest(url));
	}
	
	/**
	 * Returns a random Int between min <= Int < max.
	 * @param	min
	 * @param	max
	 * @return	The random Int.
	 */
	public static function randrange(min:Int, max:Int):Int
	{
		return (Math.floor(Math.random() * (max - min)) + min);
	}
	
	/**
	 * Range. 
	 * @param	values	Can be either [rangeEnd], [rangeStart, rangeEnd] or [rangeStart, rangeEnd, steps]
	 * 					If range(10) is called, it returns [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	 * 					If range(5, 10) is called, it returns [5, 6, 7, 8, 9]
	 * 					If range(0, 10, 2) is called, it returns [0, 2, 4, 6, 8]
	 * @return	Range array
	 */
	public static function range(values:Array<Dynamic>):Array<Dynamic>
	{
		var data:Array<Dynamic> = new Array<Dynamic>();
		var step:Int = 1;
		var start = 0;
		var end = values[0];
		
		if (values.length > 2) {
			step = values[2];
		}
		if (values.length > 1) {
			start = values[0];
			end = values[1];
		}
		if (start > end)
		{
			var i = start;
			while (i > end) {
				data.push(i);
				i -= step;
			}
		}
		else
		{
			var i = start;
			while (i < end) {
				data.push(i);
				i += step;
			}
		}
		return data;
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
	
	public static function scaleFromCenter(dis:Dynamic, sX:Float, sY:Float):Void
	{
		var prevW:Float = dis.width;
		var prevH:Float = dis.height;
		dis.scaleX = sX;
		dis.scaleY = sY;
		dis.x += (prevW - dis.width) / 2;
		dis.y += (prevH - dis.height) / 2;
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
}