var config = require('../config.js');

var http = require('http');

var hortenDir = '../src/';

var H = require( 'horten' );
new H ( { debug: true } );

var Latch = require('../horten-toys/Latch.js').latch;


//
//	spinner latchs
//


new Latch ( {
	path: '/latch/spinnerPos/',
	cols: 4,
	target: '/screens/spinner/',
	channels: {
		'pos': {
			source: '/spinner/pos/',
			target: 'pos/value'
		}
	}
});

new Latch ( {
	path: '/latch/spinnerRandom/',
	target: '/screens/spinner/',
	channels: {
		'url': {
			target: 'url',
			source: function () {
				return getRandomSeq();
			}
		}
	}
})

new Latch ( {
	path: '/latch/spinnerSpin/',
	target: '/screens/spinner/',
	channels: {
		'pos': {
			target: 'pos/value',
			source: Math.random
		}
	}
})


//
//	index
//

var indexURL = config.web.root + config.web.index;
var index = [];

console.log ( "Index URL ", indexURL );

setInterval ( pullIndex, 10000 );
pullIndex ();

function pullIndex () {
	var req = http.request( indexURL, function(res) {
		res.setEncoding('utf8');

		var json = '';

		res.on('data', function (chunk) {
			json += chunk;
		});

		res.on('end', function () { 
			try {
				var newIndex = JSON.parse ( json );
				index = newIndex;
				//console.log ( "Pulled Index" );
			} catch ( e ) {
				console.log ( "ERROR PULLING INDEX" );
			}

		})
	});

	req.on('error', function(e) {
		console.log('Error pulling index' + e.message);
	});

	req.end();
}


function getRandomSeq ()
{
	var id = Math.floor ( Math.random () * index.length );
	var ind = index[id];
	if ( ind )
		return ind.seq;
}

//
//	camera
//

var cameraRoll

console.log ("Camera URL", 'ws://'+config.camera.host+':'+config.camera.http );

var camera = new H.WebSocketClient ( 'ws://'+config.camera.host+':'+config.camera.http, {
	path: '/camera',
	prefix: '/camera',
	keepAlive: true
});
camera.push();

// Latch for pushing latest to screens
new H.Listener ( '/camera/latest/url', function ( value ) {




	var pad = H.get('/pushLatest/pad' );
	for ( var x = 1; x <= 4; x++ ) 
		for ( var y = 1; y <= 4; y++ ) {
			if ( pad && pad[x] && pad[x][y] ) {
				var id = ( x - 1 ) + ( y - 1 ) * 4;
				H.set( value, '/screens/spinner/'+id+'/url' );
				H.set( 'spinner', '/screens/source/'+id );
			}
		}
		
});


//
//	countdown
//

var countdown = function () {

	var listener = this.listener = new H.Listener ( {
		path: 'countdown',
		primitive: true
	}, function ( value, path ) {
		//console.log ( 'countdown', value, path.string );
		if ( path.startsWith ( '/start' ) && value ) {
			start ();
		} else if ( path.startsWith ( '/stop' ) && value ) {
			stop ();
		} else if ( xy = path.startsWith ( '/step/pad' ) ) {
			var id = parseInt( xy.array[0] ) -1;
			if ( value ) {
				frame ( id );
			}
		}
	} );

	function frame ( id ) {
		console.log ( "Countdown frame", id );
		H.set ( listener.get ( '/seq/'+id ) );
		listener.set ( padArrayX ( id, 10 ), '/step/pad' );
	}

	function start () {

	}
}

new countdown ();

function padArrayX ( id, max ) {
	if ( max === undefined )
		max = 10;

	id = id + 1;
	var ret = [];
	for ( var i = 0; i <= max; i ++ ) {
		ret[i] = i == id ? [ 0, 1 ] : [ 0, 0 ];
	}

	return ret;
}

//
//	Sources
//

var sources = {
	'spinner': {}, 
	'timelapse': {},
	'feedback': {}
};

for ( var k in sources ) {
	createSource ( k );
} 

