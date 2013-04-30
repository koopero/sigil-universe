var H  = require('horten');
H.instance().debug = true;

var server = new H.Server ( {
	port: 9999,
	websocket: true,
	hostname: '10.4.1.112'
});

var osc = new H.OSC ( {
	server: {
		host: 'localhost',
		port: 8000
	},
	treatAsArray: [],
	autoClient: 9000
});

var camera = new ( require ( './camera.js' ).camera ) () ;

