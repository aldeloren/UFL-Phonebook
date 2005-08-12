/*
 * Many of the following ideas are borrowed from Prototype
 * (http://prototype.conio.net/). However, we maintain compatibility with
 * Internet Explorer 5.
 */

/*
 * Add a function to the <code>window.onload</code> event.
 * Based on http://simon.incutio.com/archive/2004/05/26/addLoadEvent
 */
function addLoadEvent(f) {
	var old = window.onload;
	if (typeof window.onload != "function") {
		window.onload = f;
	}
	else {
		window.onload = function() {
			old();
			f();
		}
	}
}

/*
 * Return the element with the specified ID. Similar to Prototype's $ function,
 * but it only returns one element.
 */
function $(id) {
	var element = id;

	if (typeof element == "string") {
		if (document.getElementById != null) {
			element = document.getElementById(id);
		}
		else if (document.all != null) {
			element = document.all[id];
		}
	}

	return element;
}

if (! Array.prototype.push) {
	Array.prototype.push = function() {
		var startLength = this.length;
		for (var i = 0; i < arguments.length; i++) {
			this[startLength + i] = arguments[i];
		}
		return this.length;
	}
}

/*
 * Trim whitespace from the left and right sides of this string.
 */
String.prototype.trim = function() {
	var str = this;

	while (str.substr(0, 1) == " ") {
		str = str.substr(1, str.length);
	}
	while (str.substr(str.length - 1, str.length) == " ") {
		str = str.substr(0, str.length - 1);
	}

	return str;
}

if (! window.Element) {
	var Element = new Object();
}

Element.toggle = function() {
	for (var i = 0; i < arguments.length; i++) {
		var element = $(arguments[i]);
		Element.hidden(element) ? Element.show(element) : Element.hide(element);
	}
}

Element.hide = function() {
	for (var i = 0; i < arguments.length; i++) {
		var element = $(arguments[i]);
		element.style.display = "none";
	}
}

Element.show = function() {
	for (var i = 0; i < arguments.length; i++) {
		var element = $(arguments[i]);
		element.style.display = "block";
	}
}

/*
 * Determine if the specified elements are hidden.
 * From http://svn.pythonpaste.org/Paste/trunk/examples/filebrowser/js-lib/common.js
 */
Element.hidden = function() {
	for (var i = 0; i < arguments.length; i++) {
		var element = $(arguments[i]);
		if (element.style.display != "none") {
			return false;
		}
	}
	return true;
}

Element.hasClassName = function(element, className) {
	element = $(element);
	if (! element) {
		return;
	}
	var a = element.className.split(" ");
	for (var i = 0; i < a.length; i++) {
		if (a[i] == className) {
			return true;
		}
	}
	return false;
}

Element.addClassName = function(element, className) {
	element = $(element);
	Element.removeClassName(element, className);
	element.className += " " + className;
}

Element.removeClassName = function(element, className) {
	element = $(element);
	if (! element) {
		return;
	}
	var newClassName = "";
	var a = element.className.split(" ");
	for (var i = 0; i < a.length; i++) {
		if (a[i] != className) {
			if (i > 0) {
				newClassName += " ";
			}
			newClassName += a[i];
		}
	}
	element.className = newClassName;
}

Element.remove = function(element) {
	element = $(element);
	element.parentNode.removeChild(element);
}

/*
 * Remove child nodes with the specified name from the specified element,
 * returning the number of nodes removed.
 */
Element.removeChildren = function(element, name) {
	var children = $(element).getElementsByTagName(name);
	var count = 0;
	if (children.length > 0) {
		for (var i = 0; i < children.length; i++) {
			children[i].parentNode.removeChild(children[i]);
			++count;
		}
	}
	return count;
}

var Form = {
	disable: function(frm) {
		for (var i = 0; i < frm.elements.length; i++) {
			var element = frm.elements[i];
			element.blur();
			element.disabled = "true";
		}
	},

	enable: function(frm) {
		for (var i = 0; i < frm.elements.length; i++) {
			var element = frm.elements[i];
			element.disabled = "";
		}
	},

	/*
	 * Check that the required values have been provided on the specified
	 * form. We do this by checking for fields wrapped in a
	 * <div class="required"></div>.
	 */
	validate: function(frm) {
		var missingFields = new Array();
		for (var i = 0; i < frm.elements.length; i++) {
			var field = frm.elements[i];
			var container = field.parentNode;
			if (container != null && Element.hasClassName(container, "required") && field.value.trim() == "") {
				missingFields.push(field);
			}
		}

		var valid = true;
		if (missingFields.length > 0) {
			valid = false;
			alert(this._getValidationMessage(missingFields));
			missingFields[0].focus();
		}

		return valid;
	},

	_getValidationMessage: function(missingFields) {
		var msg = "Please enter a value for" + (missingFields.length > 1 ? " each of" : "") + " the ";

		for (var i = 0; i < missingFields.length - 1; i++) {
			msg += missingFields[i].name + (missingFields.length == 2 ? " and " : ", ");
		}
		msg += (missingFields.length > 2 ? "and " : "") + missingFields[missingFields.length - 1].name;
		msg += " field" + (missingFields.length == 1 ? "" : "s") + ".";

		return msg;
	}
};
