package render;

import openfl.display.Sprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import util.UtilClass;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import haxe.ds.Vector;
import openfl.Assets;
import openfl.geom.Point;
/**
 * ...
 * @author Michael Apfelbeck
 */
class NineSliceSprite extends FlxSprite
{
    private var spritePath:String;
    private var textureSlices:Array<Float>;
    private var textureXSum:Float;
    private var textureYSum:Float;
    private var spriteSlices:Array<Float>;
    private var spriteXSum:Float;
    private var spriteYSum:Float;
    private var spriteHeight:Int = 0;
    private var spriteWidth:Int = 0;
    private var colorSource:IColorSource;
    public function new(?X:Float = 0, ?Y:Float = 0, GraphicPath:String, ?textureSlices:Array<Float>, ?spriteSlices:Array<Float>, ?colorSource:IColorSource) 
    {
        super(X, Y, null);
        if (textureSlices == null){
            //[x1,x2,x3,y1,y2,y3]
            this.textureSlices = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
        }else{
            this.textureSlices = textureSlices;
        }
        textureXSum = this.textureSlices[0] + this.textureSlices[1] + this.textureSlices[2];
        textureYSum = this.textureSlices[3] + this.textureSlices[4] + this.textureSlices[5];
        
        if (spriteSlices == null){
            this.spriteSlices = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0];
        }else{
            this.spriteSlices = spriteSlices;
        }
        spriteXSum = this.spriteSlices[0] + this.spriteSlices[1] + this.spriteSlices[2];
        spriteYSum = this.spriteSlices[3] + this.spriteSlices[4] + this.spriteSlices[5];
        
        if (colorSource == null){
            this.colorSource = new SingleColorSource(FlxColor.WHITE);
        }else{
            this.colorSource = colorSource;
        }
        
        this.pixels = drawSprite(GraphicPath);
    }

    private function spriteXCoord(index:Int):Int{
        switch(index){
            case 0:
                return 0;
            case 1:
                return Std.int((spriteSlices[0] / spriteXSum) * spriteWidth);
            case 2:
                return Std.int(((spriteSlices[0] + spriteSlices[1]) / spriteXSum) * spriteWidth);
            case 3:
                return spriteWidth;
        }
        return spriteWidth;
    }
    private function spriteYCoord(index:Int):Int{
        switch(index){
            case 0:
                return 0;
            case 1:
                return Std.int((spriteSlices[3] / spriteYSum) * spriteHeight);
            case 2:
                return Std.int(((spriteSlices[3] + spriteSlices[4]) / spriteYSum) * spriteHeight);
            case 3:
                return spriteWidth;
        }
        return spriteWidth;
    }

    private function textureXCoord(index:Int):Float{
        switch(index){
            case 0:
                return 0;
            case 1:
                return textureSlices[0] / textureXSum;
            case 2:
                return (textureSlices[0] + textureSlices[1]) / textureXSum;
            case 3:
                return 1;
        }
        return 1;
    }
    private function textureYCoord(index:Int):Float{
        switch(index){
            case 0:
                return 0;
            case 1:
                return textureSlices[3] / textureYSum;
            case 2:
                return (textureSlices[3] + textureSlices[4]) / textureYSum;
            case 3:
                return 1;
        }
        return 1;
    }
    
    private function drawSprite(GraphicPath:String):BitmapData{
        var flashSprite:Sprite = new Sprite();
        var vertices:Array<Float> = UtilClass.arrayOfSize(32);
        var indices:Array<Int> = UtilClass.arrayOfSize(54);
        var uvtData:Array<Float> = UtilClass.arrayOfSize(32);
        var data:BitmapData = Assets.getBitmapData(GraphicPath);
        var pixelWidth:Int = Std.int(data.width / 3);
        var pixelHeight:Int = Std.int(data.height / 3);
        spriteHeight = data.height;
        spriteWidth = data.width;
        
        //vertexes are [x1,y1...]
        for (y in 0...4){
            for (x in 0...4){
                var xIndex:Int = 2 * (x + y*4);
                var yIndex:Int = xIndex + 1;
                vertices[xIndex] = spriteXCoord(x);
                vertices[yIndex] = spriteYCoord(y);
                uvtData[xIndex] = textureXCoord(x);
                uvtData[yIndex] = textureYCoord(y);
            }
        }
        
        for (y in 0...3){
            for (x in 0...3){
                var squareIndex:Int = x + y * 3;
                var xIndex:Int = 6*squareIndex;
                var vertexIndex:Int = x + 4 * y;
                var color = FlxColorToColorTransform(colorSource.getColor(squareIndex));

                data.colorTransform(getspriteRectangle(x, y), color);
                indices[xIndex + 0] = vertexIndex + 0;
                indices[xIndex + 1] = vertexIndex + 1;
                indices[xIndex + 2] = vertexIndex + 4;
                
                indices[xIndex + 3] = vertexIndex + 1;
                indices[xIndex + 4] = vertexIndex + 5;
                indices[xIndex + 5] = vertexIndex + 4;
            }
        }
        flashSprite.graphics.beginBitmapFill(data);
        flashSprite.graphics.drawTriangles(vertices, indices, uvtData);
        flashSprite.graphics.endFill();
        
        var newPixels:BitmapData = new BitmapData(Std.int( data.width), Std.int(data.height));
        newPixels.fillRect(newPixels.rect, FlxColor.TRANSPARENT);
        newPixels.draw(flashSprite);
        
        return newPixels;
    }
    
    function getspriteRectangle(x:Int, y:Int) :Rectangle
    {
        var xPos:Float = 0;
        var yPos:Float = 0;
        var width:Float = 0;
        var height:Float = 0;
        switch(x){
            case 0:
                xPos = 0;
                width = (textureSlices[0] / textureXSum) * spriteWidth;
            case 1:
                xPos = (textureSlices[0] / textureXSum) * spriteWidth;
                width = (textureSlices[1] / textureXSum) * spriteWidth;
            case 2:
                xPos = ((textureSlices[0] + textureSlices[1]) / textureXSum) * spriteWidth;
                width = (textureSlices[2] / textureXSum) * spriteWidth;
        }
        switch(y){
            case 0:
                yPos = 0;
                height = (textureSlices[3] / textureYSum) * spriteHeight;
            case 1:
                yPos = (textureSlices[3] / textureYSum) * spriteHeight;
                height = (textureSlices[4] / textureYSum) * spriteHeight;
            case 2:
                yPos = ((textureSlices[3] + textureSlices[4]) / textureYSum) * spriteHeight;
                height = (textureSlices[5] / textureYSum) * spriteHeight;
        }
        return new Rectangle(xPos, yPos, width, height);
    }
    
    private function FlxColorToColorTransform(color:FlxColor):ColorTransform{
        return new ColorTransform(color.redFloat, color.greenFloat, color.blueFloat, color.alphaFloat, 0, 0, 0, 0);
    }
}