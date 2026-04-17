$(function(){
	var filter = [];
	var result = [];
	var $noResults = $('#no-results');
	$('.uk-card-title').each(function(){
		filter.push($(this).text());
	});
	$('.uk-search-input').keyup(function(){
		var input = $('.uk-search-input').val();
		var regex = new RegExp(input, 'i');

		if (input === '') {
			$('.item').each(function(){
				$(this).removeAttr('hidden');
			});
			$noResults.hide();
		}
		else {
			var visibleCount = 0;
			filter.forEach(function(text, i){
				result[i] = text.match(regex);
			});
			$('.item').each(function(i){
				if (result[i]) {
					$(this).removeAttr('hidden');
					visibleCount++;
				}
				else {
					$(this).attr('hidden', '');
				}
			});
			if (visibleCount === 0 && $noResults.length) {
				$noResults.show();
			} else {
				$noResults.hide();
			}
		}
	});
});
