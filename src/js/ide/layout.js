var
	/*show_item = function (target)
	{
		$(target).parent().prev().find('.hide').show();
		$(target).hide();
	},*/

	// tab_resize = function (tabbar_width)
	// {
	// 	var tabs = $('#tab-bar li'),
	// 		tab_item_width = (tabbar_width - (tabs.length * 5)) / tabs.length;

	// 	tab_item_width = tab_item_width > 180 ? 180 : tab_item_width;
	// 	tabs.css('width', tab_item_width);
	// },

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
		$('.main-content').height(window.innerHeight - 95);
	}
;

var ready = function () {

	// var main_middle = $('#canvas-panel'),
	// 	resource_panel = $('#resource-panel'),
	// 	property_panel = $('#property-panel'),
	// 	nav = $('#navigation'),
	// 	main = $('#main');

	// Navigation Bar Interaction with Tab Bar
	/*
	$('#nav-dashboard-region').on('click', 'a', function (event)
	{
		if (event.target.parentNode.className !== 'show-unused-region')
		{
			$('#tab-bar-dashboard .tab-bar-truncate').tab('show');
		}
	});
	*/

	// $('#tab-bar').on('mousedown', '.close-tab', function (event)
	// {
	// 	event.preventDefault();
	// 	event.stopPropagation();

	// 	var target = $(event.target).parent(),
	// 		page_id = target.attr('id').replace('tab-bar-', '');

	// 	$('#tab-content-' + page_id).remove();
	// 	target.remove();

	// 	$('#tab-bar li:last .tab-bar-truncate').tab('show');
	// });

	/*
	$('.nav-region-list-items').on('click', 'a', function (event)
	{
		var target = event.target,
			nav = $('#navigation'),
			main = $('#main'),
			target_id = $(target).text().toLowerCase(),
			tabbar_width;

		if ($('#tab-bar-' + target_id)[0])
		{
			$('#tab-bar-' + target_id + ' .tab-bar-truncate').tab('show');
		}
		else
		{
			$('#tab-bar ul').append('<li id="tab-bar-' + target_id + '">' +
				'<a href="#tab-content-' + target_id + '" data-toggle="tab" class="truncate tab-bar-truncate" title="' + target_id + '">' +
				'<i class="icon-layers icon-label"></i>' + target_id +
				'</a>' +
				'<a href="javascript:void(0)" class="close-tab">x</a>' +
				'</li>');

			$('#tab-bar-' + target_id + ' .tab-bar-truncate').tab('show');
		}

		nav.addClass('collapsed');
		nav.removeClass('scroll-wrap');
		main.addClass('wide');
		$('#first-level-nav').removeClass('accordion');
		$('.nav-head').removeClass('accordion-group');
		$('.sub-menu-wrapper').removeClass('accordion-body');
		if (nav.hasClass('collapsed'))
		{
			$('.sub-menu-wrapper').each(function() {
				this.style.cssText = '';
			});
		};

		tabbar_width = $('#tab-bar').width();
		tab_resize($('#navigation').hasClass('expanded') ? tabbar_width + 180 : tabbar_width - 180);
	});
	*/

	// Collapsed Navigation Mouse Interaction
	/*
	$('.nav-head').hoverIntent({
		timeout: 100,

		over: function()
		{
			if ($('#navigation').hasClass('collapsed'))
			{
				$(this).delay(300).addClass('collapsed-show');
			};
		},

		out: function()
		{
			$(this).removeClass('collapsed-show');
		}
	});
	*/

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
		};
	});

	// Toggle Property Panel
	/*
	$('#hide-property-panel').click(function (event)
	{
		var item = $(this).children().first(),
			main_middle = $('#canvas-panel'),
			property_panel = $('#property-panel');

		property_panel.toggleClass('hiden');
		item.toggleClass('icon-double-angle-left').toggleClass('icon-double-angle-right');
		main_middle.toggleClass('right-hiden');
		canvasPanelResize();
	});
	*/

	// Toggle Resource Panel
	/*
	$('#hide-resource-panel').on('click', function (event)
	{
		var item = $(this).children().first(),
			main_middle = $('#canvas-panel'),
			resource_panel = $('#resource-panel');

		resource_panel.toggleClass('hiden');
		item.toggleClass('icon-double-angle-left').toggleClass('icon-double-angle-right');
		main_middle.toggleClass('left-hiden');
		canvasPanelResize();
	});
	*/

	canvasPanelResize();
	mainContentResize();

	$(window).resize(function ()
	{
		//tab_resize($('#tab-bar').width());
		canvasPanelResize();
		mainContentResize();
	});

	//fixedaccordion.resize();

	//Resource Panel
    $(document).on('click', '.fixedaccordion-head select', function (event)
    {
        event.stopPropagation();
    });
    $(document).on('change', '.fixedaccordion-head select', function (event)
    {
        event.stopPropagation();

        fixedaccordion.show.call($(this).parent().parent())
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
}

define( [ 'jquery', 'UI.scrollbar', 'bootstrap-dropdown' ], function() {

	return {
		ready : ready
	}

});