package particles;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import util.Capabilities;

/**
 * ...
 * @author Michael Apfelbeck
 */
class PopEffect 
{
    public static var DEFAULT_PARTICLE_COUNT:Int = 15;
    public static var MOBILE_PARTICLE_COUNT:Int = 9;
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
            if (Capabilities.IsMobileBrowser()){
                this.count = MOBILE_PARTICLE_COUNT;
            }else{
                this.count = DEFAULT_PARTICLE_COUNT;
            }
        }
        
    }
    
}