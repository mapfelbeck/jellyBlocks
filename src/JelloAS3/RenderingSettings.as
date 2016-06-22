package JelloAS3 
{
	/**
	 * The rendering settings for the engines. There are Scale and Offset vectors that should be multiplied and added to the
	 * resulting vectors to position the bodies on screen. It works much like a camera!
	 * 
	 * @author Luiz
	 */
	public class RenderingSettings
	{
		// The point size of points drawn on screen (this value is independent of the Scale vector)
		public static var PointSize:Number = 3;
		
		// Why is the Y vector negative? The engine is a port of an XNA engine (JelloPhysics).
		// XNA is basicly 3D, so the Y vector grows up instead of down, like in a 2D screen (Say, Flash)
		public static var Scale:Vector2 = new Vector2(25.8, -25.8);
		
		// The offset is independent of the scale, unlike Flash DisplayObject's x-y coordinates and scaleX-scaleY
		public static var Offset:Vector2 = new Vector2(300, -50);
		
		// Transforms the given point on stage coordinates into World coordinates by using the rendering settings
		public static function ToWorld(point:Vector2) : Vector2
		{
			return new Vector2((point.X - Offset.X) / Scale.X, (point.Y - Offset.Y) / Scale.Y);
		}
		
		// Transforms the given point on World coordinates into Stage coordinates by using the rendering settings
		public static function ToStage(point:Vector2) : Vector2
		{
			return new Vector2(point.X * Scale.X + Offset.X, point.Y * Scale.Y + Offset.Y);
		}
		
		// Sets the camera position and scale from scalar values
		public static function SetCamera(positionX:Number, positionY:Number, scaleX:Number, scaleY:Number) : void
		{
			Offset.X = positionX;
			Offset.Y = positionY;
			
			Scale.X = scaleX;
			Scale.Y = scaleY;
		}
		
		// Sets the camera position and scale from vector values
		// Provide null values to keep the current ones
		public static function SetCameraVec(position:Vector2 = null, scale:Vector2 = null) : void
		{
			if(position != null)
			{
				Offset.X = position.X;
				Offset.Y = position.Y;
			}
			
			if(scale != null)
			{
				Scale.X = scale.X;
				Scale.Y = scale.Y;
			}
		}
	}
}