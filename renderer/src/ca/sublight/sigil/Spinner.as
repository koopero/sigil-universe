package ca.sublight.sigil
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import ca.rockspirit.horten.Horten;
	import ca.rockspirit.horten.HortenListener;

	public class Spinner
	{
		public var sequence:Sequence;
		public var frame:Number 	= 0;
		public var wantFrame:Number = 3;
		public var delta:Number		= 0;
		public var gravity:Number 	= 0.01;
		public var damping:Number 	= 0.99;
			
		protected var _bounds:Rectangle = new Rectangle ( 0, 0, 320, 320 );
		
		public var maskStyle:String = 'linear';
		public var maskAngle:Number = 90;
		public var maskFeather:Number = 480;
		
		protected var mask:Shape;
		
		protected var zeroPoint:Point = new Point ( 0, 0 );
		
		public var listener:HortenListener;
		
		public function Spinner( path:String )
		{
			listener = new HortenListener ( path, null, false );
			listener.callback = onHorten;
			
			mask = new Shape ();
		}
		
		protected function onHorten ( path:String, value:* ):void {
			var a:Array = Horten.pathArray( path );
			
			var numVal:Number = Number(value);		
			var time:int = flash.utils.getTimer();
			
			
			
			switch ( path ) {
				case '/url/':
					sequence = Sequence.getSequence( value );
				break;
				
				case '/gravity/value/':
					gravity = Math.pow ( 0.1, ( 2 - numVal )  );
					break;
				
				case '/pos/value/':
					wantFrame = Sequence.SEQ_MAX * numVal;
				break;
				
			}
			
		}
		
		
		public function update ():void 
		{
			delta += ( wantFrame - frame ) * gravity;
			delta *= damping;
			frame += delta;
			
			
			if ( frame > Sequence.SEQ_MAX ) 
				frame = Sequence.SEQ_MAX;
			
			if ( frame < 0 )
				frame = 0;
		}
		
		public function draw ():BitmapData
		{
			if ( !sequence )
				return null;
			
			var frame0:int = Math.floor( frame );
			var frame1:int = Math.min( Math.ceil( frame ), Sequence.SEQ_MAX );
			
			if ( frame0 == frame1 ) {
				return sequence.getFrame( frame0 );
			}
			
			var c:Number = frame - frame0;
			
			maskAngle = 180;
			
			drawMask ( mask, c, true );
			
			var maskBm:BitmapData = new BitmapData ( _bounds.width, _bounds.height, true, 0 );
			maskBm.draw( mask );
			var ret:BitmapData = new BitmapData ( _bounds.width, _bounds.height, false, 0 );
			
			var under:BitmapData = sequence.getFrame( frame0 );
			var over:BitmapData = sequence.getFrame( frame1 );
			
			if ( under )
				ret.copyPixels( under, _bounds, zeroPoint );
			
			if ( over )
				ret.copyPixels( over, _bounds, zeroPoint, maskBm, zeroPoint, true ); 
			
			
			
			return ret;
			
		}
		
		
		
		protected function drawMask ( shape:Shape, c:Number, invert:Boolean ):void {
			var gr:Graphics = shape.graphics;
			
			
			var feather:Number = Math.max ( 4, Math.abs ( maskFeather ) );
			
			gr.clear();
			
			var mat:Matrix = new Matrix ();
			
			if ( maskStyle == 'linear' ) {
				var vx:Number = Math.sin( maskAngle / 180 * Math.PI );
				var vy:Number = -Math.cos( maskAngle / 180 * Math.PI );
				
				var vl:Number = Math.max( _bounds.width, _bounds.height ) + feather;
				
				vx *= vl;
				vy *= vl;
				
				
				
				
				
				mat.createGradientBox( feather, feather );
				mat.translate( feather * -0.5, feather * -0.5 );
				mat.rotate( ( maskAngle - 90 ) / 180 * Math.PI );
				mat.translate( 
					_bounds.x + _bounds.width * 0.5 + vx * ( c - 0.5 ), 
					_bounds.y + _bounds.height * 0.5 + vy * ( c - 0.5 )
				);
				
				
				
				gr.beginGradientFill( GradientType.LINEAR, [ 0xff00ff, 0xff ], [ invert ? 1 : 0, invert ? 0 : 1 ], [ 0, 255], mat );
			} else {
				feather = Math.min ( 255, feather );
				
				var centre:Point = new Point ( _bounds.x + _bounds.width / 2, _bounds.y + _bounds.height / 2 );
				var radius:Number = Math.max(
					centre.x - _bounds.left,
					_bounds.right - centre.x,
					centre.y - _bounds.top,
					_bounds.bottom - centre.y
				);
				
				mat.createGradientBox( radius * 2, radius * 2 );
				mat.translate( -radius, -radius );
				mat.translate( centre.x, centre.y );
				
				var colours:Array = [];
				var ratios:Array = [];
				var alphas:Array = [];
				
				var ratioIn:Number = Math.round( c * ( 255 + feather ) - feather );
				var ratioOut:Number = Math.round( ratioIn + feather );
				
				if ( ratioIn >= 255 ) {
					colours.push ( 0xff00ff );
					alphas.push( invert ? 1 : 0 );
					ratios.push( 0 );
					
					colours.push ( 0xff00ff );
					alphas.push( invert ? 1 : 0 );
					ratios.push( 255 );
					
				} else if ( ratioIn > 0 ) {
					colours.push ( 0xff00ff );
					alphas.push( invert ? 1 : 0 );
					ratios.push( 0 );
					
					colours.push ( 0xff00ff );
					alphas.push( invert ? 1 : 0 );
					ratios.push( ratioIn );
				} else {
					var alpha:Number = -ratioIn / feather;
					if ( invert )
						alpha = 1 - alpha;
					
					colours.push ( 0xff00ff );
					alphas.push( alpha );
					ratios.push( 0 );
				}
				
				if ( ratioIn < 255 ) {
					if ( ratioOut < 255 ) {
						colours.push ( 0xff0000 );
						alphas.push( invert ? 0 : 1 );
						ratios.push( ratioOut );
						
						colours.push ( 0xff0000 );
						alphas.push( invert ? 0 : 1 );
						ratios.push( 255 );
					} else {
						alpha = 1 - ( ratioOut - 255 ) / feather;
						if ( invert )
							alpha = 1 - alpha;
						
						colours.push ( 0xff0000 );
						alphas.push( alpha );
						ratios.push( 255 );
					}
				}
				
				gr.beginGradientFill(GradientType.RADIAL, colours, alphas, ratios, mat );
				
			}
			
			
			gr.drawRect( _bounds.x, _bounds.y, _bounds.width, _bounds.height );
			gr.endFill();
			
		}
		
		
	}
}