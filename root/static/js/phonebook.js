var typed = false;

/*
$("source").onchange = document.getElementById('searchbox').focus();
*/

function initBehavior() {
	var query = $("query");

	query.onkeyup = function(evt) {
/*
		Field.autocomplete(evt, this, {
			"@": "ufl.edu"
		});
*/
	}

	query.onclick = function(evt) {
	}

	Field.activate(query);
}
