package;

import jellyPhysics.Body;
import jellyPhysics.PointMass;
import jellyPhysics.test.*;
import lime.math.Vector2;
import haxe.unit.TestRunner;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * ...
 * @author Michael Apfelbeck
 */
class Main extends Sprite 
{
	public function new() 
	{
		super();
		
        var bitmapData:BitmapData = Assets.getBitmapData("assets/meh.png");
        var bitmap:Bitmap = new Bitmap(bitmapData);
        
        //stage.addChild(bitmap);
        
        var mass = new jellyPhysics.PointMass(17.7);

        trace("mass: " + mass.Mass);
        trace("position :" + mass.Position.x + ", " + mass.Position.y);
        
        var runner:TestRunner = new TestRunner();
        runner.add(new TestMaterialMatrix());
        runner.add(new TestVectorTools());
        runner.add(new TestAABB());
        runner.add(new TestClosedShape());
        runner.add(new TestBody());
        runner.add(new TestArrayCollider());
        runner.add(new TestWorld());
        runner.run();
	}

}
