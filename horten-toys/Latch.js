var http = require('http');

var Horten = require ( 'horten' ).Horten;
var H = Horten;

function Latch ( config ){
	var that = this;

	H.Listener.call( this, config, this.onData );
	this.primitive = true;
	this.attach ();

	this.cols = 4;



	this.channels = config.channels;
	this.target = H.Path ( config.target );

	this.num = 12;

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
			var channelListener = new H.Listener ( { path: channel.source, prefix: k }, function ( value, path ) {
				that.onChannelData( value, path );
			} );
			this.listeners.push ( channelListener );
		}

		if ( this.allChannels != undefined )
			this.allChannels.push( k );
	}
}

Latch.prototype = new H.Listener ( null );

Latch.prototype.onChannelData = function ( value, path ) {
	
	var pa = H.Path ( path ).array;
	//console.log ( 'onCd', pa[0],this.latchChannels );
	if ( this.allChannels || this.latchChannels.indexOf ( pa[0] ) != -1 ) {
		var channel = this.channels[pa[0]];

		if ( !channel.onlyOnHigh || value )
			this.apply ( null, pa[0] );
	}
	
}

Latch.prototype.onData = function ( value, path ) {
	
	//console.log ( "LATCH", path, value );

	var pa = H.Path ( path ).array;

	switch ( pa[0] ) {
		case 'all':

			for ( var i = 0; i < this.num; i ++ ) {
				this.set ( 1, 'latch' + this.indexToPath ( i ) );
				this.latch[i] = 1;
				this.apply ( i, null );
			}
		break;

		case 'rand':
			if ( value ) {
				for ( var i = 0; i < this.num; i ++ ) {
					if ( Math.random () < this.randomChance ) {
						var v = this.randomXOR ? 1 - this.latch[i] : 1;
						this.set ( v, 'latch' + this.indexToPath ( i ) );
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
					this.set ( 0, 'latch' + this.indexToPath ( i ) );
					this.latch[i] = 0;
				}
			}
		break;

		case 'latch':

			var ind = this.coordToIndex ( pa.slice( 1 ) );
			//console.log ( "onLatch", ind );
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

			//console.log ( 'app', path, v );

			this.horten.set ( v, path );
		}
	}

}

Latch.prototype.indexToTarget = function ( i ) {
	return this.target + i;
}


Latch.prototype.coordToIndex = function ( pa ) {
	//console.log ( 'coordToIndex', pa );
	var ret = parseInt( pa[0] ) - 1 + ( parseInt ( pa[1] ) - 1 )  * this.cols ;
	
	return ret;
	//return  ( x - 1 ) + ( y - 1 ) * this.cols;
}

Latch.prototype.indexToPath = function ( ind ) {

	var ret=  '/' + ( ( ind % this.cols ) + 1 ) + '/' + ( Math.floor ( ind / this.cols ) + 1 );
	//console.log ( 'iTp', ind, ret );


	return ret;
}


exports.latch = Latch;