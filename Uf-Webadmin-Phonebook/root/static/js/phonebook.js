var typed = false;

function initBehavior() {
	var query = $("query");

	query.onkeyup = function(evt) {
		typed = true;
		autocomplete(evt ? evt : window.event, this, {
			"@": "ufl.edu"
		});
	}

	query.onclick = function(evt) {
		if (! typed) {
			this.value = '';
		}
	}

	query.select();
}
