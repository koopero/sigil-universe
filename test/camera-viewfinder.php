<?php

?>
<html>
<head>
<title>Orbit Viewfinder</title>
<script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
<script src='http://10.4.1.112:9999/camera/?js=true'></script>
<script>
	H.instance().debug = true;

	var image = new H.Listener ( 
		{
			path: '/viewfinder',
			primitive: true 
		},
		function ( value, path ) {
			console.log ( "VF", path, value );
			if ( path.startsWith( '/test' ) ) {
				$('#viewfinder').attr('src', value );
			}
		} 
	);

	new H.Listener( '/', function ( value, path ) {
		console.log ( "GENERIC LISTENER", path.string, value );
	});
</script>
</head>
<body>
<img id='viewfinder'/>
</body>
</html>