function createSource ( source )
{
	var listener = new H.Listener ( {
		path: 'source/'+source,
		primitive: true
	}, function ( value, path ) {
		var pa = path.array;

		if ( pa[0] == 'pad' ) {
			if ( value ) {
				var x = parseInt ( pa[1] ),
					y = parseInt ( pa[2] );
				var screenId = padToScreenId ( x, y );

				for ( var k in sources ) {
					H.set( k == source ? 1 : 0, 'source/'+k+'/pad/'+x+'/'+y );
				}

				H.set ( source, '/screens/source/'+screenId );
			} else {
				//listener.set(1,path );
			}

		}
	} );
}

function padToScreenId ( x, y ) {
	return ( x - 1 ) + ( y - 1 ) * 4;
}

//
//	timelapse
//

new H.Listener ( '/camera/viewfinder/url', function ( value ) {
	H.set(value,'/screens/viewfinder/url')
})

//
//	lightshow presets
//

new H.Listener ( { 
	path: '/preset/countdown/write/pad',
	primitive: true
	}, function ( value, path ) {
		if ( value ) {
			var id = parseInt( path.array[0] ) - 1;
			H.set ( H.get( '/lightshow' ), '/countdown/seq/' + id + '/lightshow' );
		}
	} );

new H.Listener ( { 
	path: '/preset/countdown/read/pad',
	primitive: true
	}, function ( value, path ) {
		if ( value ) {
			var id = parseInt( path.array[0] ) - 1;
			H.set ( H.get( '/countdown/seq/' + id + '/lightshow' ), '/lightshow' );
		}
	} );

//
//	server
//

var server = new H.Server ( {
	websocket: true,
	//sockJS: true,
	//sockJSPort: 1338,
	port: config.master.port,
	hostname: config.master.host
} );


//
//	iPads ( touchOSC )
//

var controls = new H.OSC ( {
	server: {
		port: config.controls.outPort,
		host: "localhost"
	},
	client: {
		port: config.controls.inPort,
		host: config.controls.host
	}
});

new H.Listener ('controls/push', function () {
	this.set(-1);
	process.nextTick ( function () {
		controls.push();
	});
});

//
//	Lightshow
//


var lightshowOSC = new H.OSC ( {
	path: "lightshow",
	client: {
		port: config.lightshow.osc,
		host: config.lightshow.host
	}	
})

for ( var i = 0; i < 3; i ++ ) {
	var path = 'lightshow/mod/'+i+'/';

	new Selector ( {
		path: path+'func/',
		selection: [ 'sine', 'halfsine', 'square', 'saw', 'noise' ]
	});

	new Selector ( {
		path: path+'blend/',
		selection: [ 'add', 'mult' ]
	});
}


//
//	Utilities that I don't have time to put into
//	horten-toys or whatever
//

function Selector ( config ) {
	
	config.primitive = true;

	var listener = new H.Listener ( config );

	var selection = config.selection;

	var index = 0;
	var count = selection.length;

	function setIndex( value ) {
		index = value;
		index %= count;
		if ( index < 0 )
			index += count;

		listener.set ( {
			value: selection[index],
			selector: ( index + 0.5 ) / count
		} );
	}


	listener.onData = function ( value, path )
	{
		var remains;
		if ( path.startsWith ( 'next' ) ) {
			if ( value )
				setIndex ( index + 1 );
		} else if ( path.startsWith ( 'prev' ) ) {
			if ( value )
				setIndex ( index - 1 );
		} else if ( path.startsWith( 'selector' ) ) {
			value = parseFloat ( value );
			if ( value >= 1 ) {
				setIndex( count - 1 );
			} else if ( value <= 0 ) {
				setIndex( 0 );
			} else {
				setIndex( Math.floor ( value * count ) );
			}

		}
	}
}

//
//
//

var mysqlState = new H.MySQL ( {
	connection: {
		host: 		'localhost',
		port: 		8889,
		user: 		'root',
		password: 	'root',
		database: 	'universe'
	}, 
	columns: 	['number'], 
	table: 		'state'
});
mysqlState.pull();

var mysqlHistory = new H.MySQL ( {
	connection: {
		host: 		'localhost',
		port: 		8889,
		user: 		'root',
		password: 	'root',
		database: 	'universe'
	}, 
	columns: 	['number'],
	history: 	true, 
	table: 		'history',
	pathTable: 	'path'
});



