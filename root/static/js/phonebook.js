/*
 * Query is defined inline (defaultValue from app config)
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
	if (query.value == Query.defaultValue) {
		query.value = '';
	}
}

Query.blur = function() {
	var query = $('query');
	if (query.value == '') {
		query.value = Query.defaultValue;
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
