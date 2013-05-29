package ca.sublight.sigil
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;

	public class Sequence
	{
		public static const SEQ_MAX:uint = 9;
		
		protected var _loaders:Array = [];
		protected var _frames:Vector.<BitmapData> = new Vector.<BitmapData>;
		
		public function Sequence()
		{
		}
		
		public function imageURL ( frame:int, url:String ):void {
			if ( frame < _frames.length && ( _frames[frame] || _loaders[frame] ) )
				return;
			
			var req:URLRequest = new URLRequest ( url );
			
			var loader:Loader = _loaders[frame] = new Loader ();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onInit );
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
				_frames[frame] = content.bitmapData;
			}
		}
		
		public function getFrame( frame:int ):BitmapData {
			if ( _frames.length <= frame )
				return null;
			
			return _frames[frame];
		}
	}
}