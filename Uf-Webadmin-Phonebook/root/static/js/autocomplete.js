function autocomplete(evt, f, completions) {
	// Short-circuit if someone presses delete
	if (evt.keyCode == 8) {
		return;
	}

	var field = $(f);

	var completion = null;
	for (c in completions) {
		if (typeof c == "RegExp") {
			if (c.test(field.value)) {
				completion = completion[c];
				break;
			}
		}
		else {
			if (field.value.substr(field.selectionEnd - c.length, c.length) == c) {
				completion = completions[c];
				break;
			}
		}
	}

	if (completion) {
		var before = field.value.substr(0, field.selectionStart);
		var after  = field.value.substr(field.selectionEnd, field.value.length);

		var pos = field.selectionEnd;
		field.value = before + completion + after;
		field.setSelectionRange(pos, pos + completion.length);
	}
}
