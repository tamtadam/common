function push_cmd(key, value) {
	PROC_ARRAY[key] = value;

}

function send_cmd( async_ ) {
	console.log( PROC_ARRAY );

	result = AJAX_req({
			'url' : '/cgi-bin/' + CGI_PATH + '/' + CGI_SCRIPT,
			'data' : PROC_ARRAY
		},
		async_
	);
	PROC_ARRAY = new Object();
	return result;
}

function processor(data_to_process) {
	console.log( data_to_process ) ;
    if(  data_to_process != null && data_to_process[ 'errors' ] && data_to_process[ 'time' ] )
    {
	   	error_messages_and_server_comm_times( {
			'errors'  : data_to_process[ 'errors' ],
			'times'   : data_to_process[ 'time' ]  ,
		} );
    }
    if ( data_to_process != null && data_to_process != null && data_to_process[ 'time' ] ){
    	print_measure( data_to_process[ 'time' ] ) ;
        for ( var cmd in data_to_process) {
        	if ( FUNCTIONS && FUNCTIONS[ cmd ] ) {
            	FUNCTIONS[ cmd ]( data_to_process[cmd] ) ;
        	}
    	}
    }
    return data_to_process ;
}


