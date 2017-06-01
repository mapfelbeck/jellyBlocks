package render;

import jellyPhysics.math.Vector2;
import util.ScreenWorldTransform;
/**
 * ...
 * @author 
 */
class BaseDrawWorld
{
    public static var colorAdjust:Float = 0.1;
    
    public static var COLOR_BLACK:Int = 0x000000;
    public static var COLOR_WHITE:Int = 0xFFFFFF;
    public static var COLOR_GREY:Int = 0x7F7F7F;
    public static var COLOR_RED:Int = 0xFF0000;
    public static var COLOR_GREEN:Int = 0x00FF00;
    public static var COLOR_BLUE:Int = 0x0000FF;
    public static var COLOR_PURPLE:Int = 0xFF00FF;
    public static var COLOR_YELLOW:Int = 0xFFFF00;
    public static var COLOR_AQUA:Int = 0x00FFFF;
    
    private var ground:GameGround;
    
    private var colorSource:IColorSource;
    
    public var transform:ScreenWorldTransform;
    
    public function new(colorSource:IColorSource, screenWorldTransform:ScreenWorldTransform){
        this.colorSource = colorSource;
        transform = screenWorldTransform;
        setupDrawParam();
    }
    
    public function Draw(){}
    
    public function setupDrawParam(){
        
    }
    
    public function setGameGround(ground:GameGround){
        this.ground = ground;
    }
    
    private function worldToLocal(world:Vector2):Vector2{
        var local:Vector2 = new Vector2();
        local.x = (world.x * transform.scale.x) + transform.offset.x;
        local.y = (world.y * transform.scale.y) + transform.offset.y;
        return local;
    }
}