var TIMES     = new Array()  ;
var TIMES_MAX = 8            ;

var ERRORS     = new Array()  ;
var ERRORS_MAX = 4            ;

function error_messages_and_server_comm_times( datas )
{
	var p ;
	if( datas[ 'times' ] != null )
	{
	    for ( var cmd in datas['times'] ) {
			if ( TIMES.length >= TIMES_MAX )
			{
				TIMES.shift();
			}
			TIMES.push( cmd + ": " + datas['times'][ cmd ] ) ;
	    }
	}

	if( datas[ 'errors' ] != null )
	{
	    for ( var cmd in datas['errors'] ) {
			if ( ERRORS.length >= ERRORS_MAX )
			{
				ERRORS.shift();
			}
			ERRORS.push( datas['errors'][ cmd ] ) ;
	    }
	}
	
	if( datas != null )
	{
		if(!document.getElementById( "error" )) {
			alert( 'No target for error' );
		}
		document.getElementById( "error" ).innerHTML = "" ;

	    for ( var cmd in TIMES ) {
	   		/*document.getElementById( "error" ).innerHTML = document.getElementById( "error" ).innerHTML + cmd + ":" + TIMES[ cmd ] + "<br>" ;
			$( "#error" ).css( "color", "black" );
			*/
			p = create_h6( { 'id' : 'times' + cmd, 'text' : cmd } );
			p.innerHTML = TIMES[ cmd ] ;
			document.getElementById( "error" ).appendChild( p ) ;
			$( "#" + 'times' + cmd ).css( "color", "black" );
	    }

		for ( var i = 0; i < ERRORS.length; i++  ) {
	   		/*document.getElementById( "error" ).innerHTML = document.getElementById( "error" ).innerHTML +   i + ".:" + ERRORS[ i ] + "<br>" ;
			$( "#error" ).css( "color", "red" );*/
			p = create_h6( { 'id' : 'error_' + i, 'text' : ERRORS[ i ] } );
			p.innerHTML = ERRORS[ i ] ;
			document.getElementById( "error" ).appendChild( p ) ;
			$( "#" + 'error_' + i ).css( "color", "red" );
			
	    }
	}
}

function print_measure( TIMES_ARRAY )
{
    if( document.getElementById('mesure') == null ){
        return ;
    }

    document.getElementById('mesure').innerHTML = "";

    for ( key in TIMES_ARRAY ){
	document.getElementById('mesure').innerHTML += key +" : "+TIMES_ARRAY[key]+" s<br>";
    }

}

function round_it( num1,num2 ){
    return ((num1/num2).toFixed(4))*100 ;
}

function getOS() {
	var userAgent = window.navigator.userAgent,
    platform = window.navigator.platform,
    macosPlatforms = ['Macintosh', 'MacIntel', 'MacPPC', 'Mac68K'],
	windowsPlatforms = ['Win32', 'Win64', 'Windows', 'WinCE'],
	iosPlatforms = ['iPhone', 'iPad', 'iPod'],
	os = null;
	
	if (macosPlatforms.indexOf(platform) !== -1) {
		os = 'Mac OS';
	} else if (iosPlatforms.indexOf(platform) !== -1) {
		os = 'iOS';
	} else if (windowsPlatforms.indexOf(platform) !== -1) {
		os = 'Windows';
	} else if (/Android/.test(userAgent)) {
		os = 'Android';
	} else if (!os && /Linux/.test(platform)) {
		os = 'Linux';
	}

    return os;
}
