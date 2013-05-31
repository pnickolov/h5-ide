
var show_item = function (target)
{
	//var list = $(target).parent();
	$(target).parent().parent().find('.hide').show();
	$(target).hide();
};

var ready = function () {

	console.log( 'layout render' )

var tab_resize = function (tabbar_width)
{
	var tabs = $('#tab-bar li'),
		tab_item_width = (tabbar_width - (tabs.length * 5)) / tabs.length;

	tab_item_width = tab_item_width > 140 ? 140 : tab_item_width;
	tabs.css('width', tab_item_width);
};

//$(document).ready(function() {

	// Store variables
	var accordion_head = $('.accordion li a'),
		accordion_body = $('.accordion .sub-menu');

	$('#dashboard').on('click', 'a', function (event)
	{
		if (event.target.parentNode.className !== 'show-unused-region')
		{
			$('#tab-bar-dashboard .tab-bar-truncate').tab('show');
		}
	});

	$('#tab-bar').on('mousedown', '.close-tab', function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = $(event.target).parent(),
			page_id = target.attr('id').replace('tab-bar-', '');

		$('#tab-content-' + page_id).remove();
		target.remove();

		$('#tab-bar li:last .tab-bar-truncate').tab('show');
	});

	$('.sub-menu').on('click', 'a', function (event)
	{
		var target = event.target,
			target_id = $(target).text().toLowerCase();

		if ($('#tab-bar-' + target_id)[0])
		{
			$('#tab-bar-' + target_id + ' .tab-bar-truncate').tab('show');
		}
		else
		{
			$('#tab-bar ul').append('<li id="tab-bar-' + target_id + '">' +
				'<a href="#tab-content-' + target_id + '" data-toggle="tab" class="truncate tab-bar-truncate">' +
				'<i class="icon-layers icon-label"></i>' + target_id +
				'</a>' +
				'<a href="javascript:void(0)" class="close-tab">x</a>' +
				'</li>');

			// $('#main').append('<div id="tab-content-' + target_id + '" class="main-content">' +
			// 	'<div id="main-toolbar">' +
			// 		'<div class="toolbar-btn-left">' +
			// 			'<a href="#" id="hide-resource-panel" class="btn-toolbar tooltip" data-tooltip="Hide Resource Panel"><i class="icon-double-angle-left"></i></a>' +
			// 		'</div>' +
			// 		'<div class="toolbar-btn-center">' +
			// 			'<a href="#" class="btn-toolbar"><i class="icon-file-add"></i></a>' +
			// 			'<a href="#" class="btn-toolbar"><i class="icon-sitemap"></i></a>' +
			// 		'</div>' +
			// 	'</div>' +
			// 	'<div id="resource-panel">' +
			// 			'<ul class="resource-type-tab">' +
			// 				'<li class="active"><a href="#new" data-toggle="tab">New</a></li>' +
			// 				'<li><a href="#existing" data-toggle="tab">Existing</a></li>' +
			// 			'</ul>' +
			// 	'</div>' +
			// 	'<div id="canvas">' +
			// 		'Canvas for: ' + target_id +
			// 	'</div>' +
			// '</div>');

			$('#tab-bar-' + target_id + ' .tab-bar-truncate').tab('show');
		}

		$('#navigation').toggleClass('collapsed');
		$('#main').toggleClass('wide');

		tab_resize($('#navigation').hasClass('collapsed') ? $('#tab-bar').width() + 180 : $('#tab-bar').width() - 180);
	});

	// Open the first tab on load
	accordion_head.first().addClass('active').next().slideDown('normal');

	// Click function
	accordion_head.on('click', function(event)
	{
		// Disable header links
		event.preventDefault();

		// Show and hide the tabs on click
		if ($(this).attr('class') != 'active')
		{
			accordion_body.slideUp('normal');
			$(this).next().stop(true,true).slideToggle('normal');
			accordion_head.removeClass('active');
			$(this).addClass('active');
			accordion_head.parent().removeClass('active');
			$(this).parent().addClass('active');
		};
	});


	// Adapt Canvas size to window size
	var main_middle = $('#canvas-panel'),
		resource_panel = $('#resource-panel'),
		property_panel = $('#property-panel'),
		nav = $('#navigation'),
		main = $('#main');


	var middleResize = function () 
	{	
		var main_middle = $('#canvas-panel'),
			resource_panel = $('#resource-panel'),
			resource_panel_ml = resource_panel.css('margin-left'),
			property_panel = $('#property-panel'),
			property_panel_mr = property_panel.css('margin-right'),
			panel_width = resource_panel.width(),
			main = $('#main'),
			nav = $('#navigation'),
			nav_left = nav.css('left'),
			nav_width = nav.width(),
			win_width = $(window).width();
			
		main_middle.width(win_width - nav_width - nav_left - panel_width * 2 - resource_panel_ml - property_panel_mr);
		main_middle.height(main.height() - $('#tab-bar').height());
	};

	middleResize();

	$(window).resize(middleResize);

	// Hide Left Menu

	$('#view-toggle-navigation').on('click', function(event)
	{
		nav.toggleClass('collapsed');
		$(this).toggleClass('active');
		main.toggleClass('wide');
		middleResize();

		tab_resize($('#navigation').hasClass('collapsed') ? $('#tab-bar').width() + 180 : $('#tab-bar').width() - 180);
	});

	// Toggle Property Panel
	$('#hide-property-panel').on('click', function(event)
	{	
		var i = $(this).children().first();

		property_panel.toggleClass('hiden');
		i.toggleClass('icon-double-angle-left');
		i.toggleClass('icon-double-angle-right');
		main_middle.toggleClass('right-hiden');
		middleResize();
	});

	// Toggle Resource Panel
	$('#hide-resource-panel').on('click', function(event)
	{	
		var i = $(this).children().first();

		resource_panel.toggleClass('hiden');
		i.toggleClass('icon-double-angle-left');
		i.toggleClass('icon-double-angle-right');
		main_middle.toggleClass('left-hiden');
		middleResize();
	});

	$(window).resize(function ()
	{
		tab_resize($('#tab-bar').width());
	});
//});
}

define( [ 'jquery', 'bootstrap-tab', 'bootstrap-dropdown', 'UI.tooltip', 'UI.scrollbar' ], function() {

	return {
		ready : ready
	}

});