// [ Warning!!!! ] DEAD CODE
// This source code is dead. ready() seems like doing nothing.
// But it pollutes the window object. Which makes it un-removable !!!!

var ready = function () {

	// Global Overview World Map Hover Sync
	$('#map-region-spot-list').on('mouseenter', 'li', function()
	{
		$('#stat-' + this.id).addClass('hover');
	});

	$('#map-region-spot-list').on('mouseleave', 'li', function()
	{
		$('#stat-' + this.id).removeClass('hover');
	});

	$('#dashboard-widget-regions').on('mouseenter', 'a', function()
	{
		$('#' + this.id.replace('stat-','')).addClass('hover');
	});

	$('#dashboard-widget-regions').on('mouseleave', 'a', function()
	{
		$('#' + this.id.replace('stat-','')).removeClass('hover');
	});



//});
};

define( [ 'jquery', 'UI.scrollbar', 'UI.selectbox' ], function() {
	return {
		ready : ready
	};
});
