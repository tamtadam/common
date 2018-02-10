var webpage  = require('webpage')
var $        = require('.\\lib\\jquery')
var Promise  = require('.\\lib\\bluebird')
var evaluate = require('.\\evaluation').evaluate

var _pageCache = {}
var logEnabled = 1
var ongoingRequests = [];
var pagePH;

var actPage = ""
var doLog = true;

module.exports = {
	open: function(url, reload){
		return new Promise( function( resolve, reject ){
			if( !reload && (pagePH = _pageCache[ url ] ) ){
				pagePH.evaluate(function(){
					scenarioOngoing = 1;
				});
				resolve( { page : pagePH, requests : ongoingRequests } );
				
				return;
			}
			
			if( pagePH ) {
				pagePH.close();
			}
			
			pagePH = webpage.create();
			
			pagePH.onNavigationRequested = function( url, type, willNavigate, main){
				
			}
			pagePH.onConsoleMessage = function(msg, lineNum, sourceId) {
				//console.log('CONSOLE: ' + msg + ' (from line #' + lineNum + ' in "' + sourceId + '")');
			};
			pagePH.viewportSize = {
				width: 1920,
				height: 1280,
				navigationLocked: true,
			}
			
			pagePH.onResourceRequested = function ( request, networkRequest ) {
				if (request.url === url && actPage === url ) {
					console.log(' rEQUEST WILL BE ABORTED: ' + request.url)
					networkRequest.abort();
				}
				
				if( request.url.match( 'cgi' ) ) {
					
				}
				
				ongoingRequests.push({
					url : request.url,
					id  : request.id,
				});
			};
			
			pagePH.onResourceReceived = function( message ) {
				if( message.url.match('cgi') ) {
					
				}
				var index = $.map( ongoingRequests, function(n, i) { return n.url; } ).indexOf(message.url);
				
				if( index > -1 ) {
					ongoingRequests.splice( index, 1 );
				}
			}
			
			pagePH.onResourceError = function ( message ) {
				console.log( message.errorString );
			}
			
			pagePH.onAlert = function (msg) {
				console.log( 'ALERT: ' + msg )
			}
			
			pagePH.onResourceTimeout = function( request ) {
				console.log('Response TIMEOUT (#' + request.id + '): ' + JSON.stringify( request ) );
			}
			
			var startTime = Date.now();
			
			console.log( '    Opening ' + url + '...');
			actPage = "";
			
			pagePH.open(url, function( status ){
				if ( status === 'success' ) {
					actPage = url;
					console.log('    success in ' + ((Date.now() - startTime) / 1000) + ' second' );
					_pageCache[url] = pagePH;
					
					if( pagePH.injectJs( 'main.js' ) ) {
						pagePH.evaluate(function(){
							scenarioOngoing = 1;
						})
						resolve( { page : pagePH, requests : ongoingRequests } );

					} else {
						reject('Cannot inject main.js');
					}
					
				} else {
					reject('Cannot open ' + url)
				}
			})
		})
	},
		
	render: function (p) {
		var timeStamp = Date.now();
		console.log('    Rendering into ' + timeStamp + '.png...')

		if( p && p.page ) {
			p.page.render('screenshots\\' + timeStamp + '.png')
			return p
			
		} else {
			pagePH.render('screenshots\\' + timeStamp + '.png')
			return true
		}
	},
	
	getStat: function() {
		var res = pagePH.evaluate(function(){
			return commandQueue;
		});
		$.each( res, function(i, n){
			console.log('Step' + n.step + '. : ' + n.condition + ' - ' + n.status)
		});
	},
	
	
	closeBrowser: function () {
		if( pagePH ) {
			pagePH.close();
			pagePH = null;
			_pageCache = {};
		}
	},
	
	scenarioIsOngoing: function ( p ) {
		var page;
		if ( p && p.page ) {
			page = p.page;
		} else {
			page = pagePH;
		}
		
		return page.evaluate(function(){
			return scenarioOngoing
		});
	},
	
	waitForResource: function( p, url, timeout ) {
		if( p.page ) {
			timeout = timeout || 10000
			console.log('Wait for resource:' + url )
			var startTime = new Date.getTime();
			while( $.grep( p.requests, function( n, i ){ return n.url.match( url ) } ).length > 0 ) {
				var now = new Date.getTime()
				if( ( now - startTime ) > timeout ) {
					console.log( 'No response in ' + timeout/1000 + ' sec ' + ( now - startTime ) )
					return p;
				}
			}
			return p
		}
	},
	
	fill: function ( selector, value ) {
		return evaluate('fill($1,$2)', selector, value)
		
	},
	
	click: function ( selector ) {
		return evaluate('click($1)', selector)
	},	
	
	leftClick: function ( selector ) {
		return evaluate('leftClick($1)', selector)
	},
	
	triggerEvent: function ( selector, event ) {
		return evaluate('triggerEvent($1,$2)', selector, event)
	},	

	scenarioEnd: function ( selector ) {
		return evaluate('scenarioEnd($1)', selector)
	},	
	
	clickItemInSelectList: function ( selector, item ) {
		return evaluate('clickItemInSelectList($1,$2)', selector, item)
	},

	clickItemInSelectListAfter: function ( selector, item, condition ) {
		if( !condition ) {
			condition = selector;
		}
		return evaluate('clickItemInSelectListAfter($1, $2, $3)', selector, item, condition)
	},

	justWait: function ( ms ) {
		return evaluate('justWait($1)', ms)
	},
	
	getHtml: function ( selector ) {
		return evaluate('getHtml($1)', selector)
	},
	
	wait: function ( ms ) {
		return evaluate('wait($1)', ms)
	},
	
	chooseOption: function ( selector, option ) {
		return evaluate('chooseOption($1, $2)', selector, option )
	},
	
	myconsole: function ( p, text ) {
		evaluate('myconsole($1)', text )
		return p
	},	
}