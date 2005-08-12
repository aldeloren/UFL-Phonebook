function autocomplete(f, completions) {
	var field = $(f);

	for (completion in completions) {
		if (typeof completion == "RegExp") {
			if (completion.test(field.value)) {
				alert("regexp match!");
			}
		}
		else {
			if (field.value.substr(field.value.length - completion.length, field.value.length) == completion) {
				field.value += completions[completion];
			}
		}
	}
}
