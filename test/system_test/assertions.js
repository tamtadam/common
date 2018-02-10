var evaluate = require('.\\evaluation').evaluate

module.exports = {
	assertValue: function(selector, value) {
		return evaluate('assertValue($1,$2)', selector, value)
	},
	
	assertElement: function(selector) {
		return evaluate('assertElement($1)', selector)
	},	

	assertContents: function(selector, contents) {
		return evaluate('assertContents($1,$2)', selector, contents)
	},	

	assertContaining: function(selector, contents) {
		return evaluate('assertContaining($1,$2)', selector, contents)
	},	

	assertOption: function(selector, option) {
		return evaluate('assertOption($1,$2)', selector, option)
	},	
	
	assertOptions: function(selector, options) {
		return evaluate('assertOptions($1,$2)', selector, options)
	},	
	
	selectList: function(selector, options) {
		return evaluate('selectList($1,$2)', selector, options)
	},	

	assertLabel: function(selector, label) {
		return evaluate('assertLabel($1,$2)', selector, label)
	},	

	assertDisplayed: function(selector) {
		return evaluate('assertDisplayed($1)', selector)
	},	

	assertNotDisplayed: function(selector) {
		return evaluate('assertNotDisplayed($1)', selector)
	},	
}