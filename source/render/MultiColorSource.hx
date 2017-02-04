package render;

import flixel.util.FlxColor;

/**
 * ...
 * @author Michael Apfelbeck
 */
class MultiColorSource implements IColorSource
{	/**
	 * The saturation of the color (from 0 to 1)
	 */
	public var Saturation(get, set):Float;
	function get_Saturation():Float {return saturation;}	
	function set_Saturation(val:Float):Float 
	{
		this.saturation = val;
		colors = makeColors();
		return this.saturation;
	}	
	/**
	 * The value of the color (from 0 to 1)
	 */
	public var Value(get, set):Float;
	function get_Value():Float{return value;}	
	function set_Value(val:Float):Float 
	{
		this.value = val;
		colors = makeColors();
		return this.value;
	}
	/**
	 * Offset for generating colors (from 0 to 1)
	 */
	public var ColorAdjust(get, set):Float;	
	function get_ColorAdjust():Float {return this.colorAdjust;}
	function set_ColorAdjust(val:Float):Float 
	{
		this.colorAdjust = val;
		colors = makeColors();
		return this.colorAdjust;
	}
	
	private var saturation:Float = 0.8;
	private var value:Float = 0.9;
	private var colorAdjust:Float = 0.1;
	
	private var count:Int;
    private var colors:Array<FlxColor>;
    public function new(colorCount:Int) 
    {
		count = colorCount;
		colors = makeColors();
    }
    
    public function getColor(index:Int):FlxColor 
    {
        return colors[index % colors.length];
    }
	
    private function makeColors():Array<FlxColor>
    {
        var iter:Float = 1.0 / count;
        var newColors:Array<FlxColor> = new Array<FlxColor>();
        for (i in 0...count){
            newColors.push(new FlxColor(HSVtoRGB(((i * iter) + colorAdjust) % 1.0, saturation, value)));
        }
        return newColors;
    }
    
    private function HSVtoRGB(h:Float, s:Float, v:Float):Int{
        var r:Float = 0;
        var g:Float = 0;
        var b:Float = 0;
        
        var i:Int = Math.floor(h * 6);
        var f:Float = h * 6 - i;
        var p:Float = v * (1 - s);
        var q:Float = v * (1 - f * s);
        var t:Float = v * (1 - (1 - f) * s);
        
        switch(i % 6){
            case 0:
                r = v;
                g = t;
                b = p;
            case 1:
                r = q;
                g = v;
                b = p;
            case 2:
                r = p;
                g = v;
                b = t;
            case 3:
                r = p;
                g = q;
                b = v;
            case 4:
                r = t;
                g = p;
                b = v;
            case 5:
                r = v;
                g = p;
                b = q;
        }
        
        var rInt:Int = Std.int(r * 255.0);
        var gInt:Int = Std.int(g * 255.0);
        var bInt:Int = Std.int(b * 255.0);
        
        return (rInt << 16) + (gInt << 8) + (bInt);
    }
}