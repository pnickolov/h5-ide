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
		$('#main_body_content').css('height', window.innerHeight - 62);
	};

// Dom Ready
var listen = function ()
{
	MC.paper = Canvon('svg_canvas');

	//clear old svg element ( add by xjimmy )
	//$(MC.paper).find("#vpc_layer").empty();
	//$(MC.paper).find("#az_layer").empty();
	//$(MC.paper).find("#subnet_layer").empty();
	//$(MC.paper).find("#node_layer").empty();
	//$(MC.paper).find("#line_layer").empty();

	$('#canvas_body')
		.on('mousedown', '.instance-volume', MC.canvas.volume.show)
		.on('mousedown', '.port', MC.canvas.event.drawConnection.mousedown)
		.on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
		.on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown)
		.on('click', MC.canvas.event.clearSelected);

	$('#line_layer').on('click', '.line', MC.canvas.event.selectLine);

	//canvas_body.on('mousedown', MC.canvas.selection.mousedown);
	//canvas_body.on('selectstart', returnFalse);

	$('#resource-panel').on('mousedown', '.resource-item', MC.canvas.event.siderbarDrag.mousedown);

	$(document).on('keyup', MC.canvas.event.keyEvent);
	
	//$(document.body).on('click', '.volume_item', MC.canvas.volume.select);

	$(document.body).on('mousedown', '.volume_item', MC.canvas.volume.mousedown);

	canvas_resize();
	$(window).on('resize', canvas_resize);

};

// Dom Ready
var ready = function ()
{
	//temp

	//1.
	$.ajax('js/ide/canvas_test_data.json', {
		success: function (data)
		{
			if (typeof data === 'object')
			{
				MC.canvas_data = data;
				MC.canvas.layout.init();
			}
			else
			{
				console.log('load test data failed');
			}
		}
	});


	return;
};

// Dom Ready
var connect = function ()
{
	/////////// create connenction ///////////
	/*
	MC.canvas.connect($("#host1"),"instance-attach",$("#eni"),"eni-attach");

	MC.canvas.connect($("#host2"),"instance-sg-out",$("#eni"),"eni-sg-in");
	MC.canvas.connect($("#host2"),"instance-attach",$("#volume1"),"volume-attach");
	MC.canvas.connect($("#host2"),"instance-attach",$("#volume2"),"volume-attach");

	MC.canvas.connect($("#host2"),"instance-sg-in",$("#elb"),"elb-sg-out");

	MC.canvas.connect($("#igw1"),"igw-tgt",$("#rt1"),"rtb-tgt-left");
	MC.canvas.connect($("#vgw1"),"vgw-tgt",$("#rt1"),"rtb-tgt-right");

	MC.canvas.connect($("#cgw1"),"cgw-vpn",$("#vgw1"),"vgw-vpn");
	*/

};

define( ['jquery'], function() {
	return {
		'listen' : listen,
		'ready'  : ready,
		'connect': connect
	};
});
