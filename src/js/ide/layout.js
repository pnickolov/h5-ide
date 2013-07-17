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
			nav_left = nav.css('left'),
			nav_width = nav.width(),
			win_width = $(window).width();

		main_middle.width(win_width - nav_width - nav_left - panel_width * 2 - resource_panel_marginLeft - property_panel_marginRight);
		main_middle.height(main.height() - $('#tab-bar').height());
		nav.height(window.innerHeight - 50);
	},

	mainContentResize = function()
	{
		$('.main-content').height(window.innerHeight - 92);
	}
;

var ready = function () {

	// Hide Left Menu
	$('#view-toggle-navigation').on('click', function (event)
	{
		var nav = $('#navigation'),
			main = $('#main'),
			first_level_nav = $('#first-level-nav');

		nav.toggleClass('collapsed');
		$(this).toggleClass('active');
		main.toggleClass('wide');
		canvasPanelResize();

		Tabbar.resize(nav.hasClass('collapsed') ? $('#tab-bar').width() + 180 : $('#tab-bar').width() - 180);

		nav.toggleClass('scroll-wrap');

		first_level_nav[0].style.cssText = '';
		first_level_nav.toggleClass('accordion');

		$('.nav-head').toggleClass('accordion-group');
		$('.sub-menu-wrapper').toggleClass('accordion-body');

		if (nav.hasClass('collapsed'))
		{
			$('.sub-menu-wrapper').each(function() {
				this.style.cssText = '';
			});
		}
	});


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