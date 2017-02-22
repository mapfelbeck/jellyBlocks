package render;

import jellyPhysics.math.Vector2;
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
    public var offset:Vector2 = new Vector2(0, 0);
    public var scale:Vector2 = new Vector2(10.0, 10.0);
    
    private var colorSource:IColorSource;
    
    public function new(colorSource:IColorSource){
        this.colorSource = colorSource;
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
        local.x = (world.x * scale.x) + offset.x;
        local.y = (world.y * scale.y) + offset.y;
        return local;
    }
}