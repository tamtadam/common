var commandQueue = new Array();
var scenarioOngoing = 0;

function fill ( selector, value ) {
	executeAfter(selector, function(){
		var $control = $( selector )
		
		if ($control.length > 0) {
			$control.val( value );
			$control.trigger('change');
			$control.trigger('keydown');
			$control.trigger('input');
			$control.trigger('blur');
			return true;
		} else {
			return false;
		}
	});
	
	return true;
}


function click ( selector ) {
	return triggerEvent( selector, 'click' );
}

function triggerEvent (selector, event) {
	executeAfter(selector, function () {
		$( selector ).trigger(event);
		return $( selector );
	});
	return true
}

function leftClick( selector ) {
	executeAfter(selector, function(){
		$($selector).trigger({
			type : 'mousedown',
			which: 1
		});
		return true;
	})
}

function clickItemInSelectList ( selector, item ) {
	executeAfter(selector, function(){
		if(0) {
			$(selector).filter( function(n, i){ return i.value.match( item)} ).prop('selected', true).trigger('change')
			$(selector).filter( function(n, i){ return i.value.match( item)} ).prop('selected', true).trigger('click')		
			
			$(selector).filter( function(n, i){ return !i.value.match( item)} ).prop('selected', false).trigger('change')
			$(selector).filter( function(n, i){ return !i.value.match( item)} ).prop('selected', false).trigger('click')	
			
			$(selector).filter( function(n, i){ return i.innerHTML.match( item)} ).prop('selected', true).trigger('change')
			$(selector).filter( function(n, i){ return i.innerHTML.match( item)} ).prop('selected', true).trigger('click')	
			
		} else {
			$(selector).filter( function(n, i){ return $(i).html().match( item)} ).prop('selected', true).trigger('change')
			$(selector).filter( function(n, i){ return $(i).html().match( item)} ).prop('selected', true).trigger('click')	
		}

		return true;
	})
	return true
}

var index = 0;

function executeAfter (condition, callF, ms) {
	var timeout = ms || 30000;
	commandQueue.push({
		'condition' : condition,
		'func'      : callF,
		'timeout'   : timeout,
		'step'      : commandQueue.length,
		'status'    : 'FAILED',
		'freerun'   : 30,
		'ongoing'   : 0,
		'start'     : 0,
	});
	return true;
}


function nbWait() {

	if( commandQueue.length > 0 && index < commandQueue.length ) {
		var _condition = commandQueue[ index ].condition
		var _func      = commandQueue[ index ].func
		
		if( !commandQueue[ index ].start ) {
			commandQueue,start = Date.now()
		}
		
		if( !commandQueue[ index ].ongoing && assertElement( _condition ) && _func() ) {
			commandQueue[ index ].ongoing = 1;
			commandQueue[ index ].status  = "PASSED";
			
			index++;
			
		} else if ( commandQueue[ index ].start + commandQueue[ index ].timeout <= Date.now() ) {
			commandQueue[ index ].status = "FAILED";
			
			index++;
		}
	}
};

setInterval( function(){
	nbWait();
}, 250)

function scenarioEnd() {
	executeAfter('body', function(){
		scenarioOngoing = 0;
		return true;
	})
	
	return true;
}

function assertValue(selector, value) {
	executeAfter(selector, function(){
		var html = $(selector).html();
		var val  = $(selector).val();
		
		return ( val || html ? val === value || html === value : false );
	})
	
	return true;
}

function getHtml(selector) {
	executeAfter(selector, function(){
		console.log( $(selector).html() );
		console.log( $(selector).get(0).innerHTML );
	});
	
	return true;
}

function assertDisplayed(selector) {
	executeAfter(selector, function(){
		var disp = $(selector).css('display');
		return (disp == 'none' ? 0 : 1 );
	});
	
	return true;
}

function assertNotDisplayed(selector) {
	executeAfter(selector, function(){
		var disp = $(selector).css('display');
		return (disp == 'none' ? 1 : 0 );
	});
	
	return true;
}

function assertElement(selector) {
	return $(selector).length > 0
}

function assertElement(selector) {
	return $(selector).length > 0
}

function assertContaining(selector, string) {
	executeAfter(selector, function(){
		return ( $(selector).get(0).innerHTML.indexOf(string) > -1)
	});
	return true;
}

function assertOptions(selector, options) {
	executeAfter(selector, function(){
		var control  = $(selector);
		var options2 = control.map(function(){ return this.innerText }).get();
		return options2.filter(function(option){ return options.indexOf(option) > -1}).length == options.length
	})
	return true;
}

function selectList(selector, options) {
	executeAfter(selector, function(){
		var control  = $(selector);
		var options2 = control.map(function(){ return this.innerHTML }).get();
		return options2.filter(function(option){ return options.indexOf(option) > -1}).length == options.length
	})
	return true;
}
