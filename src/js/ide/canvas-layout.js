var layout = {},
	Private_IP = {},
	Pubilc_IP = {},
	SecurityGroup_Rule = {},

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
var ready = function ()
{
	var canvas_body = $('#canvas_body');

	current_tab = 'app-01';

	MC.paper = Canvon('svg_canvas');
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
		.on('mousedown', '.port', MC.canvas.event.drawConnection.mousedown)
		.on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
		.on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown)
		.on('click', MC.canvas.event.clearSelected);

	//canvas_body.on('mousedown', MC.canvas.selection.mousedown);
	//canvas_body.on('selectstart', returnFalse);

	$('#siderbar_body_main').on('mousedown', '.siderbar-component-item', MC.canvas.event.siderbarDrag.mousedown);

	$(document).on('keyup', MC.canvas.event.keyEvent);

	canvas_resize();
	$(window).on('resize', canvas_resize);


	/////////// create node ///////////
	var node_vpc = MC.canvas.add('AWS.VPC.VPC', {
		'uid': 'vpc',
		'vpc_name': 'vpc1',
		'width': 79,
		'height': 69
	});
	MC.canvas.position(node_vpc, 2, 2);

	var node_az = MC.canvas.add('AWS.EC2.AvailabilityZone', {
		'uid': 'az',
		'az_name': 'ap-northeast-1',
		'width': 44,
		'height': 51
	});
	MC.canvas.position(node_az, 19, 16);

	var node_subnet = MC.canvas.add('AWS.VPC.Subnet', {
		'uid': 'subnet',
		'subnet_name': 'subnet1',
		'width': 36,
		'height': 43
	});
	MC.canvas.position(node_subnet, 23, 20);

	var node_host1 = MC.canvas.add('AWS.EC2.Instance', {
		'uid': 'host1',
		'os_type': 'amazon.64.instance-store',
		'hostname': 'webserver'
	});
	MC.canvas.position(node_host1, 25, 22);

	var node_host2 = MC.canvas.add('AWS.EC2.Instance', {
		'uid': 'host2',
		'os_type': 'ubuntu.64.ebs',
		'hostname': 'dbserver'
	});
	MC.canvas.position(node_host2, 25, 36);

	var node_volume1 = MC.canvas.add('AWS.EC2.EBS.Volume', {
		'uid': 'volume1',
		'device_name': '/dev/sdf',
		'volume_size': '10 GB'
	});
	MC.canvas.position(node_volume1, 43, 36);

	var node_volume2 = MC.canvas.add('AWS.EC2.EBS.Volume', {
		'uid': 'volume2',
		'device_name': '/dev/sdg',
		'volume_size': '20 GB'
	});
	MC.canvas.position(node_volume2, 43, 50);

	var node_elb = MC.canvas.add('AWS.ELB', {
		'uid': 'elb',
		'elb_name': 'elb1(Internal)'
	});
	MC.canvas.position(node_elb, 3, 25);

	var node_rt1 = MC.canvas.add('AWS.VPC.RouteTable', {
		'uid': 'rt1',
		'rtb_name': 'RT1'
	});
	MC.canvas.position(node_rt1, 28, 3);

	var node_rt2 = MC.canvas.add('AWS.VPC.RouteTable', {
		'uid': 'rt2',
		'rtb_name': 'RT2'
	});
	MC.canvas.position(node_rt2, 64, 46);

	var node_eni = MC.canvas.add('AWS.VPC.NetworkInterface', {
		'uid': 'eni',
		'eni_name': 'eni0'
	});
	MC.canvas.position(node_eni, 43, 22);

	var node_igw1 = MC.canvas.add('AWS.VPC.InternetGateway', {
		'uid': 'igw1'
	});
	MC.canvas.position(node_igw1, 3, 3);

	var node_vgw1 = MC.canvas.add('AWS.VPC.VPNGateway', {
		'uid': 'vgw1'
	});
	MC.canvas.position(node_vgw1, 65, 9);

	var node_cgw1 = MC.canvas.add('AWS.VPC.CustomerGateway', {
		'uid': 'cgw1',
		'network_name': 'CustomerNetwork1'
	});
	MC.canvas.position(node_cgw1, 83, 9);

	var node_cgw2 = MC.canvas.add('AWS.VPC.CustomerGateway', {
		'uid': 'cgw2',
		'network_name': 'CustomerNetwork1'
	});
	MC.canvas.position(node_cgw2, 83, 24);

	/////////// create connenction ///////////
	MC.canvas.connect($("#host1"),"instance-attach",$("#eni"),"eni-attach");

	MC.canvas.connect($("#host2"),"instance-sg-out",$("#eni"),"eni-sg-in");
	MC.canvas.connect($("#host2"),"instance-attach",$("#volume1"),"volume-attach");
	MC.canvas.connect($("#host2"),"instance-attach",$("#volume2"),"volume-attach");

	MC.canvas.connect($("#host2"),"instance-sg-in",$("#elb"),"elb-sg-out");

	MC.canvas.connect($("#igw1"),"igw-tgt",$("#rt1"),"rtb-tgt-left");
	MC.canvas.connect($("#vgw1"),"vgw-tgt",$("#rt1"),"rtb-tgt-right");

	MC.canvas.connect($("#cgw1"),"cgw-vpn",$("#vgw1"),"vgw-vpn");

};

define( ['jquery'], function() {
	return {
		'ready' : ready
	};
});