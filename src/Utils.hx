package ;
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
	
	public static inline function scaleFromCenter(dis:Dynamic, sX:Float, sY:Float):Void
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