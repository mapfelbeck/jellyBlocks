package;

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

    public function new(){
        
    }
    
    public function setupDrawParam(){
        
    }
    
    public function rotateColorUp() 
    {
        colorAdjust = (colorAdjust + 0.05) % 1.0;
        setupDrawParam();
    }
    
    public function rotateColorDown() 
    {
        colorAdjust = (colorAdjust + 0.95) % 1.0;
        setupDrawParam();
    }
    
    private function makeColors(saturation:Float, value:Float, count:Int):Array<Int>
    {
        var iter:Float = 1.0 / count;
        var colors:Array<Int> = new Array<Int>();
        for (i in 0...count){
            colors.push(HSVtoRGB(((i * iter) + colorAdjust) % 1.0, saturation, value));
        }
        return colors;
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