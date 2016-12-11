package builders;
import enums.ShapeType;
import jellyPhysics.ClosedShape;
import jellyPhysics.math.Vector2;
/**
 * ...
 * @author 
 */
class ShapeBuilder
{
    private var shapeType:ShapeType = ShapeType.Square;
    private var shapeWidth:Float = 1.0;
    private var shapeHeight:Float = 1.0;
    private var shapeFacetCount:Int = 8;
    private var shapeVertexes:Array<Vector2>;
    
    public function new(){}
    
    public function type(shapeType:ShapeType):ShapeBuilder{
        this.shapeType = shapeType;
        return this;
    }
    
    public function size(size:Float):ShapeBuilder{
        this.shapeWidth = size;
        return this;
    }
    
    public function width(width:Float):ShapeBuilder{
        this.shapeWidth = width;
        return this;
    }
    
    public function height(height:Float):ShapeBuilder{
        this.shapeHeight = height;
        return this;
    }
    
    public function facetCount(facetCount:Int):ShapeBuilder{
        this.shapeFacetCount = facetCount;
        return this;
    }
    
    public function vertexes(vertexes:Array<Vector2>):ShapeBuilder{
        this.shapeVertexes = vertexes;
        return this;
    }
    
    public function create():ClosedShape{
        switch(shapeType){
            case ShapeType.Square:
                this.shapeVertexes = getRectangleVertexes(shapeWidth, shapeWidth);
            case ShapeType.Rectangle:
                this.shapeVertexes = getRectangleVertexes(shapeWidth, shapeHeight);
            case ShapeType.Polygon:
                this.shapeVertexes = getPolygonVertexes();
            case ShapeType.Custom:
                if (shapeVertexes == null || shapeVertexes.length < 3){
                    throw "ShapeBuilder error: vertexes list for custom shape is null or length < 3.";
                }
        }
        
        return createInternal(this.shapeVertexes);
    }
    
    function getPolygonVertexes() :Array<Vector2>
    {
        var verts:Array<Vector2> = new Array<Vector2>();
        for (i in 0...shapeFacetCount){
            var point:Vector2 = new Vector2();
            point.x =  Math.cos(2 * (Math.PI / shapeFacetCount) * i) * shapeWidth;
            point.y = Math.sin(2 * (Math.PI / shapeFacetCount) * i) * shapeWidth;
            verts.push(point);
        }
        return verts;
    }
    
    private function createInternal(verts:Array<Vector2>):ClosedShape{
        var polygonShape:ClosedShape = new ClosedShape();
        polygonShape.Begin();
        for (i in 0...verts.length){
            polygonShape.AddVertex(verts[i]);
        }
        
        polygonShape.Finish(true);
        return polygonShape;
    }
    
    private function getRectangleVertexes(width:Float, height:Float):Array<Vector2>{
        var verts:Array<Vector2> = new Array<Vector2>();
        verts.push(new Vector2(0, 0));
        verts.push(new Vector2(width, 0));
        verts.push(new Vector2(width, height));
        verts.push(new Vector2(0, height));
        return verts;
    }
}