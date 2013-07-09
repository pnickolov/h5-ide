MC.canvas.add = function (flag, option, coordinate)
{

	var group = document.createElementNS("http://www.w3.org/2000/svg", 'g'),
		create_mode = true,
		type = '',
		class_type = '',
		component_data = {},
		component_layout = {},
		width = 140,
		height = 120,
		pad = 10,
		top = 0;

	data = MC.canvas.data.get('component');
	layout = MC.canvas.data.get('layout.component');

	if (!option && !coordinate)
	{
		//existed resource ( init data from MC.tab[tab_id].data )
		create_mode = false;

		option = {};
		coordinate = {};

		group.id = flag; //flag is uid
		type = !data[ group.id ] ? layout.group[ group.id ].type : data[ group.id ].type;
	}
	else
	{
		//new resource ( init data from option and layout )
		create_mode = true;

		group.id = MC.guid();
		type = flag; //flag is resource type
	}
	class_type = type.replace(/\./ig, '-'); // type is resource type

	switch (type) {

		//***** az begin *****//
		case 'AWS.EC2.AvailabilityZone':

			if (create_mode)
			{//write
				component_layout = $.extend(true, {}, MC.canvas.AZ_JSON.layout);
				component_layout.name = option.name;

				option.width = 30;
				option.height = 30;
			}
			else
			{//read
				component_layout = layout.group[group.id];
				option.name = component_layout.name;

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.width = component_layout.size[0];
				option.height = component_layout.size[1];
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
					).attr({'class': 'group-resizer resizer-topleft', 'data-direction': 'topleft'}),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-top', 'data-direction': 'top'}),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr({'class': 'group-resizer resizer-topright', 'data-direction': 'topright'}),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-left', 'data-direction': 'left'}),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-right', 'data-direction': 'right'}),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomleft', 'data-direction': 'bottomleft'}),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-bottom', 'data-direction': 'bottom'}),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomright', 'data-direction': 'bottomright'})
				).attr({
					'class': 'resizer-wrap'
				}),

				////3.az label
				Canvon.text(1, MC.canvas.GROUP_LABEL_OFFSET, option.name).attr({
					'class': 'group-label name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group',
				'data-class': type
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
				component_data = $.extend(true, {}, MC.canvas.VPC_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.VPC_JSON.layout);

				option.width = 60;
				option.height = 60;
			}
			else
			{
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.group[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.width = component_layout.size[0];
				option.height = component_layout.size[1];
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
					).attr({'class': 'group-resizer resizer-topleft', 'data-direction': 'topleft'}),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-top', 'data-direction': 'top'}),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr({'class': 'group-resizer resizer-topright', 'data-direction': 'topright'}),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-left', 'data-direction': 'left'}),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-right', 'data-direction': 'right'}),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomleft', 'data-direction': 'bottomleft'}),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-bottom', 'data-direction': 'bottom'}),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomright', 'data-direction': 'bottomright'})
				).attr({
					'class': 'resizer-wrap'
				}),

				////3.vpc label
				Canvon.text(1, MC.canvas.GROUP_LABEL_OFFSET, option.name).attr({
					'class': 'group-label name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group',
				'data-class': type
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
				component_data = $.extend(true, {}, MC.canvas.SUBNET_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.SUBNET_JSON.layout);

				option.width = 20;
				option.height = 20;
			}
			else
			{
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.group[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.width = component_layout.size[0];
				option.height = component_layout.size[1];
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
					).attr({'class': 'group-resizer resizer-topleft', 'data-direction': 'topleft'}),
					Canvon.rectangle(
						pad, top, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-top', 'data-direction': 'top'}),
					Canvon.rectangle(
						width - pad, top, pad, pad
					).attr({'class': 'group-resizer resizer-topright', 'data-direction': 'topright'}),
					Canvon.rectangle(
						0, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-left', 'data-direction': 'left'}),
					Canvon.rectangle(
						width - pad, top + pad, pad, height - 2 * pad
					).attr({'class': 'group-resizer resizer-right', 'data-direction': 'right'}),
					Canvon.rectangle(
						0, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomleft', 'data-direction': 'bottomleft'}),
					Canvon.rectangle(
						pad, height + top - pad, width - 2 * pad, pad
					).attr({'class': 'group-resizer resizer-bottom', 'data-direction': 'bottom'}),
					Canvon.rectangle(
						width - pad, height + top - pad, pad, pad
					).attr({'class': 'group-resizer resizer-bottomright', 'data-direction': 'bottomright'})
				).attr({
					'class': 'resizer-wrap'
				}),

				////3.subnet label
				Canvon.text(1, MC.canvas.GROUP_LABEL_OFFSET, option.name).attr({
					'class': 'group-label name'
				})

			).attr({
				'class': 'dragable ' + class_type,
				'data-type': 'group',
				'data-class': type
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
			{//write
				component_data = $.extend(true, {}, MC.canvas.INSTANCE_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.INSTANCE_JSON.layout);
				component_layout.osType =  option.osType;
				component_layout.architecture =  option.architecture;
				component_layout.rootDeviceType =  option.rootDeviceType;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.osType = component_layout.osType ;
				option.architecture = component_layout.architecture ;
				option.rootDeviceType = component_layout.rootDeviceType ;
			}
			os_type = option.osType + '.' + option.architecture + '.' + option.rootDeviceType;

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
					'transform': 'translate(8, 26)' + MC.canvas.PORT_RIGHT_ROTATE, //port position: right:0 top:-90 left:-180 bottom:-270
					'data-name': 'instance-sg-in', //for identify port
					'data-position': 'left', //port position: for calc point of junction
					'data-type': 'sg', //color of line
					'data-direction': 'in', //direction
					'data-angle': MC.canvas.PORT_LEFT_ANGLE //port angle: right:0 top:90 left:180 bottom:270
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-instance-sg-out',
					'transform': 'translate(84, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'instance-sg-out',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-instance-attach',
					'transform': 'translate(84, 52)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'instance-attach',
					'data-position': 'right',
					'data-type': 'attachment',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
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
				'data-type': 'node',
				'data-class': type
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
			{//write
				component_data = $.extend(true, {}, MC.canvas.VOLUME_JSON.data);
				component_data.name = option.name;
				component_data.resource.AttachmentSet.Size = option.volumeSize;

				component_layout = $.extend(true, {}, MC.canvas.VOLUME_JSON.layout);
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;
				option.volumeSize = component_data.resource.AttachmentSet.Size;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 100, 100).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/VOL-Canvas.png', 18, 20, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-volume-attach',
					'transform': 'translate(22, 62)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'volume-attach',
					'data-position': 'left',
					'data-type': 'attachment',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				////3. device-name
				Canvon.text(50, 40, option.name).attr({
					'class': 'node-label device-name'
				}),

				////3. volume-size
				Canvon.text(50, 65, option.volumeSize + " GiB").attr({
					'class': 'node-label volume-size'
				})

			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
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
			{//write
				component_data = $.extend(true, {}, MC.canvas.ELB_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.ELB_JSON.layout);
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 100, 100).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/ELB-Canvas.png', 20, 23, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-elb-sg-in',
					'transform': 'translate(12, 50)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-sg-in',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-elb-sg-out',
					'transform': 'translate(90, 62)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-sg-out',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-elb-assoc',
					'transform': 'translate(90, 37)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-assoc',
					'data-position': 'right',
					'data-type': 'association',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5. elb_name
				Canvon.text(50, 60, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
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
			{//write
				component_data = $.extend(true, {}, MC.canvas.ROUTETABLE_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.ROUTETABLE_JSON.layout);
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 100, 100).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/RTB-Canvas.png', 15, 15, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-rtb-tgt-left',
					'transform': 'translate(21, 50)' + MC.canvas.PORT_LEFT_ROTATE,
					'data-name': 'rtb-tgt-left',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-rtb-tgt-right',
					'transform': 'translate(81, 50)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'rtb-tgt-right',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: top port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-rtb-src-top',
					'transform': 'translate(50, 3)' + MC.canvas.PORT_UP_ROTATE,
					'data-name': 'rtb-src-top',
					'data-position': 'top',
					'data-type': 'association',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_UP_ANGLE
				}),

				//5 path: bottom port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-rtb-src-bottom',
					'transform': 'translate(50, 80)' + MC.canvas.PORT_DOWN_ROTATE,
					'data-name': 'rtb-src-bottom',
					'data-position': 'bottom',
					'data-type': 'association',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_DOWN_ANGLE
				}),

				////6. routetable name
				Canvon.text(50, 33, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
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
			{//write
				component_data = $.extend(true, {}, MC.canvas.IGW_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.IGW_JSON.layout);
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 100, 100).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/IGW-Canvas.png', 15, 15, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-igw-unknown',
					'transform': 'translate(20, 50)' + MC.canvas.PORT_LEFT_ROTATE,
					'data-name': 'igw-unknown',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-igw-tgt',
					'transform': 'translate(87, 50)' + MC.canvas.PORT_LEFT_ROTATE,
					'data-name': 'igw-tgt',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////4. igw name
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
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
			{//write
				component_data = $.extend(true, {}, MC.canvas.VGW_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.VGW_JSON.layout);
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 100, 100).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/VGW-Canvas.png', 15, 15, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-vgw-tgt',
					'transform': 'translate(12, 50)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'vgw-tgt',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-purple port-vgw-vpn',
					'transform': 'translate(80, 50)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'vgw-vpn',
					'data-position': 'right',
					'data-type': 'vpn',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////4. vgw name
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
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
			{//write
				component_data = $.extend(true, {}, MC.canvas.CGW_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.CGW_JSON.layout);
				component_layout.networkName = option.networkName;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				option.networkName = component_layout.networkName;
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 100, 100).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/CGW-Canvas.png', 15, 15, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-purple port-cgw-vpn',
					'transform': 'translate(2, 50)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'cgw-vpn',
					'data-position': 'left',
					'data-type': 'vpn',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				////3. cgw name
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name'
				}),

				////4. network name
				Canvon.text(100, 95, option.networkName).attr({
					'class': 'node-label network-name'
				})

			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
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
			{//write
				component_data = $.extend(true, {}, MC.canvas.ENI_JSON.data);
				component_data.name = option.name;

				component_layout = $.extend(true, {}, MC.canvas.ENI_JSON.layout);
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, 100, 100).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/ENI-Canvas.png', 15, 25, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-eni-sg-in',
					'transform': 'translate(12, 37)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-sg-in',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-eni-attach',
					'transform': 'translate(12, 62)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-attach',
					'data-position': 'left',
					'data-type': 'attachment',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-eni-sg-out',
					'transform': 'translate(80, 38)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-sg-out',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5. eni_name
				Canvon.text(32, 60, option.name, {
					'text-anchor': 'start' // start, middle(default), end, inherit
				}).attr({
					'class': 'node-label name'
				})
			).attr({
				'class': 'dragable node ' + class_type,
				'data-type': 'node',
				'data-class': type
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
