var H  = require('horten');
var config = require('../config.js');

H.instance().debug = true;

var server = new H.Server ( {
	port: config.camera.http,
	websocket: true,
	hostname: config.camera.host
});

var osc = new H.OSC ( {
	server: {
		host: 'localhost',
		port: config.camera.osc
	},
	treatAsArray: [],
	autoClient: 9000
});

var camera = new ( require ( './camera.js' ).camera ) () ;

