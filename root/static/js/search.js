var Query = {
	defaultValues: {},

	init: function() {
		var inputs = document.getElementsByTagName('input');
		for (var i = 0; i < inputs.length; i++) {
			var input = inputs[i];
			if (Element.hasClassName(input, "query")) {
				Query.defaultValues[input.id] = input.value;
				addEvent(input, 'onclick', Query.click);
				addEvent(input, 'onblur', Query.blur);
			}
		}
	},
	click: function() {
		Element.addClassName(this, "active");
		if (this.value == Query.defaultValues[this.id]) {
			this.value = '';
		}
	},
	blur: function() {
		if (this.value == '') {
			Element.removeClassName(this, 'active');
			this.value = Query.defaultValues[this.id];
		}
	}
};

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
