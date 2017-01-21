package render;

import flixel.util.FlxColor;

/**
 * @author Michael Apfelbeck
 */
interface IColorSource 
{
    function getColor(index:Int):FlxColor;
}