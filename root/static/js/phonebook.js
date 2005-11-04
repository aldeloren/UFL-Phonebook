/*
 * Query should be defined inline (defaultValue from configuration)
 */
if (! Query) {
	var Query = {
		defaultValue: ''
	};
}

Query.init = function() {
	var query = $('query');
	if (query) {
		addEvent(query, 'onclick', Query.click);
		addEvent(query, 'onblur', Query.blur);
		Field.activate(query);
	}
}

Query.click = function() {
	var query = $('query');
	if (query.value == this.defaultValue) {
		query.value = '';
	}
}

Query.blur = function() {
	var query = $('query');
	if (query.value == '') {
		query.value = this.defaultValue;
	}
}

var Source = {
	init: function() {
		var source = $('source');
		if (source) {
			addEvent(source, 'onchange', Source.change);
		}
	},
	change: function() {
		var query = $('query');
		Field.activate(query);
	}
};

addEvent(window, 'onload', Query.init);
addEvent(window, 'onload', Source.init);
