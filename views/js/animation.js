$(document).ready(function() {
    $(".article-thumb").imgLiquid();
});

$(".account-menu li").hover(function() {
    $(this).children('ul').show();
}, function() {
    $(this).children('ul').hide();
});

jQuery( function($) {
	$('tbody tr[data-href]').addClass('clickable').click( function() {
		window.location = $(this).attr('data-href');
	}).find('a').hover( function() {
		$(this).parents('tr').unbind('click');
	}, function() {
		$(this).parents('tr').click( function() {
			window.location = $(this).attr('data-href');
		});
	});
});
