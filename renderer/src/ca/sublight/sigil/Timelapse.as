package ca.sublight.sigil
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import ca.rockspirit.horten.HortenListener;

	public class Timelapse
	{
		public var feedback:BitmapData;
		public var viewfinder:BitmapData;
				
		public var listener:HortenListener;
		
		public var mask:Shape;
		public var maskBm:BitmapData;
		
		public function Timelapse( path:String )
		{
			listener = new HortenListener ( path );
			listener.callback = onHorten;
			feedback = new BitmapData ( 320,320, false, 0 );
		}
		
		protected function onHorten ( path:String, value:* ):void {
			next = value;
		}
		
		public function update ():void
		{
			load();
			
			if ( viewfinder ) {
				
				if ( !mask ) {
					mask = new Shape ();
				}
				
				mask.graphics.clear();
				mask.graphics.beginFill( 0, 0.2 );
				mask.graphics.drawCircle( Math.random() * 320, Math.random() * 320, Math.random() * 10 + 50 );
				mask.graphics.endFill();
				
				maskBm = new BitmapData ( 320, 320, true, 0 );
				maskBm.draw( mask );
				
				
				var ct:ColorTransform = new ColorTransform ( 1,1,1,0.1 );
				feedback.copyPixels( viewfinder, new Rectangle ( 0,0,320,320), new Point (), maskBm, new Point (), true );
			}
			
		}
		
		protected var next:String;
		protected var lastLoaded:String;
		
		protected var loader:Loader;
		protected var loading:String;
		
		public function load ():void {
			if ( next == lastLoaded || !next )
				return;
			
			if ( loader )
				return;
			
			loading = next;
			
			var req:URLRequest = new URLRequest( next );
			
			loader = new Loader ();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onInit );
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError );
			loader.load( req );
			
		}
		
		protected function onInit ( e:Event ):void {
			var cli:LoaderInfo = e.target as LoaderInfo;
			var content:Bitmap = cli.loader.content as Bitmap;
			
			if ( content ) {
				viewfinder = new BitmapData ( 320, 320, false );
				var mat:Matrix = new Matrix ();
				mat.translate( -320, -240 );
				mat.rotate( Math.PI / -2 );
				mat.scale( 320/480, 320/480 );
				mat.translate( 160, 108 );
				
				viewfinder.draw( content.bitmapData, mat, null,null,null,true );
			}
			
			lastLoaded = loading;
			loading = null;
			
			cli.removeEventListener(Event.INIT, onInit );
			cli.removeEventListener(IOErrorEvent.IO_ERROR, onError );
			loader = null;
		}
		
		protected function onError ( e:Event ):void {
			var cli:LoaderInfo = e.target as LoaderInfo;
			trace ( "Timelapse loader error", e );
			cli.removeEventListener(Event.INIT, onInit );
			cli.removeEventListener(IOErrorEvent.IO_ERROR, onError );
			loader = null;
		}
		
		
		
	}
}