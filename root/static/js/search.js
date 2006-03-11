/*
 * Clear the default value of any input fields with class "query" when
 * clicked.
 */
var Query = {
	defaultValues: {},

	setDefaultValue: function(key, value) {
		Query.defaultValues[key] = value;
	},
	getDefaultValue: function(key) {
		return Query.defaultValues[key];
	},
	init: function() {
		var inputs = document.getElementsByTagName('input');
		for (var i = 0; i < inputs.length; i++) {
			var input = inputs[i];
			if (Element.hasClassName(input, 'query')) {
				// Let page override value
				if (Query.getDefaultValue(input.id) == null) {
					Query.setDefaultValue(input.id, input.defaultValue);
				}

				addEvent(input, 'onfocus', function() { Query.activate(this) });
				addEvent(input, 'onblur', function() { Query.deactivate(this) });

				if (input.value != Query.getDefaultValue(input.id)) {
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
