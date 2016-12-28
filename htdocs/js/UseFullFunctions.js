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

function create_select_list(name, id, list, func, act_table) {
    var sel,prefix,table_id,table_name;
    var i = 0;
    var sortedlist = [];
	
	prefix     = act_table["prefix"];
	table_id   = act_table["id"];
	table_name = act_table["name"];

    sel = document.getElementById(id);
    if (sel == null) {
        sel = document.createElement('select');
        sel.name = name;
        sel.id = id;
    } else {
        document.getElementById(id).innerHTML = "";
    }

    sel.onchange = func;

    for (var idx in list) {
        sel.options[i] = new Option(list[idx][table_name], list[idx][table_name]);
        sel.options[i].value = list[idx][table_id];
        sel.options[i].id = (prefix || "") + list[idx][table_id];

        i++;
    }
    sel.multiple = "multiple";
    return sel;
}

function create_button_as_img(id, func, label, src) {
    var button = document.getElementById(id);
    if (button == null) {
        button = document.createElement('img');
        if (id) {
            button.id = id;
        }
    }
    if (button.src == "") {
        button.src = src;
    }
    button.onclick = func;
    return button;
}

function create_input(input_id) {
    var input = document.createElement("input");
    input.id  = input_id;

    return input;
}

function create_h6(p_data) {
    var p = document.createElement("h6");
    p.id = p_data["id"];
    p.setAttribute("class", p_data["class"]);
    p.innerHTML = p_data['text'];
    return p;
}

function create_li(li_data) {
    var li = document.createElement("li");

    if (li_data['value']) {
        li.value = li_data['value'];
    }

    if (li_data['class']) {
        li.class = li_data['class'];
        li.setAttribute("class", li_data["class"]);
    }
    if (li_data['id']) {
        li.id = li_data['id'];
    }
    if (li_data['function']) {
        li.onclick = link_to_screenshot;
    }

    return li;
}


