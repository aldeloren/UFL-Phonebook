function initBehavior() {
	$("query").onkeyup = function(evt) {
		autocomplete(evt, this, {
			"@": "ufl.edu"
		});
	}
}
