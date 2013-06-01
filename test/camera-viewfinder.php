<?php
	$config = json_decode( file_get_contents( "../config.json" ) );
?>
<html>
<head>
<title>Orbit Viewfinder</title>
<script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
<script src='http://10.4.1.40:1337/camera/?js=true'></script>
<script>
	H.instance().debug = true;

	var image = new H.Listener ( 
		{
			path: '/viewfinder/url'
		},
		function ( value, path ) {
			$('#viewfinder').attr('src', value );
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