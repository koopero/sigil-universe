package ca.sublight.sigil
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import ca.rockspirit.horten.Horten;
	import ca.rockspirit.horten.HortenListener;
	
	public class Screen extends Sprite
	{
		public var listener:HortenListener;
		
		public var smooth:Boolean 			= false;		
		public var corner:Vector.<Point> 	= Vector.<Point>([ new Point ( 0, 0 ),new Point ( 1, 0 ),new Point ( 0, 1 ),new Point ( 1, 1 )] );
		
		public function Screen( path:String )
		{
			listener = new HortenListener ( path, null, false );			
			listener.callback = onHorten; 
			
			super();
		}
		
		
		protected function onHorten ( path:String, value:* ):void {
			trace ( "SCREEN", listener.path, path, value );
			var a:Array = Horten.pathArray( path );
			
			var numVal:Number = Number(value);		
			var time:int = flash.utils.getTimer();
			

			
			switch ( a[0] ) {
				case 'corner':
					if ( a[2] == '1' ) {
						corner[int(a[1])].y = numVal;
					} else {
						corner[int(a[1])].x = numVal;
					}
				break;
			}
			
		}
		
		
		//	----------------------------
		//	Place a bitmap on the screen
		//	----------------------------
		
		public function clear():void {
			graphics.clear();
		}
		
		
		public function drawBitmap ( bitmap:BitmapData ):void {
			
			
			var width:Number = stage.stageWidth;
			var height:Number = stage.stageHeight;
			
			var p1:Point = new Point ( corner[0].x * width, corner[0].y * height );
			var p2:Point = new Point ( corner[1].x * width, corner[1].y * height );
			var p3:Point = new Point ( corner[2].x * width, corner[2].y * height );
			var p4:Point = new Point ( corner[3].x * width, corner[3].y * height );
			
			
			
			
			var pc:Point = getIntersection(p1, p4, p2, p3); // Central point
			
			// If no intersection between two diagonals, doesn't draw anything
			if (!Boolean(pc)) return;
			
			
			// Lengths of first diagonal		
			var ll1:Number = Point.distance(p1, pc);
			var ll2:Number = Point.distance(pc, p4);
			
			// Lengths of second diagonal		
			var lr1:Number = Point.distance(p2, pc);
			var lr2:Number = Point.distance(pc, p3);
			
			// Ratio between diagonals
			var f:Number = (ll1 + ll2) / (lr1 + lr2);
			
			// Draws the triangle
			
			graphics.beginBitmapFill(bitmap, null, false, smooth );
			
			graphics.drawTriangles(
				Vector.<Number>([p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y]),
				Vector.<int>([0,1,2, 1,3,2]),
				Vector.<Number>([0,0,(1/ll2)*f, 1,0,(1/lr2), 0,1,(1/lr1), 1,1,(1/ll1)*f]) // Magic
			);
		}
		
		
		
		protected function getIntersection(p1:Point, p2:Point, p3:Point, p4:Point): Point {
			// Returns a point containing the intersection between two lines
			// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
			// http://www.gamedev.pastebin.com/f49a054c1
			
			var a1:Number = p2.y - p1.y;
			var b1:Number = p1.x - p2.x;
			var a2:Number = p4.y - p3.y;
			var b2:Number = p3.x - p4.x;
			
			var denom:Number = a1 * b2 - a2 * b1;
			if (denom == 0) return null;
			
			var c1:Number = p2.x * p1.y - p1.x * p2.y;
			var c2:Number = p4.x * p3.y - p3.x * p4.y;
			
			var p:Point = new Point((b1 * c2 - b2 * c1)/denom, (a2 * c1 - a1 * c2)/denom);
			
			if (Point.distance(p, p2) > Point.distance(p1, p2)) return null;
			if (Point.distance(p, p1) > Point.distance(p1, p2)) return null;
			if (Point.distance(p, p4) > Point.distance(p3, p4)) return null;
			if (Point.distance(p, p3) > Point.distance(p3, p4)) return null;
			
			return p;
		}
		
		
	}
}