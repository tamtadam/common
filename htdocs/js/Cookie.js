function AddCookie(key, value) {

	document.cookie = key + "=" + value;
	return 1;
}

function GetCookie(c_name) {
	var i, x, y, ARRcookies = document.cookie.split(";");
	for (i = 0; i < ARRcookies.length; i+=1) {
		x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
		y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
		x = x.replace(/^\s+|\s+$/g, "");
		if (x == c_name) {
			return unescape(y);
		}
	}
}
function AllCookie() {
   "use strict";

	var i, cookie, name, value, cookies;

   cookies = document.cookie.split(/; /g);

	document.write("<table>");
	
	for (i = 0; i < cookies.length; i+=1) {

		cookie = cookies[i];
		/*
		 * if ( cookie.indexOf("=" == -1 )){ continue ; }
		 */

		name = cookie.substring(0, cookie.indexOf("="));
		value = cookie.substring(cookie.indexOf("=") + 1);
		// document.write( name ) ;
		// document.write( value ) ;
		document.write("<tr><td>" + name + "</td><td>" + unescape(value)
				+ "</td></tr>");
	}
	document.write("</table>");
}

function DeleteCookie(key) {
   "use strict";
	document.cookie = key + "=";
	return 1;
}
function DeletAllCookie() {
   "use strict";

   var i, cookie, name, value, cookies;

   cookies = document.cookie.split(/; /g);

	for (i = 0; i < cookies.length; i+=1 ) {

		cookie = cookies[i];

		name = cookie.substring(0, cookie.indexOf("="));
		value = cookie.substring(cookie.indexOf("=") + 1);
		document.cookie = name + "=";
	}
	// window.location.reload();
	return 1;
}