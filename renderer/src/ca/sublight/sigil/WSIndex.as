package ca.sublight.sigil
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	
	import ca.rockspirit.network.JSONCall;
	
	public class WSIndex extends EventDispatcher
	{
		public static var indexURL:String;
		
		public static var sequences:Array = [];
		
				
		public static function getIndex ():void {
			var call:JSONCall = new JSONCall ( indexURL, onGetIndex );
			
		}
		
		protected static function onGetIndex ( data:Object ):void {
			if ( data.listing ) {
				for each ( var ob:* in data.listing ) {
					if ( ob['type'] == 'file' ) {
						var pathArr:Array = ob.path.split('/');
						
						if ( pathArr[0] != 'orbit' ) {
							continue;
						}
						
						var day:String = pathArr[1];
						var time:String = pathArr[2];
						
						var seqId:int = int( day+time );
						var frame:int = int( pathArr[3].split('.')[0] );
						
						var seq:Sequence;
						seq = sequences[seqId];
						if ( !seq ) {
							seq = sequences[seqId] = new Sequence ();
						}
						
						seq.imageURL( frame, ob.url );												
					}
				}
			}
		}
		
		public static function getFrame ( seqId:int, frame:int ):BitmapData {
			var seq:Sequence;
			seq = sequences[seqId];
			if ( !seq ) {
				seq = sequences[seqId] = new Sequence ();
			}
			
			return seq.getFrame ( frame );
		}
	}
}