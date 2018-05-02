var asyncLoop = require('.\\asyncLoop').asyncLoop
var action = require('.\\actions')

function runTest(test, onDone) {
	var features = []
	
	test(function (featureDesc, featureBuilder) {
		features.push({
			desc   : featureDesc,
			builder: featureBuilder
		})
	})
	
	
	asyncLoop(features, function(feature, featuresLoop, featureIndex){
		console.log( ( featureIndex + 1 ) + '. feature:' + feature.desc + '\n===' )
		
		var scenarios = []
		
		feature.builder ( function( scenarioDesc, scenarioBuilder ) {
			scenarios.push({
				desc    : scenarioDesc,
				builder : scenarioBuilder
			})
		})
		
		asyncLoop(scenarios, function( scenario, scenariosLoop, scenarioIndex) {
			console.log( (scenarioIndex + 1 ) + '. scenario: ' + scenario.desc + '\n---')

			scenario.builder().then(function ( result ) {
				console.log( ( result ? '    **Scenario steps are ready for execution' : 'FAIL') + '\n' );
			
				if ( result ) {
					function caller() {
						var startTime = Date.now();
						setTimeout(function(){
							
							if( action.scenarioIsOngoing() ) {
								caller();
							} else {
								action.getStat();
								scenariosLoop.next();
							}
						}, 1000);
					}
					caller();
				} else {
					scenariosLoop._break()
				}
			}, function (error) {
				console.log( error + '\nFAIL\n')
				scenariosLoop._break()
			});
		}, function () {
			console.log('Feature end, start the next one')
			_pageCache = {};
			action.render();
			action.closeBrowser();
			featuresLoop.next();
		})
	}, onDone)
}

var tests = [
	'test'
];

asyncLoop( tests, function (test, testLoop) {
	runTest( (require('f:\\GIT\\gherkin_editor\\test\\system\\' + test ) ).test, function(){
		testLoop.next()
	})
}, function () {
	window.setTimeout(function () {
		console.log('END of the execution');
		phantom.exit;
	}, 2000);
})
