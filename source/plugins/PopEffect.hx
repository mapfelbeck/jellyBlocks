package plugins;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

/**
 * ...
 * @author Michael Apfelbeck
 */
class PopEffect 
{
    public static var DEFAULT_PARTICLE_COUNT:Int = 10;
    public var position:FlxPoint;
    public var color:FlxColor;
    public var count:Int;
    public function new(position:FlxPoint, color:FlxColor, ?count:Int) 
    {
        this.position = position;
        this.color = color;
        if (count != null){
            this.count = count;
        }else{
            this.count = DEFAULT_PARTICLE_COUNT;
        }
        
    }
    
}