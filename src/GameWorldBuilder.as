package
{
    import JelloAS3.*;
    
    /**
     * ...
     * @author Michael Apfelbeck
     */
    public class GameWorldBuilder
    {
        
        public function GameWorldBuilder()
        {
        
        }
        
        public function Build(worldNum:int):World
        {
            switch (worldNum)
            {
            case 0: 
                return Build0();
                break;
            case 1: 
                return Build1();
                break;
            case 2: 
                return Build2();
                break;
            case 3: 
                return Build3();
                break;
            case 4: 
                return Build4();
                break;
            default: 
                throw new Error("wat??");
                break;
            }
        }
        
        private function Build0():World
        {
            var mWorld:World = new World();
            
            var mSpringBodies:Vector.<DraggableSpringBody> = new Vector.<DraggableSpringBody>();
            var mPressureBodies:Vector.<DraggablePressureBody> = new Vector.<DraggablePressureBody>();
            var mStaticBodies:Vector.<Body> = new Vector.<Body>();
            
            // Temp vars:
            var shape:ClosedShape;
            var pb:DraggablePressureBody;
            
            var groundShape:ClosedShape = new ClosedShape();
            groundShape.begin();
            groundShape.addVertex(new Vector2(-20, 1));
            groundShape.addVertex(new Vector2(20, 1));
            groundShape.addVertex(new Vector2(20, -1));
            groundShape.addVertex(new Vector2(-20, -1));
            groundShape.finish();
            
            // groundShape.transformOwn(0, new Vector2(3, 3));
            
            var groundBody:Body = new Body(mWorld, groundShape, Utils.fillArray(Number.POSITIVE_INFINITY, groundShape.Vertices.length), new Vector2(0, -19), 0, Vector2.One.clone(), false);
            
            mStaticBodies.push(groundBody);
            
            shape = new ClosedShape();
            
            shape.begin();
            shape.addVertexPos(0, 0);
            shape.addVertexPos(0, 1);
            shape.addVertexPos(0, 2);
            shape.addVertexPos(1, 2);
            shape.addVertexPos(2, 2);
            shape.addVertexPos(2, 1);
            shape.addVertexPos(2, 0);
            shape.addVertexPos(1, 0);
            shape.finish();
            
            for (var x = -16; x <= -10; x += 3)
            {
                /*var body:DraggableSpringBody = new DraggableSpringBody(mWorld, shape, 1, 150.0, 5.0, 300.0, 15.0, new Vector2(0, x), 0.0, Vector2.One.clone());
                
                   body.addInternalSpring(0, 2, 300, 10);
                   body.addInternalSpring(1, 3, 300, 10);*/
                
                var body1:DraggablePressureBody = new DraggablePressureBody(mWorld, shape, 1, 40.0, 150.0, 5.0, 300.0, 15.0, new Vector2(0, x), 0.0, Vector2.One.clone());
                
                //body.addInternalSpring(0, 2, 300, 10);
                //body.addInternalSpring(1, 3, 300, 10);
                
                //body.addTriangle(0, 1, 3);
                //body.addTriangle(1, 3, 2);
                body1.addTriangle(7, 0, 1);
                body1.addTriangle(7, 1, 2);
                body1.addTriangle(7, 2, 3);
                body1.addTriangle(7, 3, 4);
                body1.addTriangle(7, 4, 5);
                body1.addTriangle(7, 5, 6);
                
                mPressureBodies.push(body1);
                
                body1.finalizeTriangles(0x00FF7F, 0x00FF7F);
                
                    //mSpringBodies.Add(body);
                    //mPressureBodies.Add(body);
            }
            
            return mWorld;
        }
        
        private function Build1():World
        {
            var mWorld:World = new World();
            
            var mSpringBodies:Vector.<DraggableSpringBody> = new Vector.<DraggableSpringBody>();
            var mPressureBodies:Vector.<DraggablePressureBody> = new Vector.<DraggablePressureBody>();
            var mStaticBodies:Vector.<Body> = new Vector.<Body>();
            
            trace("oh hai!");
            // Temp vars:
            var shape:ClosedShape;
            var pb:DraggablePressureBody;
            
            var groundShape:ClosedShape = new ClosedShape();
            groundShape.begin();
            groundShape.addVertex(new Vector2(-20, 1));
            groundShape.addVertex(new Vector2(20, 1));
            groundShape.addVertex(new Vector2(20, -1));
            groundShape.addVertex(new Vector2(-20, -1));
            groundShape.finish();
            
            // groundShape.transformOwn(0, new Vector2(3, 3));
            
            var groundBody:Body = new Body(mWorld, groundShape, Utils.fillArray(Number.POSITIVE_INFINITY, groundShape.Vertices.length), new Vector2(0, -19), 0, Vector2.One.clone(), false);
            
            mStaticBodies.push(groundBody);
            
            shape = new ClosedShape();
            shape.begin();
            shape.addVertex(new Vector2(-1.5, 2.0));
            shape.addVertex(new Vector2(-0.5, 2.0));
            shape.addVertex(new Vector2(0.5, 2.0));
            shape.addVertex(new Vector2(1.5, 2.0));
            shape.addVertex(new Vector2(1.5, 1.0));
            shape.addVertex(new Vector2(0.5, 1.0));
            shape.addVertex(new Vector2(0.5, -1.0));
            shape.addVertex(new Vector2(1.5, -1.0));
            shape.addVertex(new Vector2(1.5, -2.0));
            shape.addVertex(new Vector2(0.5, -2.0));
            shape.addVertex(new Vector2(-0.5, -2.0));
            shape.addVertex(new Vector2(-1.5, -2.0));
            shape.addVertex(new Vector2(-1.5, -1.0));
            shape.addVertex(new Vector2(-0.5, -1.0));
            shape.addVertex(new Vector2(-0.5, 1.0));
            shape.addVertex(new Vector2(-1.5, 1.0));
            shape.finish();
            
            shape.transformOwn(0, new Vector2(1.0, 1.0));
            
            // draggablespringbody is an inherited version of SpringBody that includes polygons for visualization, and the
            // ability to drag the body around the screen with the cursor.
            for (var x:int = -8; x <= 8; x += 4)
            {
                var body:DraggableSpringBody = new DraggableSpringBody(mWorld, shape, 1, 150.0, 5.0, 300.0, 20.0, new Vector2(x, 0), 0.0, Vector2.One.clone());
                
                body.addInternalSpring(0, 14, 300.0, 10.0);
                body.addInternalSpring(1, 14, 300.0, 10.0);
                body.addInternalSpring(1, 15, 300.0, 10.0);
                body.addInternalSpring(1, 5, 300.0, 10.0);
                body.addInternalSpring(2, 14, 300.0, 10.0);
                body.addInternalSpring(2, 5, 300.0, 10.0);
                body.addInternalSpring(1, 5, 300.0, 10.0);
                body.addInternalSpring(14, 5, 300.0, 10.0);
                body.addInternalSpring(2, 4, 300.0, 10.0);
                body.addInternalSpring(3, 5, 300.0, 10.0);
                body.addInternalSpring(14, 6, 300.0, 10.0);
                body.addInternalSpring(5, 13, 300.0, 10.0);
                body.addInternalSpring(13, 6, 300.0, 10.0);
                body.addInternalSpring(12, 10, 300.0, 10.0);
                body.addInternalSpring(13, 11, 300.0, 10.0);
                body.addInternalSpring(13, 10, 300.0, 10.0);
                body.addInternalSpring(13, 9, 300.0, 10.0);
                body.addInternalSpring(6, 10, 300.0, 10.0);
                body.addInternalSpring(6, 9, 300.0, 10.0);
                body.addInternalSpring(6, 8, 300.0, 10.0);
                body.addInternalSpring(7, 9, 300.0, 10.0);
                
                // polygons!
                body.addTriangle(0, 15, 1);
                body.addTriangle(1, 15, 14);
                body.addTriangle(1, 14, 5);
                body.addTriangle(1, 5, 2);
                body.addTriangle(2, 5, 4);
                body.addTriangle(2, 4, 3);
                body.addTriangle(14, 13, 6);
                body.addTriangle(14, 6, 5);
                body.addTriangle(12, 11, 10);
                body.addTriangle(12, 10, 13);
                body.addTriangle(13, 10, 9);
                body.addTriangle(13, 9, 6);
                body.addTriangle(6, 9, 8);
                body.addTriangle(6, 8, 7);
                
                body.finalizeTriangles(0x00FF7F, 0xFF0080);
                
                mSpringBodies.push(body);
            }
            
            var ball:ClosedShape = new ClosedShape();
            ball.begin();
            for (var i:int = 0; i < 360; i += 20)
            {
                ball.addVertexPos(Math.cos((Math.PI / 180) * -i), Math.sin((Math.PI / 180) * -i));
            }
            ball.finish();
            
            for (x = -10; x <= 10; x += 5)
            {
                pb = new DraggablePressureBody(mWorld, ball, 1.0, 40.0, 10.0, 1.0, 300.0, 20.0, new Vector2(x, -12), 0, Vector2.One.clone());
                
                pb.addTriangle(0, 10, 9);
                pb.addTriangle(0, 9, 1);
                pb.addTriangle(1, 9, 8);
                pb.addTriangle(1, 8, 2);
                pb.addTriangle(2, 8, 7);
                pb.addTriangle(2, 7, 3);
                pb.addTriangle(3, 7, 6);
                pb.addTriangle(3, 6, 4);
                pb.addTriangle(4, 6, 5);
                pb.addTriangle(17, 10, 0);
                pb.addTriangle(17, 11, 10);
                pb.addTriangle(16, 11, 17);
                pb.addTriangle(16, 12, 11);
                pb.addTriangle(15, 12, 16);
                pb.addTriangle(15, 13, 12);
                pb.addTriangle(14, 12, 15);
                pb.addTriangle(14, 13, 12);
                
                // pb.finalizeTriangles((x==-10) ? Color.Teal : Color.Maroon);
                pb.finalizeTriangles(0x008080, 0xFFFFFF);
                
                mPressureBodies.push(pb);
                
                if (x == -10)
                {
                    pb.GasPressure = 0;
                }
            }
            
            return mWorld;
        }
        
        private function Build2():World
        {
            var mWorld:World = new World();
            
            var mSpringBodies:Vector.<DraggableSpringBody> = new Vector.<DraggableSpringBody>();
            var mPressureBodies:Vector.<DraggablePressureBody> = new Vector.<DraggablePressureBody>();
            var mStaticBodies:Vector.<Body> = new Vector.<Body>();
            
            trace("oh hai!");
            // Temp vars:
            var shape:ClosedShape;
            var pb:DraggablePressureBody;
            
            var groundShape:ClosedShape = new ClosedShape();
            groundShape.begin();
            groundShape.addVertex(new Vector2(-20, 1));
            groundShape.addVertex(new Vector2(20, 1));
            groundShape.addVertex(new Vector2(20, -1));
            groundShape.addVertex(new Vector2(-20, -1));
            groundShape.finish();
            
            // groundShape.transformOwn(0, new Vector2(3, 3));
            
            var groundBody:Body = new Body(mWorld, groundShape, Utils.fillArray(Number.POSITIVE_INFINITY, groundShape.Vertices.length), new Vector2(0, -19), 0, Vector2.One.clone(), false);
            
            mStaticBodies.push(groundBody);
            
            var def:Number = 20;
            
            var ball:ClosedShape = new ClosedShape();
            ball.begin();
            for (var i = 0; i < 360; i += def)
            {
                ball.addVertexPos(Math.cos((Math.PI / 180) * -i), Math.sin((Math.PI / 180) * -i));
            }
            ball.transformOwn(0, new Vector2(0.3, 0.3));
            ball.finish();
            
            var x:int;
            pb = new DraggablePressureBody(mWorld, ball, 0.6, 30.0, 10.0, 1.0, 600.0, 20.0, new Vector2(x, -15), 0, Vector2.One.clone());
            
            pb.finalizeTriangles(0x008080, 0x000000);
            
            mPressureBodies.push(pb);
            
            mSpringBodies.push(createBox(mWorld, 5, -17, 2, 2, 0));
            mSpringBodies.push(createBox(mWorld, 5, -14, 2, 2, 0));
            mSpringBodies.push(createBox(mWorld, 5, -11, 2, 2, 0));
            mSpringBodies.push(createBox(mWorld, 5, -8, 2, 2, 0));
            mPressureBodies.push(createBox(mWorld, 0, -17, 2, 2, 1));
            mStaticBodies.push(createBox(mWorld, -5, -10, 3, 3, 2));
            
            return mWorld;
        }
        
        private function Build3():World
        {
            var mWorld:World = new World();
            
            var mSpringBodies:Vector.<DraggableSpringBody> = new Vector.<DraggableSpringBody>();
            var mPressureBodies:Vector.<DraggablePressureBody> = new Vector.<DraggablePressureBody>();
            var mStaticBodies:Vector.<Body> = new Vector.<Body>();
            
            trace("oh hai!");
            // Temp vars:
            var shape:ClosedShape;
            var pb:DraggablePressureBody;
            
            var groundShape:ClosedShape = new ClosedShape();
            groundShape.begin();
            groundShape.addVertex(new Vector2(-20, 1));
            groundShape.addVertex(new Vector2(20, 1));
            groundShape.addVertex(new Vector2(20, -1));
            groundShape.addVertex(new Vector2(-20, -1));
            groundShape.finish();
            
            // groundShape.transformOwn(0, new Vector2(3, 3));
            
            var groundBody:Body = new Body(mWorld, groundShape, Utils.fillArray(Number.POSITIVE_INFINITY, groundShape.Vertices.length), new Vector2(0, -19), 0, Vector2.One.clone(), false);
            
            mStaticBodies.push(groundBody);
            
            mWorld.removeBody(groundBody);
            mStaticBodies.splice(mStaticBodies.indexOf(groundBody), 1);
            
            var def:Number = 20;
            
            var ball:ClosedShape = new ClosedShape();
            ball.begin();
            for (var i = 0; i < 360; i += def)
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
            
            mSpringBodies.push(fix(createBox(mWorld, 0, -18, bs, bs, 0)));
            
            mSpringBodies.push(fix(createBox(mWorld, 2, -15, bs, bs, 0)));
            mSpringBodies.push(fix(createBox(mWorld, -2, -15, bs, bs, 0)));
            
            mSpringBodies.push(fix(createBox(mWorld, 4, -12, bs, bs, 0)));
            mSpringBodies.push(fix(createBox(mWorld, 0, -12, bs, bs, 0)));
            mSpringBodies.push(fix(createBox(mWorld, -4, -12, bs, bs, 0)));
            
            mSpringBodies.push(fix(createBox(mWorld, 6, -9, bs, bs, 0)));
            mSpringBodies.push(fix(createBox(mWorld, 2, -9, bs, bs, 0)));
            mSpringBodies.push(fix(createBox(mWorld, -2, -9, bs, bs, 0)));
            mSpringBodies.push(fix(createBox(mWorld, -6, -9, bs, bs, 0)));
            
            mStaticBodies.push(createBox(mWorld, -9, -12, 2, 27, 3).setPositionAngle(null, Math.PI / 5, null));
            mStaticBodies.push(createBox(mWorld, 9, -12, 2, 27, 3).setPositionAngle(null, -Math.PI / 5, null));
            
            return mWorld;
        }
        
        private function Build4():World
        {
            var mWorld:World = new World();
            
            var mSpringBodies:Vector.<DraggableSpringBody> = new Vector.<DraggableSpringBody>();
            var mPressureBodies:Vector.<DraggablePressureBody> = new Vector.<DraggablePressureBody>();
            var mStaticBodies:Vector.<Body> = new Vector.<Body>();
            
            // Temp vars:
            var shape:ClosedShape;
            var pb:DraggablePressureBody;
            
            var groundShape:ClosedShape = new ClosedShape();
            groundShape.begin();
            groundShape.addVertex(new Vector2(-20, 1));
            groundShape.addVertex(new Vector2(20, 1));
            groundShape.addVertex(new Vector2(20, -1));
            groundShape.addVertex(new Vector2(-20, -1));
            groundShape.finish();
            
            // groundShape.transformOwn(0, new Vector2(3, 3));
            
            var groundBody:Body = new Body(mWorld, groundShape, Utils.fillArray(Number.POSITIVE_INFINITY, groundShape.Vertices.length), new Vector2(0, -19), 0, Vector2.One.clone(), false);
            
            mStaticBodies.push(groundBody);
            
            //world specific here
            
            return mWorld;
        }
        
        private function fix(b:Body):void
        {
            b.mIsPined = true;
            
            b.VelocityDamping = 0.97;
            
            (b as SpringBody).setEdgeSpringConstants(100, 10);
        }
        
        private function createBox(mWorld:World, x:Number, y:Number, w:Number, h:Number, t:int = 0):Body
        {
            var shape = new ClosedShape();
            
            if (t == 0)
            {
                shape.begin();
                shape.addVertexPos(0, 0);
                shape.addVertexPos(0, h);
                shape.addVertexPos(w, h);
                shape.addVertexPos(w, 0);
                shape.finish();
                
                var body:DraggableSpringBody = new DraggableSpringBody(mWorld, shape, 1, 150.0, 5.0, 300.0, 15.0, new Vector2(x, y), 0.0, Vector2.One.clone());
                
                body.addInternalSpring(0, 2, 300, 10);
                body.addInternalSpring(1, 3, 300, 10);
                
                body.addTriangle(0, 1, 2);
                body.addTriangle(1, 2, 3);
                body.finalizeTriangles(0xDDDD00, 0xDDDD00);
                
                //mSpringBodies.push(body);
                
                return body;
            }
            else if (t == 1)
            {
                shape.begin();
                shape.addVertexPos(0, 0);
                shape.addVertexPos(0, h / 2);
                shape.addVertexPos(0, h);
                shape.addVertexPos(w / 2, h);
                shape.addVertexPos(w, h);
                shape.addVertexPos(w, h / 2);
                shape.addVertexPos(w, 0);
                shape.addVertexPos(w / 2, 0);
                shape.finish();
                
                var body1:DraggablePressureBody = new DraggablePressureBody(mWorld, shape, 1, 200.0, 150.0, 5.0, 300.0, 15.0, new Vector2(x, y), 0.0, new Vector2(0.5, 0.5));
                
                body1.addTriangle(7, 0, 1);
                body1.addTriangle(7, 1, 2);
                body1.addTriangle(7, 2, 3);
                body1.addTriangle(7, 3, 4);
                body1.addTriangle(7, 4, 5);
                body1.addTriangle(7, 5, 6);
                
                //mPressureBodies.push(body1);
                
                body1.finalizeTriangles(0x00FF7F, 0x00FF7F);
                
                return body1;
            }
            else if (t == 2)
            {
                shape.begin();
                shape.addVertexPos(0, 0);
                shape.addVertexPos(0, h / 2);
                shape.addVertexPos(0, h);
                shape.addVertexPos(w / 2, h);
                shape.addVertexPos(w, h);
                shape.addVertexPos(w, h / 2);
                shape.addVertexPos(w, 0);
                shape.addVertexPos(w / 2, 0);
                shape.finish();
                
                var body2:SpringBody = new SpringBody(mWorld, shape, 5, 900, 50, 30, 15, new Vector2(x, y), 0, Vector2.One.clone(), true);
                
                //mStaticBodies.push(body2);
                
                return body2;
            }
            else if (t == 3)
            {
                shape.begin();
                shape.addVertexPos(0, 0);
                shape.addVertexPos(0, h);
                shape.addVertexPos(w, h);
                shape.addVertexPos(w, 0);
                shape.finish();
                
                var body3:Body = new Body(mWorld, shape, Utils.fillArray(Number.POSITIVE_INFINITY, shape.Vertices.length), new Vector2(x, y), 0, Vector2.One.clone(), false);
                
                //mStaticBodies.push(body3);
                
                return body3;
            }
            
            return null;
        }
    }

}