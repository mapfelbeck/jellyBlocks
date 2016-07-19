package;

import jellyPhysics.test.*;
import openfl.display.Sprite;
import openfl.events.*;

/**
 * ...
 * @author Michael Apfelbeck
 */
class Main extends Sprite 
{
	public function new() 
	{
		super();
        
        this.stage.quality = "HIGH";
		
        var testWorld:Sprite = new TestWorld5();
        stage.addChild(testWorld);
	}

}
