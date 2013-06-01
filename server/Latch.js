var http = require('http');

var horten = require ( './horten/Horten.js' );
var Horten = horten.Horten;

function Latch ( config ){
	var that = this;

	horten.Listener.call( this, config, this.ondata );
	this.catchAll = true;
	this.attach ();

	this.cols = 8;
	this.numPerSlice = 16;



	this.channels = config.channels;
	this.target = Horten.pathString ( config.target );

	this.num = 48;

	this.latch = [];

	this.randomChance = 0.3;
	this.randomXOR = true;
	this.randomApply = true;

	for ( var i = 0; i < this.num; i ++ ) {
		this.latch[i] 	= this.get ( 'latch' + this.indexToPath( i ) );
	}

	this.latchChannels = [];
	this.allChannels = [];

	this.listeners = [];

	for ( var k in this.channels ) {
		var channel = this.channels[k];
		if ( 'string' == typeof channel.source ) {
			var channelListener = new horten.Listener ( { path: channel.source, prefix: k }, function ( path, value ) {
				that.onChannelData( path, value );
			} );
			this.listeners.push ( channelListener );
		}

		if ( this.allChannels != undefined )
			this.allChannels.push( k );
	}
}

Latch.prototype = new horten.Listener ( null );

Latch.prototype.onChannelData = function ( path, value ) {
	
	var pa = Horten.pathArray ( path );
	console.log ( 'onCd', pa[0],this.latchChannels );
	if ( this.allChannels || this.latchChannels.indexOf ( pa[0] ) != -1 ) {
		var channel = this.channels[pa[0]];

		if ( !channel.onlyOnHigh || value )
			this.apply ( null, pa[0] );
	}
	
}

Latch.prototype.ondata = function ( path, value ) {
	

	var pa = Horten.pathArray ( path );

	switch ( pa[0] ) {
		case 'all':

			for ( var i = 0; i < this.num; i ++ ) {
				this.set ( 'latch' + this.indexToPath ( i ), 1 );
				this.latch[i] = 1;
				this.apply ( i, null );
			}
		break;

		case 'rand':
			if ( value ) {
				for ( var i = 0; i < this.num; i ++ ) {
					if ( Math.random () < this.randomChance ) {
						var v = this.randomXOR ? 1 - this.latch[i] : 1;
						this.set ( 'latch' + this.indexToPath ( i ), v );
						if ( v && this.randomApply ) {
							this.apply ( i, null );
						}
					}
				}
			}
		break;

		case 'clear':
			if ( value ) {
				for ( var i = 0; i < this.num; i ++ ) {
					this.set ( 'latch' + this.indexToPath ( i ), 0 );
					this.latch[i] = 0;
				}
			}
		break;

		case 'latch':
			var ind = this.coordToIndex ( pa.slice( 1 ) );
			this.latch[ind] = value;
			if ( value ) {
				this.apply( ind, null );
			}
		break;



		case 'channel':
			var ind = this.latchChannels.indexOf ( pa[1] );
			if ( value ) {
				if ( ind == -1 ) 
					this.latchChannels.push ( pa[1] );
			} else {
				if ( ind != -1 )
					this.latchChannels.splice ( ind, 1 );
			}
		break;

		default:
			//console.log ( 'l', path, value );
		break;
	}
}

Latch.prototype.apply = function ( ind, channel ) {
	var indexes, channels;
	if ( ind != undefined  ) {
		indexes = [ ind ];
	} else {
		indexes = [];
		for ( var i = 0; i < this.num; i ++ ) {
			if ( this.latch[i] )
				indexes.push(i);
		}
	}

	if ( channel != undefined ) {
		channels = [ channel ];
	} else if ( this.allChannels ) {
		channels = this.allChannels;
	} else {
		channels = this.latchChannels;
	}

	

	for ( var ci = 0; ci < channels.length; ci ++ ) {
		var channel = this.channels[channels[ci]];

		if ( !channel )
			continue;

		var v;

		if ( 'function' == typeof channel.source ) {
			v = channel.source;
		} else if ( 'string' == typeof channel.source ) {
			v = this.horten.get ( channel.source );
		} else {
			continue;
		}

		for ( var ii = 0; ii < indexes.length; ii ++ ) {
			var i = indexes[ii];
			var path = this.indexToTarget ( i ) + '/' + ( channel.target || '' );

			if ( 'function' == typeof v ) {
				//console.log ( "Calling to get");
				v = v( path );
			}

			console.log ( 'app', path, v );

			this.horten.set ( path, v );
		}
	}

}

Latch.prototype.indexToTarget = function ( i ) {
	return this.target + i;
}


Latch.prototype.coordToIndex = function ( pa ) {
	console.log ( 'coordToIndex', pa );
	var ret = parseInt( pa[0] ) * this.numPerSlice + parseInt( pa[1] ) - 1 + ( parseInt ( pa[2] ) - 1 )  * this.cols ;
	
	return ret;
	//return  ( x - 1 ) + ( y - 1 ) * this.cols;
}

Latch.prototype.indexToPath = function ( ind ) {
	var slice = Math.floor( ind / this.numPerSlice );
	ind -= slice * this.numPerSlice;



	var ret= '/' + slice + '/' + ( ( ind % this.cols ) + 1 ) + '/' + ( Math.floor ( ind / this.cols ) + 1 );
	console.log ( 'iTp', ind, slice, ret );


	return ret;
}


exports.latch = Latch;