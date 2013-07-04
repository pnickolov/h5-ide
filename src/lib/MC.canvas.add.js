MC.canvas.add = function (type, option, coordinate)
{

	var group = document.createElementNS("http://www.w3.org/2000/svg", 'g'),
		create_mode = true,
		class_type = type.replace(/\./ig, '-'),
		component_data = {},
		component_layout = {},
		width = 140,
		height = 120,
		pad = 10,
		top = 0;

	group.id = option.uid;
	data = MC.canvas.data.get('component');
	layout = MC.canvas.data.get('layout.component');

	if ( !option && !coordinate )
	{
		//existed resource ( init data from MC.tab[tab_id].data )
		//option = {};
		//coordinate = {};
		create_mode = false;
	}
	else
	{
		//new resource ( init data from option and layout )
		class_type = type.replace(/\./ig, '-');
		group.id = MC.guid();
		create_mode = true;
	}

	switch (type) {

		//***** az begin *****//
		case 'AWS.EC2.AvailabilityZone':

			if (create_mode)
			{
				option.width = 44;
				option.height = 51;
				$.extend(true, component_layout, MC.canvas.AZ_JSON.layout);
			}

			width = option.width * MC.canvas.GRID_WIDTH,
			height = option.height * MC.canvas.GRID_HEIGHT,

			$(group).append(

				////1. area
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'group group-az'
				}),

				////2.scale area
				Canvon.group().append(
					Canvon.rectangle(
						0, top, pad, pad
					).attr('class', 'group-resizer resizer-topleft').data('direction', 'topleft'),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr('class', 'group-resizer resizer-top').data('direction', 'top'),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr('class', 'group-resizer resizer-topright').data('direction', 'topright'),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr('class', 'group-resizer resizer-left').data('direction', 'left'),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr('class', 'group-resizer resizer-right').data('direction', 'right'),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr('class', 'group-resizer resizer-bottomleft').data('direction', 'bottomleft'),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr('class', 'group-resizer resizer-bottom').data('direction', 'bottom'),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr('class', 'group-resizer resizer-bottomright').data('direction', 'bottomright')
				).attr({
					'class': 'resizer-wrap'
				}),

				////3.az label
				Canvon.text(1, MC.canvas.GROUP_LABEL_OFFSET, option.name).attr({
					'class': 'group-label name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group'
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			component_layout.size = [option.width, option.height];
			layout.group[group.id] = component_layout;
			MC.canvas.data.set('layout.component.group', layout.group);

			$('#az_layer').append(group);

			break;
		//***** az end *****//

		//***** vpc begin *****//
		case 'AWS.VPC.VPC':

			if (create_mode)
			{
				option.width = 79;
				option.height = 69;
				$.extend(true, component_layout, MC.canvas.VPC_JSON.layout);
				$.extend(true, component_data, MC.canvas.VPC_JSON.data);
			}

			width = option.width * MC.canvas.GRID_WIDTH,
			height = option.height * MC.canvas.GRID_HEIGHT,

			$(group).append(

				////1. area
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'group group-vpc'
				}),

				////2.scale area
				Canvon.group().append(
					Canvon.rectangle(
						0, top, pad, pad
					).attr('class', 'group-resizer resizer-topleft').data('direction', 'topleft'),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr('class', 'group-resizer resizer-top').data('direction', 'top'),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr('class', 'group-resizer resizer-topright').data('direction', 'topright'),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr('class', 'group-resizer resizer-left').data('direction', 'left'),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr('class', 'group-resizer resizer-right').data('direction', 'right'),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr('class', 'group-resizer resizer-bottomleft').data('direction', 'bottomleft'),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr('class', 'group-resizer resizer-bottom').data('direction', 'bottom'),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr('class', 'group-resizer resizer-bottomright').data('direction', 'bottomright')
				).attr({
					'class': 'resizer-wrap'
				}),

				////3.vpc label
				Canvon.text(1, MC.canvas.GROUP_LABEL_OFFSET, option.name).attr({
					'class': 'group-label name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group'
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			component_layout.size = [option.width, option.height];
			layout.group[group.id] = component_layout;
			MC.canvas.data.set('layout.component.group', layout.group);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#vpc_layer').append(group);

			break;
		//***** vpc end *****//

		//***** subnet begin *****//
		case 'AWS.VPC.Subnet':

			if (create_mode)
			{
				option.width = 36;
				option.height = 43;
				$.extend(true, component_layout, MC.canvas.SUBNET_JSON.layout);
				$.extend(true, component_data, MC.canvas.SUBNET_JSON.data);
			}

			width = option.width * MC.canvas.GRID_WIDTH,
			height = option.height * MC.canvas.GRID_HEIGHT,

			$(group).append(

				////1. area
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'group group-subnet'
				}),

				////2.scale area
				Canvon.group().append(
					Canvon.rectangle(
						0, top, pad, pad
					).attr('class', 'group-resizer resizer-topleft').data('direction', 'topleft'),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr('class', 'group-resizer resizer-top').data('direction', 'top'),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr('class', 'group-resizer resizer-topright').data('direction', 'topright'),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr('class', 'group-resizer resizer-left').data('direction', 'left'),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr('class', 'group-resizer resizer-right').data('direction', 'right'),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr('class', 'group-resizer resizer-bottomleft').data('direction', 'bottomleft'),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr('class', 'group-resizer resizer-bottom').data('direction', 'bottom'),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr('class', 'group-resizer resizer-bottomright').data('direction', 'bottomright')
				).attr({
					'class': 'resizer-wrap'
				}),

				////3.subnet label
				Canvon.text(1, MC.canvas.GROUP_LABEL_OFFSET, option.name).attr({
					'class': 'group-label name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group'
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			component_layout.size = [option.width, option.height];
			layout.group[group.id] = component_layout;
			MC.canvas.data.set('layout.component.group', layout.group);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#subnet_layer').append(group);

			break;
		//***** subnet end *****//

		//***** instance begin *****//
		case 'AWS.EC2.Instance':

			var os_type = 'ami-unknown';
			if (create_mode)
			{
				os_type = option.osType + '.' + option.architecture + '.' + option.rootDeviceType;
				$.extend(true, component_layout, MC.canvas.INSTANCE_JSON.layout);
				$.extend(true, component_data, MC.canvas.INSTANCE_JSON.data);
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 100, 100).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/Instance-Canvas.png', 15, 8, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-instance-sg-in',
					'transform': 'translate(8, 26)' + MC.canvas.PORT_RIGHT_ROTATE //port position: right:0 top:-90 left:-180 bottom:-270
				}).data({
					'name': 'instance-sg-in', //for identify port
					'position': 'left', //port position: for calc point of junction
					'type': 'sg', //color of line
					'direction': 'in', //direction
					'angle': MC.canvas.PORT_LEFT_ANGLE //port angle: right:0 top:90 left:180 bottom:270
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-instance-sg-out',
					'transform': 'translate(84, 26)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'instance-sg-out',
					'position': 'right',
					'type': 'sg',
					'direction': 'out',
					'angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-instance-attach',
					'transform': 'translate(84, 52)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'instance-attach',
					'position': 'right',
					'type': 'attachment',
					'direction': 'out',
					'angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5. os_type
				Canvon.image('../assets/images/ide/ami/' + os_type + '.png', 30, 15, 39, 27),

				////6. volume-attached
				Canvon.image('../assets/images/ide/icon/instance-volume-not-attached.png', 21, 48, 29, 24),

				////7. eip
				Canvon.image('../assets/images/ide/icon/instance-eip-off.png', 53, 50, 22, 16),

				////8. hostname
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node'
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** instance end *****//


		//***** volume begin *****//
		case 'AWS.EC2.EBS.Volume':

			if (create_mode)
			{
				$.extend(true, component_layout, MC.canvas.VOLUME_JSON.layout);
				$.extend(true, component_data, MC.canvas.VOLUME_JSON.data);
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 140, 120).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/VOL-Canvas.png', 0, 0, 140, 120),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-volume-attach',
					'transform': 'translate(26, 62)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'volume-attach',
					'position': 'left',
					'type': 'attachment',
					'direction': 'in',
					'angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				////3. device-name
				Canvon.text(68, 50, option.name).attr({
					'class': 'node-label device-name'
				}),

				////3. device-name
				Canvon.text(68, 65, option.volumeSize + " GiB").attr({
					'class': 'node-label volume-size'
				})

			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node'
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** volume end *****//

		//***** elb begin *****//
		case 'AWS.ELB':

			if (create_mode)
			{
				$.extend(true, component_layout, MC.canvas.ELB_JSON.layout);
				$.extend(true, component_data, MC.canvas.ELB_JSON.data);
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 140, 120).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/ELB-Canvas.png', 0, 0, 140, 120),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-elb-sg-in',
					'transform': 'translate(12, 50)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'elb-sg-in',
					'position': 'left',
					'type': 'sg',
					'direction': "in",
					'angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-elb-sg-out',
					'transform': 'translate(117, 62)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'elb-sg-out',
					'position': 'right',
					'type': 'sg',
					'direction': 'out',
					'angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-elb-assoc',
					'transform': 'translate(117, 37)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'elb-assoc',
					'position': 'right',
					'type': 'association',
					'direction': 'out',
					'angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5. elb_name
				Canvon.text(70, 60, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node'
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** elb end *****//

		//***** routetable begin *****//
		case 'AWS.VPC.RouteTable':

			if (create_mode)
			{
				$.extend(true, component_layout, MC.canvas.ROUTETABLE_JSON.layout);
				$.extend(true, component_data, MC.canvas.ROUTETABLE_JSON.data);
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 140, 120).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/RTB-Canvas.png', 0, 0, 140, 120),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-rtb-tgt-left',
					'transform': 'translate(41, 50)' + MC.canvas.PORT_LEFT_ROTATE
				}).data({
					'name': 'rtb-tgt-left',
					'position': 'left',
					'type': 'sg',
					'direction': 'out',
					'angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-rtb-tgt-right',
					'transform': 'translate(96, 50)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'rtb-tgt-right',
					'position': 'right',
					'type': 'sg',
					'direction': 'out',
					'angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: top port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-rtb-src-top',
					'transform': 'translate(70, 16)' + MC.canvas.PORT_TOP_ROTATE
				}).data({
					'name': 'rtb-src-top',
					'position': 'top',
					'type': 'association',
					'direction': 'in',
					'angle': MC.canvas.PORT_TOP_ANGLE
				}),

				//5 path: bottom port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-rtb-src-bottom',
					'transform': 'translate(70, 90)' + MC.canvas.PORT_BOTTOM_ROTATE
				}).data({
					'name': 'rtb-src-bottom',
					'position': 'bottom',
					'type': 'association',
					'direction': 'in',
					'angle': MC.canvas.PORT_BOTTOM_ANGLE
				}),

				////6. routetable name
				Canvon.text(70, 47, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node'
			});

			// set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			// set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** routetable end *****//

		//***** igw begin *****//
		case 'AWS.VPC.InternetGateway':

			if (create_mode)
			{
				$.extend(true, component_layout, MC.canvas.IGW_JSON.layout);
				$.extend(true, component_data, MC.canvas.IGW_JSON.data);
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 140, 120).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/IGW-Canvas.png', 0, 0, 140, 120),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-igw-unknown',
					'transform': 'translate(41, 50)' + MC.canvas.PORT_LEFT_ROTATE
				}).data({
					'name': 'igw-unknown',
					'position': 'left',
					'type': 'sg',
					'direction': 'out',
					'angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-igw-tgt',
					'transform': 'translate(104, 50)' + MC.canvas.PORT_LEFT_ROTATE
				}).data({
					'name': 'igw-tgt',
					'position': 'right',
					'type': 'sg',
					'direction': 'in',
					'angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////4. igw name
				Canvon.text(70, 100, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node'
			});

			// set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			// set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** igw end *****//

		//***** vgw begin *****//
		case 'AWS.VPC.VPNGateway':

			if (create_mode)
			{
				$.extend(true, component_layout, MC.canvas.VGW_JSON.layout);
				$.extend(true, component_data, MC.canvas.VGW_JSON.data);
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 140, 120).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/VGW-Canvas.png', 0, 0, 140, 120),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-vgw-tgt',
					'transform': 'translate(33, 50)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'vgw-tgt',
					'position': 'left',
					'type': 'sg',
					'direction': 'in',
					'angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-purple port-vgw-vpn',
					'transform': 'translate(96, 50)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'vgw-vpn',
					'position': 'right',
					'type': 'vpn',
					'direction': 'out',
					'angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////4. vgw name
				Canvon.text(70, 100, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node'
			});

			// set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			// set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** vgw end *****//

		//***** cgw begin *****//
		case 'AWS.VPC.CustomerGateway':

			if (create_mode)
			{
				$.extend(true, component_layout, MC.canvas.CGW_JSON.layout);
				$.extend(true, component_data, MC.canvas.CGW_JSON.data);
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 140, 120).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/CGW-Canvas.png', 0, 0, 140, 120),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-purple port-cgw-vpn',
					'transform': 'translate(-8, 50)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'cgw-vpn',
					'position': 'left',
					'type': 'vpn',
					'direction': 'in',
					'angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				////3. cgw name
				Canvon.text(20, 95, option.name).attr({
					'class': 'node-label name'
				}),

				////4. network name
				Canvon.text(100, 95, option.network_name).attr({
					'class': 'node-label network-name'
				})

			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node'
			});

			// set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			// set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
		//***** cgw end *****//


		//***** eni begin *****//
		case 'AWS.VPC.NetworkInterface':

			if (create_mode)
			{
				$.extend(true, component_layout, MC.canvas.ENI_JSON.layout);
				$.extend(true, component_data, MC.canvas.ENI_JSON.data);
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 140, 120).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/ENI-Canvas.png', 0, 0, 140, 120),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-eni-sg-in',
					'transform': 'translate(27, 37)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'eni-sg-in',
					'position': 'left',
					'type': 'sg',
					'direction': "in",
					'angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-eni-attach',
					'transform': 'translate(27, 62)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'eni-attach',
					'position': 'left',
					'type': 'attachment',
					'direction': "in",
					'angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-eni-sg-out',
					'transform': 'translate(102, 38)' + MC.canvas.PORT_RIGHT_ROTATE
				}).data({
					'name': 'eni-sg-out',
					'position': 'right',
					'type': 'sg',
					'direction': 'out',
					'angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5. eni_name
				Canvon.text(42, 60, option.name, {
					'text-anchor': 'start' // start, middle(default), end, inherit
				}).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node'
			});

			//set layout
			component_layout.coordinate = [coordinate.x, coordinate.y];
			layout.node[group.id] = component_layout;
			MC.canvas.data.set('layout.component.node', layout.node);

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			$('#node_layer').append(group);

			break;
			//***** eni end *****//

	}

	//set the node position
	MC.canvas.position(group, coordinate.x, coordinate.y);

	return group;
};
