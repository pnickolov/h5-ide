var

	canvasPanelResize = function ()
	{
		var main_middle = $('#canvas-panel'),
			resource_panel = $('#resource-panel'),
			property_panel = $('#property-panel'),
			resource_panel_marginLeft = resource_panel.css('margin-left'),
			property_panel_marginRight = property_panel.css('margin-right'),
			panel_width = resource_panel.width(),
			main = $('#main'),
			nav = $('#navigation'),
			nav_sub = $('.sub-menu-scroll-wrap'),
			nav_left = nav.css('left'),
			nav_width = nav.width(),
			win_width = $(window).width();

		main_middle.width(win_width - nav_width - nav_left - panel_width * 2 - resource_panel_marginLeft - property_panel_marginRight);
		main_middle.height(main.height() - $('#tab-bar').height());
		nav.height(window.innerHeight);
		nav_sub.height(window.innerHeight - 100);
	},

	mainContentResize = function()
	{
		$('.main-content').height(window.innerHeight - 42);
		// console.log('mainContentResize');
	}
;

var ready = function () {

	canvasPanelResize();
	mainContentResize();

	//Resource Panel
    $(document).on('click', '.fixedaccordion-head select', function (event)
    {
        event.stopPropagation();
    });
    $(document).on('change', '.fixedaccordion-head select', function (event)
    {
        event.stopPropagation();

        fixedaccordion.show.call($(this).parent().parent());
    });

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

define( [ 'jquery', 'UI.scrollbar', 'bootstrap-dropdown' ], function() {

	return {
		ready : ready
	};
});