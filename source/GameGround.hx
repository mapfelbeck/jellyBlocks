package;
import builders.GameBlockBuilder;
import builders.ShapeBuilder;
import enums.ShapeType;
import enums.BlockType;
import jellyPhysics.Body;
import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;
import jellyPhysics.math.VectorTools;

/**
 * ...
 * @author 
 */
class GameGround
{
    private var width:Float;
    private var height:Float;
    private var border:Float;
    private var position:Vector2;
    private var builder:GameBlockBuilder;
    
    private var bodies:Array<Body>;
    public function new(border:Float, width:Float, height:Float, 
                        position:Vector2, builder:GameBlockBuilder) 
    {
        this.width = width;
        this.height = height;
        this.border = border;
        this.position = position;
        this.builder = builder;
        bodies = new Array<Body>();
    }
    
    public function Assemble():Array<Body>{
        /*var groundBody:Body = new Body(getSquareShape(2), Math.POSITIVE_INFINITY, new Vector2(0, 9), 0, new Vector2(18, 1), false);
        groundBody.IsStatic = true;
        groundBody.Material = MATERIAL_GROUND;
        physicsWorld.AddBody(groundBody);*/
        //public StaticBodyConfig(float theWidth, float theHeight, Vector2 theLocation
        
        //lower left
        bodies.push(makeBody(border, border, new Vector2( -(border + width) / 2, (border + height) / 2)));        
        //lower middle
        bodies.push(makeBody(width, border, new Vector2(0, (border + height) / 2)));
        //lower right
        bodies.push(makeBody(border, border, new Vector2((border + width) / 2, (border + height) / 2)));
        
        //middle left
        bodies.push(makeBody(border, height, new Vector2(-(border + width) / 2, 0)));
        //middle
        //bodies.push(makeBody(width, height, new Vector2(0 ,0 )));
        //middle right
        bodies.push(makeBody(border, height, new Vector2((border + width) / 2, 0)));

        //upper left
        bodies.push(makeBody(border, border, new Vector2(-(border + width) / 2, -(border + height) / 2)));
        //upper middle
        //bodies.push(makeBody(width, border, new Vector2(0, -(border + height) / 2)));
        //upper right
        bodies.push(makeBody(border, border, new Vector2((border + width) / 2, -(border + height) / 2)));

        
        return bodies;
    }
    
    function makeBody(width:Float, height:Float, relPosition:Vector2):Body
    {
        var shapeBuilder: ShapeBuilder = builder.getShapeBuilder().type(ShapeType.Rectangle).width(width).height(height);
        builder = builder.setPosition(relPosition).setType(BlockType.Normal);
        
        /*var shapeBuilder:ShapeBuilder = builder.get new ShapeBuilder().type(ShapeType.Rectangle).width(width).height(height);
        var bodyPosition:Vector2 = VectorTools.Add(relPosition, position);
        var shape:ClosedShape = shapeBuilder.create();
        var body:Body = new Body(shape, Math.POSITIVE_INFINITY, bodyPosition, 0.0, new Vector2(1, 1), true);*/
        return builder.create();
    }    
}