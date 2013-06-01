package ca.sublight.sigil
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.text.TextField;
	
	import ca.rockspirit.datatypes.Colour;

	public class TestScreen
	{
		public function TestScreen()
		{
		}
		
		protected static var _bm:Vector.<BitmapData> = new Vector.<BitmapData> ( SigilUniverse.NUM_SCREENS );
		
		public static function getScreen ( id:int ):BitmapData {
			if ( _bm[id] )
				return _bm[id];
			
			var colour:Colour = Colour.fromString('white');
			
			var bm:BitmapData = new BitmapData ( 320, 320, false, colour.argb );
			var tf:TextField = new TextField ();
			tf.textColor = 0;
			tf.text = String ( id );
			
			var mat:Matrix = new Matrix ();
			mat.translate( tf.textWidth / -2, tf.textHeight / -2 );
			mat.scale( 4, 4 );
			mat.translate( 160, 160 );
			
			bm.draw( tf, mat );
			_bm[id] = bm;
			return bm;
		}
		
	}
}