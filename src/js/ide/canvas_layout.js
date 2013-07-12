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
	var canvas_body = $('#canvas_body');

	current_tab = '';

	MC.paper = Canvon('svg_canvas');

	//clear old svg element ( add by xjimmy )
	//$(MC.paper).find("#vpc_layer").empty();
	//$(MC.paper).find("#az_layer").empty();
	//$(MC.paper).find("#subnet_layer").empty();
	//$(MC.paper).find("#node_layer").empty();
	//$(MC.paper).find("#line_layer").empty();


	// $.ajax('../js/canvas/response.data', {
	// 	success: function (data)
	// 	{
	// 		if (typeof data === 'object')
	// 		{
	// 			user_data = $.xml2json(data);
	// 		}
	// 		else
	// 		{
	// 			user_data = $.xml2json($.parseXML(data));
	// 		}
	// 		MC.canvas.layout.analysis(user_data);
	// 		MC.canvas.layout.init();
	// 	}
	// });

	canvas_body
		.on('mousedown', '.instance-volume', MC.canvas.event.volumeShow)
		.on('mousedown', '.port', MC.canvas.event.drawConnection.mousedown)
		.on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
		.on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown)
		.on('click', MC.canvas.event.clearSelected);

	$('#line_layer').on('click', '.line', MC.canvas.event.selectLine);

	//canvas_body.on('mousedown', MC.canvas.selection.mousedown);
	//canvas_body.on('selectstart', returnFalse);

	$('#resource-panel').on('mousedown', '.resource-item', MC.canvas.event.siderbarDrag.mousedown);

	$(document).on('keyup', MC.canvas.event.keyEvent);
	
	$(document.body).on('click', '.volume_item', MC.canvas.event.volumeSelect);

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

	//2.simulate drag from resource panel
	MC.canvas_data = $.extend(true, {}, MC.canvas.STACK_JSON);

	/////////// create node ///////////
	var node_vpc = MC.canvas.add('AWS.VPC.VPC', {
		'name': 'vpc1'
	},{
		'x': 2,
		'y': 2
	});

	var node_az = MC.canvas.add('AWS.EC2.AvailabilityZone', {
		'name': 'ap-northeast-1'
	},{
		'x': 19,
		'y': 16
	});

	var node_subnet = MC.canvas.add('AWS.VPC.Subnet', {
		'name': 'subnet1'
	},{
		'x': 23,
		'y': 20
	});

	var node_host1 = MC.canvas.add('AWS.EC2.Instance', {
		'name': 'host1',
		'imageId': 'ami-d14dc2d0',
		'osType': 'redhat',
		'architecture':'x86_64',
		'rootDeviceType':'ebs'
	},{
		'x': 25,
		'y': 22
	});

	var node_host2 = MC.canvas.add('AWS.EC2.Instance', {
		'name': 'host2',
		'imageId': 'ami-fc6ceefd',
		'osType':
		'ubuntu',
		'architecture':'i386',
		'rootDeviceType':'ebs'
	},{
		'x': 25,
		'y': 36
	});

	var node_volume1 = MC.canvas.add('AWS.EC2.EBS.Volume', {
		'name': '/dev/sdf',
		'volumeSize':'1',
		'snapshotId': ''
	},{
		'x': 43,
		'y': 36
	});

	var node_volume2 = MC.canvas.add('AWS.EC2.EBS.Volume', {
		'name': '/dev/sdg',
		'volumeSize':'10',
		'snapshotId': ''
	},{
		'x': 43,
		'y': 50
	});

	var node_elb = MC.canvas.add('AWS.ELB', {
		'name': 'elb1(Internet)'
	},{
		'x': 3,
		'y': 25
	});

	var node_rt1 = MC.canvas.add('AWS.VPC.RouteTable', {
		'name': 'RT1'
	},{
		'x': 28,
		'y': 3
	});

	var node_rt2 = MC.canvas.add('AWS.VPC.RouteTable', {
		'name': 'RT2'
	},{
		'x': 64,
		'y': 46
	});

	var node_eni = MC.canvas.add('AWS.VPC.NetworkInterface', {
		'name': 'eni0'
	},{
		'x': 43,
		'y': 22
	});

	var node_igw1 = MC.canvas.add('AWS.VPC.InternetGateway', {
		'name': 'IGW'
	},{
		'x': 3,
		'y': 3
	});

	var node_vgw1 = MC.canvas.add('AWS.VPC.VPNGateway', {
		'name': 'VGW'
	},{
		'x': 65,
		'y': 9
	});

	var node_cgw1 = MC.canvas.add('AWS.VPC.CustomerGateway', {
		'name': 'CGW',
		'networkName': 'CustomerNetwork1'
	},{
		'x': 83,
		'y': 9
	});

	var node_cgw2 = MC.canvas.add('AWS.VPC.CustomerGateway', {
		'name': 'CGW',
		'networkName': 'CustomerNetwork2'
	},{
		'x': 83,
		'y': 24
	});

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
