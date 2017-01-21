package render;

import flixel.util.FlxColor;

/**
 * ...
 * @author Michael Apfelbeck
 */
class MultiColorSource implements IColorSource
{
    private var colors:Array<FlxColor>;
    public function new() 
    {
        colors = [FlxColor.RED, FlxColor.GREEN, FlxColor.BLUE, FlxColor.YELLOW, FlxColor.PURPLE, FlxColor.ORANGE];
    }
    
    public function getColor(index:Int):FlxColor 
    {
        return colors[index % colors.length];
    }
}