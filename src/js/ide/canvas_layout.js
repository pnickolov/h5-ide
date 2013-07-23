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

		$('#canvas').css('height', window.innerHeight - 129);
	};

// Dom Ready
var listen = function ()
{
	MC.paper = Canvon('svg_canvas');

	$('#canvas_body')
		.on('mousedown', '.instance-volume', MC.canvas.volume.show)
		.on('mousedown', '.port', MC.canvas.event.drawConnection.mousedown)
		.on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
		.on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown)
		.on('click', '.line', MC.canvas.event.selectLine)
		.on('mousedown', MC.canvas.event.clearSelected)
		.on('mousedown', '#svg_canvas', MC.canvas.event.clickBlank)
		.on('selectstart', returnFalse);

	//canvas_body.on('mousedown', MC.canvas.selection.mousedown);

	$('#tab-content-design').on('click', '#canvas-panel, #resource-panel', MC.canvas.volume.close);

	$('#resource-panel').on('mousedown', '.resource-item', MC.canvas.event.siderbarDrag.mousedown);

};

// Dom Ready
var ready = function ()
{
	$(document).on('keyup', MC.canvas.event.keyEvent);

	$('#header, #navigation, #tab-bar').on('click', MC.canvas.volume.close);

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
