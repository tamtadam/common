var TIMES     = new Array()  ;
var TIMES_MAX = 8            ;

var ERRORS     = new Array()  ;
var ERRORS_MAX = 4            ;

function msg ( content ) {
	if( typeof( dialog ) != 'undefined' ) {
		$('#message_box p').html( content ? content : 'Töltés....');
		dialog.dialog( "open" );
	}
}


function add_extra_accordion (target, title, content) {
    var newDiv = "<div><h3>" + title + "</h3><div>" + $(content).html() + "</div></div>";
    target.append(newDiv)
    target.accordion("refresh");
}


function sortObj(arr){
    var sortedKeys = new Array();
    var sortedObj = {};

    for (var i in arr){
        sortedKeys.push(i);
    }
    sortedKeys.sort();

    for (var i in sortedKeys){
        sortedObj[sortedKeys[i]] = arr[sortedKeys[i]];
    }

    return sortedObj;

}

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
		if(ERRORS.length > 0 ) {
	        $('#error').dialog({
		        width: 500,
		        title: 'List of errors!',
		        height: 150,
		        position: [600, 600],
		        buttons:
		        {
		            "Close": {
		            	text: 'Close',
		                click: function() {
		                    $(this).dialog("close");
		                }
		            }
		        }
		    });			
		}

	}
}

function getParameterByName(name)
{
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(window.location.href);
    if(results == null)
    return "";
    else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
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

function CreateLimitStruct( step ) {
	var type_l = step[ 'type' ] ;

	if ( step[ 'step' ] ) {
		message_pager[ type_l ][ 'limit_min' ] += step[ 'step' ] ;
		message_pager[ type_l ][ 'limit_min' ] < 0 ? message_pager[ type_l ][ 'limit_min' ] = 0 : 0;
		step[ 'step' ] < 0 ? --message_pager[ type_l ][ 'page_num' ] : ++message_pager[ type_l ][ 'page_num' ];
		if (message_pager[ type_l ][ 'page_num' ] < 1) {
			message_pager[ type_l ][ 'page_num' ] = 1;
		}
		message_pager[ type_l ][ 'step' ] = step[ 'step' ];
	}
		
	var sendXMLStrings = {
		'limit_min'    : message_pager[ type_l ][ 'limit_min' ]  ,
		'limit_offset' : message_pager[ type_l ][ 'limit_offset' ] ,
	};
	if( step[ 'json' ] == 1 ){
	    return JSON.stringify(sendXMLStrings);	
    } else {
	    return sendXMLStrings;
    }
}

function show_hour(){
    var Digital=new Date();
    var hours=Digital.getHours();
    var minutes=Digital.getMinutes();
    //var time_p = $("#time_pick");
    //time_p.val( hours + ":" + minutes );
    setTimeout("show_hour()",600000) ;
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
//TODO name felesleges
function create_select_list(id, list, func, select_params,option_params) {
    var sel,prefix,table_id,table_name;
    var i = 0;
    var sortedlist = [];
	
	//prefix     = act_table["prefix"];
	//table_id   = act_table["id"];
	//table_name = act_table["name"];

    sel = document.getElementById(id);
    if (sel == null) {
        sel = document.createElement('ul');
        sel.id = id;
    } else {
        document.getElementById(id).innerHTML = "";
    }

    $.each(select_params, function(k,v){ sel[k] = v});

    for (var idx in list) {
    	var li = document.createElement('li');
    	var a = document.createElement('a');
    	a.href = "#";
    	a.innerHTML = list[idx]["Title"];
    	
    	
        $(li).data('data', list[idx]);

        $.each(option_params, function(k,v){ li[k] = v});

        if(list[idx].Cnt==0){
        	$(li).addClass("disabled");
        }

        li.appendChild(a);
        li.onclick = func;

        sel.appendChild(li);
        i++;
    }
    return sel;
}

function create_select_list_native(name, id, list, func, act_table, select_params) {
    var sel,prefix,table_id,table_name;
    var i = 0;
    var sortedlist = [];
	
	prefix     = act_table["prefix"];
	table_id   = act_table["id"];
	table_name = act_table["name"];

    sel = document.getElementById(id);
    if (sel == null) {
        sel = document.createElement('select');
        sel.id = id;
    } else {
        document.getElementById(id).innerHTML = "";
    }

    $.each(select_params, function(k,v){ sel[k] = v});

    sel.onchange = func;

    for (var idx in list) {
        sel.options[i] = new Option(list[idx][table_name], list[idx][table_name]);
        sel.options[i].value = list[idx][table_id];
        sel.options[i].id = (prefix || "") + list[idx][table_id];
        $(sel.options[i]).data('data', list[idx]);

        i++;
    }
    return sel;
}

function create_list_group(id, list, func, select_params,option_params) {
    var sel,prefix,table_id,table_name;
    var i = 0;
    var sortedlist = [];
	
    sel = document.getElementById(id);
    if (sel == null) {
        sel = document.createElement('ul');
        sel.id = id;
    } else {
        document.getElementById(id).innerHTML = "";
    }

    $.each(select_params, function(k,v){ $(sel).prop(k, v)});

    for (var idx in list) {
    	var li = document.createElement('a');
    	li.innerHTML = list[idx]["Title"];
    	
        $(li).data('data', list[idx]);

        $.each(option_params, function(k,v){ $(li).prop(k, v)});

        if(list[idx].Cnt==0){
        	$(li).addClass("disabled");
        }
        li.onclick = func;

        sel.appendChild(li);
        i++;
    }
    $(sel).sortable();
    return sel;
}

function create_button_as_img(id, func, label, src, par) {
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
//    button.addEventListener("click", function(){
//        func(par);
//    }, false);

    return button;
}

function create_button(btn_id,func,params,html_fwork) {
    var button = document.getElementById(btn_id);
    if (button == null) {
        button = document.createElement('button');
        if (btn_id) {
            button.id = btn_id;
        }
    }
	
    $.each(params, function(k,v){ button[k] = v});

    if(html_fwork != null){
        if(html_fwork==="jquery"){
        	$("#" + btn_id).button();
        } else if(html_fwork==="bootstrap"){
        	
        }    	
    }
    button.onclick = func;
//    button.addEventListener("click", function(){
//        func(params);
//    }, false);

    return button;	
}

function create_input(input_id) {
    var input = document.createElement("input");
    input.id  = input_id;

    return input;
}

function create_a(a_params) {
    var a = document.createElement('a');
    $.each(a_params, function(k,v){ $(a).prop(k, v) });
    return a;
}

function create_h6(p_data) {
    var p = document.createElement("h6");
    p.id = p_data["id"];
    p.setAttribute("class", p_data["class"]);
    p.innerHTML = p_data['text'];
    return p;
}

function create_span(p_data) {
    var p = document.createElement("span");
    p.id = p_data["id"];
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



