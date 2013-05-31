var layout = {},
	Private_IP = {},
	Pubilc_IP = {},
	SecurityGroup_Rule = {}/*,

	
	hide_siderbar = function ()
	{
		$('#siderbar_body_main').hide();

		$('#main_body').animate({
			'margin-left': 60
		}, 300);

		$('#siderbar').animate({
			'width': 60
		}, 300);

		$('#show_siderbar_btn').fadeIn();
	},

	show_siderbar = function ()
	{
		$('#main_body').animate({
			'margin-left': 279
		}, 300);

		$('#siderbar').animate({
			'width': 279
		}, 300, function ()
		{
			$('#siderbar_body_main').show();
			$('#show_siderbar_btn').fadeOut();
		});
	},

*/

// Dom Ready
var ready = function ()
{

	canvas_resize = function ()
	{
		$('#main_body_content').css('height', window.innerHeight - 62);
	};

	var canvas_body = $('#canvas_body');

	MC.paper = Canvon('svg_canvas');
	$.ajax('response.data', {
		success: function (data)
		{
			if (typeof data === 'object')
			{
				user_data = $.xml2json(data);
			}
			else
			{
				user_data = $.xml2json($.parseXML(data));
			}
			MC.canvas.layout.analysis(user_data);
			MC.canvas.layout.init();
		}
	});

	canvas_body.on('mousedown', '.dragable', MC.drag.canvas.mousedown);
	canvas_body.on('click', function (event)
	{
		var target = $(event.target);

		$('.focusable').removeClass('focused');

		if (target.hasClass('focusable'))
		{
			target.addClass('focused');
		}

		if (target.hasClass('node') || target.hasClass('zone'))
		{
			MC.canvas.focused_node.push(target.attr('id'));
		}
	});

	canvas_body.on('mousedown', MC.canvas.selection.mousedown);
	canvas_body.on('mousedown', '.connectable', MC.canvas.line_connect.mousedown);
	canvas_body.on('mousedown', '.zone_resizer', MC.drag.resize.mousedown);
	canvas_body.on('selectstart', returnFalse);
	canvas_body.on('mousedown', '.zone_title', returnFalse);
	canvas_body.on('click', '.attachment_keyPairs', function (event)
	{
		var target = $(event.target).parent(),
			node_attachment;

		if (target.hasClass('attached_keyPairs'))
		{
			target.removeClass('attached_keyPairs');
			node_attachment = MC.layout_data[target.attr('id')]['attachment'];
			node_attachment.splice(node_attachment.indexOf('keyPairs'), 1);
		}

		return false;
	});

	canvas_body.on('click', '.attachment_eip', function (event)
	{
		var target = $(event.target).parent(),
			node_attachment;

		if (target.hasClass('attached_eip'))
		{
			target.removeClass('attached_eip');
			node_attachment = MC.layout_data[target.attr('id')]['attachment'];
			node_attachment.splice(node_attachment.indexOf('eip'), 1);
		}

		return false;
	});	

	/*
	$('.siderbar_tab_title').on('click', function (event)
	{
		var target = $(event.target),
			list = target.next();

		if (list.css('display') != 'block')
		{
			$('.siderbar_tab ol').slideUp();
			list.slideDown(200);
		}
	});
	*/

	$('#siderbar_body_main').on('mousedown', '.dragComponent', MC.drag.component.mousedown);
	$('#top_btn_zoom_out').on('click', MC.canvas.zoomOut);
	$('#top_btn_zoom_in').addClass('disabled');

	$(document).on('keyup', MC.KeyRemoveNode);

	canvas_resize();
	$(window).on('resize', canvas_resize);
};

define([ 'canvon', 'MC.canvas' ], function() {

	return {
		ready : ready
	}
});