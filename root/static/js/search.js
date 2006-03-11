/*
 * Clear the default value of any input fields with class "query" when
 * clicked.
 */
var Query = {
	defaultValues: {},

	setDefaultValue: function(input, value) {
		Query.defaultValues[input.id] = value;
	},
	getDefaultValue: function(input) {
		return Query.defaultValues[input.id];
	},
	init: function() {
		var inputs = document.getElementsByTagName('input');
		for (var i = 0; i < inputs.length; i++) {
			var input = inputs[i];
			if (Element.hasClassName(input, 'query')) {
				// Let page override value
				if (Query.getDefaultValue(input) == null) {
					Query.setDefaultValue(input, input.defaultValue);
				}

				addEvent(input, 'onfocus', function() { Query.activate(this) });
				addEvent(input, 'onblur', function() { Query.deactivate(this) });

				if (input.value != Query.getDefaultValue(input)) {
					Query.activate(input);
				}
			}
		}
	},
	activate: function(field) {
		Element.addClassName(field, 'active');
		if (field.value == Query.getDefaultValue(field.id)) {
			field.value = '';
		}
	},
	deactivate: function(field) {
		if (field.value == '') {
			Element.removeClassName(field, 'active');
			field.value = Query.getDefaultValue(field.id);
		}
	}
};

/*
 * Automatically select the first input field with class "query" in
 * the form containing a "source" select menu.
 */
var Source = {
	init: function() {
		var source = $('source');
		if (source) {
			addEvent(source, 'onchange', Source.change);
		}
	},
	change: function() {
		var inputs = this.form.getElementsByTagName('input');
		for (var i = 0; i < inputs.length; i++) {
			var input = inputs[i];
			if (Element.hasClassName(input, 'query')) {
				Field.activate(input);
				break;
			}
		}
	}
};

addEvent(window, 'onload', Query.init);
addEvent(window, 'onload', Source.init);
