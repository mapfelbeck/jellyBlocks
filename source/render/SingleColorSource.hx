package render;

import flixel.util.FlxColor;

/**
* ...
* @author Michael Apfelbeck
*/
class SingleColorSource implements IColorSource
{
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