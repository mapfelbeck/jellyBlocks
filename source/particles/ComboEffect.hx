package particles;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import util.Capabilities;

/**
 * ...
 * @author Michael Apfelbeck
 */
class ComboEffect 
{
    public static var DEFAULT_PARTICLE_COUNT:Int = 4;
    public static var MOBILE_PARTICLE_COUNT:Int = 2;
    public var position:FlxPoint;
    public var color:FlxColor;
    public var count:Int;
    public var text:String;
    
    public function new(position:FlxPoint, color:FlxColor, text:String, ?count:Int) 
    {
        this.position = position;
        this.color = color;
        this.text = text;
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