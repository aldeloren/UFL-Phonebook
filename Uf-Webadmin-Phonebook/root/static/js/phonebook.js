function initBehavior() {
	$("query").onkeyup = function() {
		autocomplete(this, {
			"@": "ufl.edu"
		});
	}
}
