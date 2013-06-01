package ca.sublight.sigil
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;

	public class Sequence
	{
		public static const SEQ_MAX:uint = 6;
		
		public var url:String;
		
		protected var _loaders:Array = [];
		protected var _frames:Vector.<BitmapData> = new Vector.<BitmapData> ( SEQ_MAX + 1 );
		
		
		protected static var __sequences:Object = {};
		public static function getSequence ( url:String ):Sequence {
			var seq:Sequence
			if ( !(seq = __sequences[url]) ) {
				return __sequences[url] = new Sequence ( url );
			} 
			return seq;
		}
		
		public function Sequence( url:String )
		{
			this.url = url;
		}
		
		public function loadFrame ( frame:int ):void {
			if (  _frames[frame] || _loaders[frame] )
				return;
			
			var url:String = this.url + frame + '.jpg';
			
			var req:URLRequest = new URLRequest ( url );
			
			var loader:Loader = _loaders[frame] = new Loader ();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onInit );
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError );
			loader.load( req );
			
		}
		
		protected function onInit ( e:Event ):void {
			var cli:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = cli.loader;
			var content:Bitmap = cli.loader.content as Bitmap;
			var frame:int = _loaders.indexOf( loader );
			
			if ( content ) {
				if ( _frames.length < frame ) 
					_frames.length = frame;
				
				var bm:BitmapData = new BitmapData ( 320, 320, false, 0xff0000 );
				var mat:Matrix = new Matrix ();
				mat.translate( -320, -240 );
				mat.rotate( Math.PI / -2 );
				mat.scale( 320/480, 320/480 );
				mat.translate( 160, 108 );
				
				bm.draw( content.bitmapData, mat, null,null,null,true );
				
				_frames[frame] = bm;
			}
			_loaders[frame] = null;
			cli.removeEventListener(Event.INIT, onInit );
			cli.removeEventListener(IOErrorEvent.IO_ERROR, onError );
			
		}
		
		protected function onError ( e:Event ):void {
			var cli:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = cli.loader;
			var frame:int = _loaders.indexOf( loader );
			_loaders[frame] = null;
			
			cli.removeEventListener(Event.INIT, onInit );
			cli.removeEventListener(IOErrorEvent.IO_ERROR, onError );
			
		}
		
		public function getFrame( frame:int ):BitmapData {
			loadFrame ( frame );
			
			if ( _frames.length <= frame )
				return null;
			
			return _frames[frame];
		}
	}
}