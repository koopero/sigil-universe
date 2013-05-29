package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import ca.rockspirit.horten.Horten;
	import ca.rockspirit.horten.HortenListener;
	import ca.rockspirit.horten.HortenWebSocket;
	import ca.sublight.sigil.Screen;
	import ca.sublight.sigil.Sequence;
	import ca.sublight.sigil.Spinner;
	import ca.sublight.sigil.WSIndex;
	
	public class SigilUniverse extends Sprite
	{
		public static const HORTEN_WS:String = 'ws://localhost:1337/screens';
		public static const WATERSHED_URL:String = 'http://panjandrum.local:65432/ws/index/orbit/orbit/?depth=3';
		
		public static const NUM_SCREENS:uint = 12;
		
		public var status:TextField;
		
		public var index:WSIndex;
		
		public var screens:Vector.<Screen> = new Vector.<Screen>;
		public var spinners:Vector.<Spinner> = new Vector.<Spinner>;
		
		public var horten:Horten;
	
		public function SigilUniverse()
		{
			stage.frameRate = 60;
			stage.color = 0;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			horten = Horten.getInstance();
			
			
			var ws:HortenWebSocket = new HortenWebSocket ( HORTEN_WS );
			ws.pullFromServer();
			
			var listener:HortenListener = new HortenListener ( "/", null, false );
			listener.callback = onHorten;
			
			
			
			this.addEventListener(Event.ENTER_FRAME, onFrame );
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
			
			status = new TextField ();
			status.text = 'status';
			this.addChild( status );
			

			
			for ( var i:uint = 0; i < NUM_SCREENS; i ++ ) {
				var screen:Screen = new Screen ( '/screen/'+i);
				this.addChild( screen );
				screens[i] = screen;
				
				var spinner:Spinner = new Spinner ();
				spinners[i] = spinner;
			}
			
			
			WSIndex.indexURL = WATERSHED_URL;
			
			WSIndex.getIndex();
			
		}
		
		protected var screenId:int = 0;
		protected var cornerId:int = 0;
		
		protected function onHorten ( path:String, value:* ):void {
			var pa:Array = path.split( '/' ).slice( 1 );
			
			if ( pa[0] == 'corner' && pa[0] == 'screenId') {
				screenId = int ( pa[2] ) - 1 + ( int( pa[3] ) -1 ) * 4;
			} else if (  pa[1] == 'id' && value ) {
				cornerId = int ( pa[2] ) - 1 + ( int( pa[3] ) -1 ) * 2;
			} else if ( pa[0]	== 'corner' && pa[1] == 'coord' ) {
				var p:String = 'screen/'+screenId+"/corner/"+cornerId+"/"+pa[4];
				
				horten.set( p, value );
				
			}
			
		}
		
		protected function onFrame ( e:Event = null ):void {
			for ( var i:uint = 0; i < NUM_SCREENS; i ++ ) {
				
				spinners[i].update();
				
				var bm:BitmapData = spinners[i].draw();
				
				
				
				if ( bm ) { 
					var screen:Screen = screens[i];
					screen.clear();
					screen.drawBitmap( bm );
				}
			}
		}
		
		
		
		
		
		
		public function onKeyDown ( e:KeyboardEvent ):void {
			switch ( e.keyCode ) {
				case Keyboard.F:
					fullscreen = !fullscreen;
					break;
				
				/*case Keyboard.NUMBER_1:
				setReactorId ( 1 );
				break;
				
				case Keyboard.NUMBER_2:
				setReactorId ( 2 );
				break;
				*/
			}
		}
		
		public function get fullscreen ():Boolean
		{
			return stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE || stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE;
		}
		
		public function set fullscreen ( value:Boolean ):void {
			if ( value && stage.allowsFullScreen ) {
				try {
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				} catch ( e:Error ) {
					stage.displayState = StageDisplayState.FULL_SCREEN;
				}
			} else {
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
	}
}