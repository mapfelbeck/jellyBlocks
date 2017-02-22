package render;

import flixel.util.FlxColor;

/**
* ...
* @author Michael Apfelbeck
*/
class SingleColorSource implements IColorSource
{
    
	/**
	 * The saturation of the color (from 0 to 1)
	 */
	public var Saturation(get, set):Float;
	public function get_Saturation():Float {return 0;}	
	public function set_Saturation(val:Float):Float 
	{
		return 0;
	}	
	/**
	 * The value of the color (from 0 to 1)
	 */
	public var Value(get, set):Float;
	public function get_Value():Float{return 0;}	
	public function set_Value(val:Float):Float 
	{
		return 0;
	}
	/**
	 * Offset for generating colors (from 0 to 1)
	 */
	public var ColorAdjust(get, set):Float;	
	public function get_ColorAdjust():Float {return 0;}
	public function set_ColorAdjust(val:Float):Float 
	{
		return 0;
	}
    
    private var color:FlxColor;
    public function new(color:FlxColor) 
    {
        this.color = color;
    }

    public function getColor(index:Int):FlxColor 
    {
        return color;
    }
}