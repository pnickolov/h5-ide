
// [ Warning!!!! ] DEAD CODE
// This source code is dead. listen() / ready() / connect() seems like doing nothing.
// But it pollutes the window object. Which makes it un-removable !!!!
// Dom Ready
var listen = function ()
{
	var canvas_state = MC.canvas.getState();

	MC.paper = Canvon('svg_canvas');

	if (canvas_state === 'app')
	{
		$('#canvas_body')
			.addClass('canvas_state_' + canvas_state)
			.on('mousedown', '.instance-volume', MC.canvas.volume.show)
			.on('mousedown', '.dragable', MC.canvas.event.selectNode)
			.on('click', '.line', MC.canvas.event.selectLine)
			.on('mousedown', MC.canvas.event.clearSelected)
			.on('mousedown', '#svg_canvas', MC.canvas.event.clickBlank)
			.on('mouseenter mouseleave', '.node', MC.canvas.event.nodeHover)
			.on('selectstart', returnFalse)
			.on('mousedown', '.node-launchconfiguration-label', MC.canvas.asgList.show);

		$('#tab-content-design').on('click', '#canvas-panel, #resource-panel', MC.canvas.volume.close);
	}

	if (canvas_state === 'stack')
	{
		$('#canvas_body')
			.addClass('canvas_state_' + canvas_state)
			//.on('mousedown', '.instance-volume', MC.canvas.volume.show)
			//.on('mousedown', '.eip-status', MC.canvas.event.EIPstatus)
			.on('mousedown', '.port', MC.canvas.event.drawConnection.mousedown)
			.on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
			.on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown)
			.on('mouseenter mouseleave', '.node', MC.canvas.event.nodeHover)
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
