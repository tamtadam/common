var action = require('..\\actions')
var assert = require('..\\assertions')

var URL = 'http://localhost/gherkin_editor/index.html';

module.exports = {
	test: function (feature) {
		feature('Example usage', function (scenario) {
			scenario('fill', function() {
				return action.open(URL)
					.then(action.fill('#username', 'trenyik'))
					.then(action.fill('#password', 'alma'))
					.then(action.click('#login'))
					.then(assert.assertDisplayed('#feature_list'))
					.then(action.scenarioEnd(''))
			})
		})
	}
}