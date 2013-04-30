// Load the horten module, and call it 'H' This will refer to an object with
// many properties.
var H  = require('horten');
var fs = require('fs');
var sprintf = require('sprintf').sprintf;

var spawn = require( 'child_process' ).spawn;

function OrbitCamera ( )
{
	var listener = new H.Listener ( {
		path: 		'/camera',
		primitive: 	true
	}, onData );

	config = {
		destination: 'http://dodo.hatestheinternet.com/ws/orbit/orbit/'
	}

	var width = 640, height = 480;

	listener.set ( {
		brightness: 117/255,
		contrast: 	31/255,
		gain: 		35/255,
		saturation: 0/255

	});

	var testCamera = -1;

	setInterval( iterateTestCamera, 10000 );

	function iterateTestCamera () {
		if ( testCamera >= 0 ) {
			var id = cameraMap.indexOf ( testCamera );
			if ( id >= 0 ) 
				singlePic( id, new Date (), function ( url ) {
					listener.set( url, 'viewfinder/test' );
				} )		
		}
	}



	function onData ( value, path ) {
		var parse;

		if ( path.startsWith ( '/reset/' ) ) {
			refreshCameras ();
		} else if ( path.startsWith( '/shutter') ) {
			if ( value )
				takePicture ();
		} else if ( parse = path.startsWith( '/map' ) ) {
			if ( value ) {
				var y = parseInt ( parse.array[ 0 ] ) - 1;
				var x = parseInt ( parse.array[ 1 ] ) - 1;
				if ( x < numCameras )
					cameraMap[x] = y;
			}

			refreshCameraMap();
		} else if ( path.startsWith( '/test/stop' ) ) {
			testCamera = -1;			
		} else if ( parse = path.startsWith( '/test') ) {
			var x = parseInt ( parse.array[ 0 ] ) - 1;
			if ( value ) {
				testCamera = x;
			}
		}
	}

	var numCameras = 0
	var cameraMap  = [];

	refreshCameras ();

	function takePicture () {
		var time = new Date ();

		console.log ( "Taking picture at ", time );

		for ( var i = 0; i < cameraMap.length; i ++ ) {
			singlePic( i, time );
		}

	}

	function refreshCameras ( ) {
		cameraMap = [];
		for ( var i = 0; i < 16; i ++ ) {
			var file = '/dev/video'+i;	

			if ( !fs.existsSync ( file ) )
				break;

			cameraMap[i] = i;
		}

		refreshCameraMap ( );
	}

	function singlePic ( cameraId, time, callback ) {
		var jpegFile = time.getTime()+'.'+cameraId+'.jpg';

		var filename = sprintf(
			"%02u%02u/%02u%02u%02u/%u.jpg", 
			time.getMonth() + 1,
			time.getDate(),
			time.getHours(),
			time.getMinutes(),
			time.getSeconds(),
			cameraId
		);

		var destinationURL = config.destination+filename;

		var cmd = [
			"-d"+"/dev/video"+cameraMap[cameraId],
			"-B"+imageConfigNumber('brightness'),
			"-C"+imageConfigNumber('contrast'),
			"-S"+imageConfigNumber('saturation'),
			"-G"+imageConfigNumber('gain'),
			"-q"+80,
			"-x"+width,
			"-y"+height,
			"-o"+jpegFile
		];

		console.log ( 'uvccapture', cmd );

		var uvccapture = spawn ( 'uvccapture', cmd );
		
		/*
		uvccapture.stderr.on('data', function (data) {
			console.log( cameraId, 'uvcc stderr', data.toString());
		});

		uvccapture.stdout.on('data', function (data) {
			console.log( cameraId, 'uvcc stdout', data.toString());
		});
		*/

		uvccapture.on('close', function ( code ) {
			
			var curl = spawn ( 'curl', [
				destinationURL,
				"--form",
				"file=@"+jpegFile,
				"--form",
				"method=PUT"
			] );



			curl.on('close', function ( code ) {
				console.log ( "uploading", jpegFile, "to", destinationURL );

				fs.unlink ( jpegFile, function() {} );
				if ( callback )
					callback( destinationURL );
			});

		});
	}


	function imageConfigNumber ( key ) {
		var val = parseInt( parseFloat( listener.get( key ) ) * 255 );
		return String(val);
	}


	function refreshCameraMap ( ) {
		var out = [];
		var rows = 12, cols = 12, l = cameraMap.length;

		for ( var x = 1; x <= cols; x ++ ) {
			var col = out[x] = [];
			for ( var y = 1; y <= rows; y ++ ) {
				col[y] = x - 1 < l && y - 1 < l && cameraMap[x-1] == y-1;
			}
		}

		listener.set( out, 'map' );
	}


}

exports.camera = OrbitCamera;




/**
	Itemize the cameras currently connected to the computer.
*/
/*




refreshCameras();

var listener = new H.Listener ( '/shutter/', function ( value, path ) {
	console.log( "SNAP! " );
	var time = new Date ().getTime();
	var jpegFile = 'camera.jpg';

	var uvccapture = spawn ( 'uvccapture', 
		[
			"-B128",
			"-C32",
			"-S16",
			"-G32",
			"-x640",
			"-y480",
			"-o"+jpegFile
		]
	);

	uvccapture.on('close', function ( code ) {
		console.log('Took a pic!', jpegFile );

		var url = "http://panjandrum.local:65432/ws/original/orbit/"+time+"/camera.jpg";
		var curl = spawn ( 'curl', [
			url,
			"--form",
			"file=@"+jpegFile
		] );

		curl.on('close', function ( code ) {
			console.log ( 'Saved to', url );
		});

	});
} );
*/