package render;

import flixel.util.FlxColor;

/**
 * @author Michael Apfelbeck
 */
interface IColorSource 
{	/**
	 * The saturation of the color (from 0 to 1)
	 */
	public var Saturation(get, set):Float;
	function get_Saturation():Float;
	function set_Saturation(val:Float):Float;
	/**
	 * The value of the color (from 0 to 1)
	 */
	public var Value(get, set):Float;
	function get_Value():Float;	
	function set_Value(val:Float):Float;
	/**
	 * Offset for generating colors (from 0 to 1)
	 */
	public var ColorAdjust(get, set):Float;	
	function get_ColorAdjust():Float;
	function set_ColorAdjust(val:Float):Float;
    
    function getColor(index:Int):FlxColor;
}