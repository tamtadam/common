module.exports = {
	asyncLoop: function (array, callback, onDone) {
		var done = false;
		var index = 0;
		var loop = {
			next: function () {
				if( done ) {
					return;
				}
				if( index < array.length ) {
					callback(array[index], loop, index++);
					
				} else {
					loop._break();
				}
			},
			
			_break: function () {
				done = true;
				onDone();
			}
		}
		
		loop.next();
	}	
}