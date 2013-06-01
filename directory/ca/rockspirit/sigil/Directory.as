package ca.rockspirit.sigil
{
	import ca.rockspirit.horten.Horten;
	import ca.rockspirit.horten.HortenHttp;
	import ca.rockspirit.horten.HortenListener;
	import ca.rockspirit.horten.HortenWebSocket;
	
	import net.eportsystems.base.App;
	
	public class Directory extends App
	{


		public function Directory()
		{
			var root:String = 'http://10.4.1.40:65432/orbit/';
			var master:String = 'ws://localhost:1337/directory';
			
			super();

			var horten:Horten = Horten.getInstance();
			horten.debug = true;
			
			
			var indexData:HortenHttp = new HortenHttp ( root + 'gifIndex.php', '/index/' );
			indexData.autoPull = 3600;
			indexData.pull();
			
			var masterConnect:HortenWebSocket = new HortenWebSocket ( master );
			masterConnect.pullFromServer();
			
			var listener:HortenListener = new HortenListener ( "/", null, false );
			listener.callback = onHorten;
			
			
		}
		
		protected function onHorten ( path:String, value:* ):void {
			var pa:Array = path.split( '/' ).slice( 1 );
			trace ( '/pa', pa );
			
		}
	}
}