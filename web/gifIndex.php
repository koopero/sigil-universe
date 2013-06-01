<?php

	$config = json_decode( file_get_contents( "../config.json" ) );

	$index = $config->watershed->root . $config->watershed->gifIndex;

	$index = file_get_contents ( $index );
	$index = json_decode( $index );

	$root = $index->root;

	$ret = array ();

	foreach ( $index->listing as $in ) {
		if ( $in->type == 'dir' )
			continue;

		list ( $orbit, $day, $file ) = explode ( '/', $in->path );
		list ( $time, $gif) = explode ( '.', $file );

		$out = array (
			'gif'=>$in->url,
			'seq'=>$root.'orbit/orbit/'.$day.'/'.$time.'/',
			'page'=>$config->web->root.$config->web->viewer.$day.$time,
			'frameThree'=>$root.'orbit/orbit/'.$day.'/'.$time.'/3.jpg',
		);



		$ret[] = $out;
	}

	//var_dump ( $ret );
	//var_dump ( $index );

	header( "Content-Type: application/json" );
	echo json_encode( $ret );
