package;
import builders.GameBlockBuilder;
import builders.ShapeBuilder;
import enums.BlockType;
import enums.ShapeType;
import jellyPhysics.Body;
import jellyPhysics.math.Vector2;

/**
 * ...
 * @author 
 */
class GameGround
{
    //width of play space inside arena
    private var width:Float;
    public var Width(get, null):Float;
    public function get_Width(){ return width; }
    
    //height of play space inside arena
    private var height:Float;
    public var Height(get, null):Float;
    public function get_Height(){ return height; }
    
    //size of blocks around arena
    private var border:Float;
    public var Border(get, null):Float;
    public function get_Border(){ return border; }
    
    /*private var position:Vector2;
    public var Position(get, null):Vector2;
    public function get_Position(){ return position; }*/
    
    private var builder:GameBlockBuilder;
    
    private var makeCap:Bool;
    
    private var bodies:Array<Body>;
	public var BodyCount(get, null):Int;
	public function get_BodyCount():Int{ return bodies.length;}
    public function new(border:Float, width:Float, height:Float, builder:GameBlockBuilder, ?capArena:Bool = true) 
    {
        this.width = width;
        this.height = height;
        this.border = border;
        this.builder = builder;
        bodies = new Array<Body>();
        this.makeCap = capArena;
    }
    
    public function Assemble():Array<Body>{
        
        var count:Int = 0;
        var tempSize:Float = 0;
        
        //lower left
        bodies.push(makeBody(border, border, new Vector2( -(border + width) / 2, (border + height) / 2)));        
        
        //lower middle
        count = Std.int( width / border);
        tempSize = width / count;
        for (i in 0...count){
            bodies.push(makeBody(tempSize, border, new Vector2(i * (tempSize) - (width / 2) + (border/2), (border + height) / 2)));
        }
        
        //lower right
        bodies.push(makeBody(border, border, new Vector2((border + width) / 2, (border + height) / 2)));
        
        //middle left
        count = Std.int( height / border);
        tempSize = height / count;
        for (i in 0...count){
            bodies.push(makeBody(border, tempSize, new Vector2( -(border + width) / 2, (i*tempSize-(height/2))+(tempSize/2))));
        }
        
        //middle
        //bodies.push(makeBody(width, height, new Vector2(0 ,0 )));
        //middle right
        count = Std.int( height / border);
        tempSize = height / count;
        for (i in 0...count){
            bodies.push(makeBody(border, tempSize, new Vector2( (border + width) / 2, (i*tempSize-(height/2))+(tempSize/2))));
        }

        //upper left
        bodies.push(makeBody(border, border, new Vector2(-(border + width) / 2, -(border + height) / 2)));
        //upper middle
        //bodies.push(makeBody(width, border, new Vector2(0, -(border + height) / 2)));
        //upper right
        bodies.push(makeBody(border, border, new Vector2((border + width) / 2, -(border + height) / 2)));

        var capHeight:Int = 2;
        //arena cap
        if (makeCap){
            for(i in 1...capHeight+1){
                bodies.push(makeBody(border, border, new Vector2( -(border + width) / 2, ( -(border + height) / 2) - (border * i))));
                bodies.push(makeBody(border, border, new Vector2( (border + width) / 2, ( -(border + height) / 2) - (border * i))));
            }
            var capY:Float = ( -(border + height) / 2) - (border * capHeight);
            count = Std.int( width / border);
            for (i in 0...count){
                bodies.push(makeBody(tempSize, border, new Vector2(i * (tempSize) - (width / 2) + (border/2), capY)));
            }
        }
        
        return bodies;
    }
    
    function makeBody(width:Float, height:Float, relPosition:Vector2):Body
    {
        var shapeBuilder: ShapeBuilder = builder.getShapeBuilder().type(ShapeType.Rectangle).width(width).height(height);
        builder = builder.setPosition(relPosition).setType(BlockType.Normal).setMaterial(constants.GameConstants.MATERIAL_GROUND);
        
        return builder.create();
    }    
}