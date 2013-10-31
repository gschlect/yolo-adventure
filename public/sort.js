function isNumeric(n) {
	return !isNaN(parseFloat(n)) && isFinite(n);
}

function sort($th){
	var inverse = $th.children('.glyphicon').hasClass('glyphicon-chevron-down');
	$('tbody')
		.find('td')
		.filter(function(){return $(this).index() === $th.index()})
		.sortElements(function(a, b){
			a = $.text([a]);
			b = $.text([b]);
			if(isNumeric(a) && isNumeric(b)){
				a = parseFloat(a);
				b = parseFloat(b);
			}
			if(a == b)
				return 0;
			else if(a > b)
				return (inverse ? -1 : 1);
			else
				return (inverse ? 1 : -1);
		}, function(){
			return this.parentNode;
		});
}

// bind for tables with class .sortable
$(document).on('ready', function(){
	$('table.sortable thead').on('click', 'th:not(.sort)', function(e){
		e.stopPropagation();
		$(this)
			.addClass('sort')
			.siblings()
			.removeClass('sort');
		sort($(this));
	});

	$('table.sortable').on('click', 'th.sort', function(){
		$(this)
			.children('.glyphicon')
			.toggleClass('glyphicon-chevron-up')
			.toggleClass('glyphicon-chevron-down');
		sort($(this));
	});
});
