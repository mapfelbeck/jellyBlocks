package
{
    import flash.display.*;
    import flash.events.*;
    
    import JelloAS3.*;
    import flash.utils.setInterval;
    
    import flash.utils.getTimer;
    
    [Frame(factoryClass = "Preloader")]
    public class Main extends MovieClip
    {
        public var mWorld:World = new World();
        
        public var RenderCanvas:Sprite;
        
        //public var mSpringBodies:Vector.<DraggableSpringBody> = new Vector.<DraggableSpringBody>();
        //public var mPressureBodies:Vector.<DraggablePressureBody> = new Vector.<DraggablePressureBody>();
        //public var mStaticBodies:Vector.<Body> = new Vector.<Body>();
        
        public var tId:int = 2;
        
        public var worldBuilder:GameWorldBuilder;
        
        public var showDebug:Boolean = false;
        
        public var dragBody:Body;
        public var mouseDown:Boolean = false;
        public var dragPoint:int = 0;
        
        public var go:Boolean = true;
        
        private var frameRate:int = 60;
        private var physicsIter:int = 30;
        
        public function Main():void
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            
            var i:Input2 = new Input2(this);
            
            stage.quality = "HIGH";
            stage.color = 0.
            stage.frameRate = frameRate;
            
            addEventListener(Event.ENTER_FRAME, loop);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseClick);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseup);
            
            RenderCanvas = new Sprite();
            addChildAt(RenderCanvas, 0);
            
            //this.addChild(new FlashPreloadProfiler());
            //showDebug = true;
            
            worldBuilder = new GameWorldBuilder();
            mWorld = worldBuilder.Build(tId);
            
            addChild(new Stats());
        }
        
        /*function loadTest(t:int) : void
           {
        
           else if(tId == 3)
           {
           mWorld.removeBody(groundBody);
           mStaticBodies.splice(mStaticBodies.indexOf(groundBody), 1);
        
           def = 20;
        
           ball = new ClosedShape();
           ball.begin();
           for (i = 0; i < 360; i += def)
           {
           ball.addVertexPos(Math.cos((Math.PI / 180) * -i), Math.sin((Math.PI / 180) * -i));
           }
           ball.transformOwn(0, new Vector2(0.3, 0.3));
           ball.finish();
        
        
           //var pb:DraggablePressureBody;
           pb = new DraggablePressureBody(mWorld, ball, 0.6, 90.0, 10.0, 1.0, 1000.0, 25.0, new Vector2(0, -3), 0, Vector2.One.clone());
        
           // Equalize the size by the pressure by extending the soft body a bit so it won't wobble right off:
           pb.setPositionAngle(null, 0, new Vector2(4.33, 4.33));
        
           pb.finalizeTriangles(0x996633, 0x996633);
        
           mPressureBodies.push(pb);
        
        
           mWorld.setMaterialPairData(0, 0, 0.0, 0.9);
        
        
           var bs:Number = 1.3;
        
           fix(createBox(0, -18, bs, bs, 0));
        
           fix(createBox(2, -15, bs, bs, 0));
           fix(createBox(-2, -15, bs, bs, 0));
        
           fix(createBox(4, -12, bs, bs, 0));
           fix(createBox(0, -12, bs, bs, 0));
           fix(createBox(-4, -12, bs, bs, 0));
        
           fix(createBox(6, -9, bs, bs, 0));
           fix(createBox(2, -9, bs, bs, 0));
           fix(createBox(-2, -9, bs, bs, 0));
           fix(createBox(-6, -9, bs, bs, 0));
        
           createBox(-9, -12, 2, 27, 3).setPositionAngle(null, Math.PI / 5, null);
           createBox(9, -12, 2, 27, 3).setPositionAngle(null, -Math.PI / 5, null);
           }
           }*/
        
        public function mouseClick(e:Event):void
        {
            // cursorPos = new Vector3(Mouse.GetState().X - Window.ClientBounds.Width / 2, -Mouse.GetState().Y + Window.ClientBounds.Height / 2, 0) * 0.038;
            
            var s:Vector2 = RenderingSettings.Scale;
            var p:Vector2 = RenderingSettings.Offset;
            
            // var cursorPos = new Vector2(mouseX - p.X, mouseY - p.Y);
            var cursorPos = new Vector2((mouseX - p.X) / s.X, (mouseY - p.Y) / s.Y);
            
            if (dragBody == null)
            {
                var body:Array = [0];
                var dragp:Array = [0];
                
                mWorld.getClosestPointMass(cursorPos, body, dragp);
                
                dragPoint = dragp[0];
                dragBody = mWorld.getBody(body[0]);
            }
            
            mouseDown = true;
        }
        
        public function mouseup(e:Event):void
        {
            mouseDown = false;
            
            dragBody = null;
        }
        
        public function numbOfPairs(numb:int, wholeNumb:int):int
        {
            var i:int = 0;
            
            while (wholeNumb > numb)
            {
                wholeNumb -= numb;
                i++;
            }
            
            return i;
        }
        
        public function loop(e:Event):void
        {
            var s:Vector2 = RenderingSettings.Scale;
            var p:Vector2 = RenderingSettings.Offset;
            
            var cursorPos:Vector2 = new Vector2((mouseX - p.X) / s.X, (mouseY - p.Y) / s.Y);
            
            var pm:PointMass;
            
            if (Input2.keysDownInterval[32] == 1)
                go = !go;
            
            if (go)
                for (var i:int = 0; i < physicsIter; i++)
                {
                    mWorld.update(1.0 / (Number)(frameRate * physicsIter));
                    
                    if (dragBody != null)
                    {
                        pm = dragBody.getPointMass(dragPoint);
                        
                        if (dragBody is DraggableSpringBody)
                            DraggableSpringBody(dragBody).setDragForce(VectorTools.calculateSpringForceRetPos(pm.PositionX, pm.PositionY, pm.VelocityX, pm.VelocityY, cursorPos.X, cursorPos.Y, 0, 0, 0.0, 100.0, 10.0), dragPoint);
                        
                        else if (dragBody is DraggablePressureBody)
                            DraggablePressureBody(dragBody).setDragForce(VectorTools.calculateSpringForceRetPos(pm.PositionX, pm.PositionY, pm.VelocityX, pm.VelocityY, cursorPos.X, cursorPos.Y, 0, 0, 0.0, 100.0, 10.0), dragPoint);
                    }
                }
            
            RenderCanvas.graphics.clear();
            
            // Control the blob on test 2
            if (tId == 2)
            {
                var pb:PressureBody;
                for (i = 0; i < mWorld.mBodies.length; i++)
                {
                    var testBody:Body = mWorld.mBodies[i];
                    if (testBody is DraggablePressureBody)
                    {
                        pb = testBody as DraggablePressureBody;
                        break;
                    }
                }
                
                if (Input2.press_up)
                {
                    pb.setEdgeSpringConstants(900, 25);
                    pb.GasPressure = 400;
                }
                else
                {
                    pb.setEdgeSpringConstants(400, 20);
                    pb.GasPressure = 150;
                }
                
                if ((Input2.press_left && pb.DerivedOmega() < 5) || (Input2.press_right && pb.DerivedOmega() > -5))
                {
                    for (i = 0; i < pb.mPointMasses.length; i++)
                    {
                        pm = pb.mPointMasses[i];
                        // var pmL:PointMass = mPointMasses[
                        
                        var dx:Number = pm.PositionX - pb.DerivedPosition.X;
                        var dy:Number = pm.PositionY - pb.DerivedPosition.Y;
                        
                        var dis:Number = Math.sqrt(dx * dx + dy * dy);
                        
                        dx /= dis;
                        dy /= dis;
                        
                        if (Input2.press_left)
                        {
                            dx = -dx;
                            dy = -dy;
                        }
                        
                        pm.ForceX += dy * 25;
                        pm.ForceY += -dx * 25;
                    }
                }
            }
            
            if (!showDebug)
            {
                for (i = 0; i < mWorld.mBodies.length; i++)
                {
                    mWorld.mBodies[i].drawMe(RenderCanvas.graphics);
                }
            }
            else
            {
                // draw all the bodies in debug mode, to confirm physics.
                mWorld.debugDrawMe(RenderCanvas.graphics);
                mWorld.debugDrawAllBodies(RenderCanvas.graphics, false);
            }
            
            if (dragBody != null)
            {
                s = RenderingSettings.Scale;
                p = RenderingSettings.Offset;
                
                pm = dragBody.mPointMasses[dragPoint];
                
                RenderCanvas.graphics.lineStyle(1, 0xD2B48C);
                
                RenderCanvas.graphics.moveTo(pm.PositionX * s.X + p.X, pm.PositionY * s.Y + p.Y);
                RenderCanvas.graphics.lineTo(mouseX, mouseY);
            }
            else
            {
                dragBody = null;
                dragPoint = -1;
            }
        }
    }
}