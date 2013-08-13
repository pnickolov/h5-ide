var
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

	canvas_resize = function ()
	{
		//$('#main_body_content').css('height', window.innerHeight - 60);

		$('#canvas').css('height', window.innerHeight - 91);
	};

// Dom Ready
var listen = function ()
{
	var canvas_state = MC.canvas.getState();

	MC.paper = Canvon('svg_canvas');

	if (canvas_state === 'app')
	{
		$('#canvas_body')
			.addClass('canvas_state_' + canvas_state)
			//.on('mousedown', '.instance-volume', MC.canvas.volume.show)
			.on('mousedown', '.dragable', MC.canvas.event.selectNode)
			.on('click', '.line', MC.canvas.event.selectLine)
			.on('mousedown', MC.canvas.event.clearSelected)
			.on('mousedown', '#svg_canvas', MC.canvas.event.clickBlank)
			.on('selectstart', returnFalse);

		$('#tab-content-design').on('click', '#canvas-panel, #resource-panel', MC.canvas.volume.close);
	}

	if (canvas_state === 'stack')
	{
		$('#canvas_body')
			.addClass('canvas_state_' + canvas_state)
			//.on('mousedown', '.instance-volume', MC.canvas.volume.show)
			//.on('mousedown', '.eip-status', MC.canvas.event.EIPstatus)
			.on('mouseenter mouseleave', '.node', MC.canvas.event.nodeHover)
			.on('mousedown', '.node-label', MC.canvas.asgList.show)
			.on('mousedown', '.port', MC.canvas.event.drawConnection.mousedown)
			.on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
			.on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown)
			.on('click', '.line', MC.canvas.event.selectLine)
			.on('mousedown', MC.canvas.event.clearSelected)
			.on('mousedown', '#svg_canvas', MC.canvas.event.clickBlank)
			.on('selectstart', returnFalse);

		$('#tab-content-design').on('click', '#canvas-panel, #resource-panel', MC.canvas.volume.close);

	}
};

// Dom Ready
var ready = function ()
{
	$(document).on('keydown', MC.canvas.event.keyEvent);

	$('#header, #navigation, #tab-bar').on('click', MC.canvas.volume.close);

	$('#tab-content-design').on('mousedown', '.resource-item', MC.canvas.event.siderbarDrag.mousedown);

	$(document.body)
		.on('mousedown', '#instance_volume_list a', MC.canvas.volume.mousedown);

	canvas_resize();
	$(window).on('resize', canvas_resize);
};

// Dom Ready
var connect = function ()
{

};

define( ['jquery'], function() {
	return {
		'listen' : listen,
		'ready'  : ready,
		'connect': connect
	};
});
