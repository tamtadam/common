var $        = require('.\\lib\\jquery')

function substitute( string, variables ) {
	return string.replace(/\$([1-9])\d*/g, function (match, index) {
//		console.log('match:' + match + ' index:' + index);
		return JSON.stringify( variables[ index ] )
	})
}

module.exports = {
	evaluate: function ( expression ) {
//		console.log('CMD generated: ' + expression + " - " + JSON.stringify(arguments, undefined, 4));
		var _arguments = arguments;
		console.log('    ' + substitute(expression, _arguments));
		return function (p) {
			p.page.evaluate('function () { return ' + substitute(expression, _arguments ) + '; }' );
			return p
		}
	}	
}