/*
 * Clear the default value of any input fields with class "query" when
 * clicked.
 */
var Query = {
	defaultValues: {},

	setDefaultValue: function(key, value) {
		// Let page override value from init
		if (Query.defaultValues[key] == null) {
			Query.defaultValues[key] = value;
		}
	},
	getDefaultValue: function(key) {
		return Query.defaultValues[key];
	},
	init: function() {
		var inputs = document.getElementsByTagName('input');
		for (var i = 0; i < inputs.length; i++) {
			var input = inputs[i];
			if (Element.hasClassName(input, 'query')) {
				Query.setDefaultValue(input.id, input.value);
				addEvent(input, 'onfocus', Query.focus);
				addEvent(input, 'onblur', Query.blur);

				if (input.value != Query.getDefaultValue(input.id)) {
					Element.addClassName(input, 'active');
				}
			}
		}
	},
	focus: function() {
		Element.addClassName(this, 'active');
		if (this.value == Query.getDefaultValue(this.id)) {
			this.value = '';
		}
	},
	blur: function() {
		if (this.value == '') {
			Element.removeClassName(this, 'active');
			this.value = Query.getDefaultValue(this.id);
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
