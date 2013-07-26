MC.canvas.add = function (flag, option, coordinate)
{
	var group = document.createElementNS("http://www.w3.org/2000/svg", 'g'),
		create_mode = true,
		type = '',
		class_type = '',
		component_data = {},
		component_layout = {},
		width = 100,
		height = 100,
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

		//get parent group
		if (option.groupUId && option.groupUId != 'Canvas' )
		{
			var group_layout = MC.canvas_data.layout.component.group[ option.groupUId ];
			option.group = {};

			switch (group_layout.type)
			{
				case 'AWS.EC2.AvailabilityZone':
					option.group.availableZoneName = group_layout.name;
					option.group.vpcUId = $(".AWS-VPC-VPC")[0] ? $(".AWS-VPC-VPC")[0].id : '' ;
					break;
				case 'AWS.VPC.Subnet':
					var gropu_comp = MC.canvas_data.component[ option.groupUId ];
					option.group.subnetUId = option.groupUId;
					option.group.availableZoneName = gropu_comp.resource.AvailabilityZone;
					option.group.vpcUId = $(".AWS-VPC-VPC")[0].id;
					break;
				case 'AWS.VPC.VPC':
					option.group.vpcUId = $(".AWS-VPC-VPC")[0].id;
					break;
			}
		}
	}

	class_type = type.replace(/\./ig, '-'); // type is resource type

	switch (type) {

		//***** az begin *****//
		case 'AWS.EC2.AvailabilityZone':

			if (create_mode)
			{//write
				component_layout = $.extend(true, {}, MC.canvas.AZ_JSON.layout);
				component_layout.name = option.name;

				$.each($(".resource-item"), function ( idx, item){

					var data = $(item).data();

					if(data.type === 'AWS.EC2.AvailabilityZone' && data.option.name === option.name){
						$(item)
							.data('enable', false)
							.addClass('resource-disabled')
							.removeClass("tooltip");
						return false;
					}
				});

				size = MC.canvas.GROUP_DEFAULT_SIZE[ type ];
				option.width = size[0];
				option.height = size[1];

				component_layout.groupUId = option.groupUId;
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
					'class': 'group group-az',
					'rx': 5,
					'ry': 5
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
				Canvon.text(MC.canvas.GROUP_LABEL_COORDINATE[ type ][0], MC.canvas.GROUP_LABEL_COORDINATE[ type ][1], option.name).attr({
					'class': 'group-label name',
					'id': group.id + '_name'
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

				size = MC.canvas.GROUP_DEFAULT_SIZE[ type ];
				option.width = size[0];
				option.height = size[1];
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
					'class': 'group group-vpc',
					'rx': 5,
					'ry': 5
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
				Canvon.text(MC.canvas.GROUP_LABEL_COORDINATE[ type ][0], MC.canvas.GROUP_LABEL_COORDINATE[ type ][1], option.name).attr({
					'class': 'group-label name',
					'id': group.id + '_name'
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
				component_data.resource.VpcId = "@" + option.group.vpcUId + '.resource.VpcId';
				component_data.resource.AvailabilityZone = option.group.availableZoneName;

				component_layout = $.extend(true, {}, MC.canvas.SUBNET_JSON.layout);
				component_layout.groupUId = option.groupUId;

				size = MC.canvas.GROUP_DEFAULT_SIZE[ type ];
				option.width = size[0];
				option.height = size[1];
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
					'class': 'group group-subnet',
					'rx': 5,
					'ry': 5
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

				//3 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-subnet-association-in',
					'transform': 'translate(-12, ' + ((height / 2) - 13) + ')', //port position: right:0 top:-90 left:-180 bottom:-270
					'data-name': 'subnet-association-in', //for identify port
					'data-position': 'left', //port position: for calc point of junction
					'data-type': 'association', //color of line
					'data-direction': 'in', //direction
					'data-angle': MC.canvas.PORT_LEFT_ANGLE //port angle: right:0 top:90 left:180 bottom:270
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-subnet-association-out',
					'transform': 'translate(' + (width + 4) + ', ' + ((height / 2) - 13) + ')',
					'data-name': 'subnet-association-out',
					'data-position': 'right',
					'data-type': 'association',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5.subnet label
				Canvon.text(MC.canvas.GROUP_LABEL_COORDINATE[ type ][0], MC.canvas.GROUP_LABEL_COORDINATE[ type ][1], option.name).attr({
					'class': 'group-label name',
					'id': group.id + '_name'
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

			var os_type = 'ami-unknown',
				volume_number = 0,
				icon_volume_status = 'not-attached',
				eni = null;

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.INSTANCE_JSON.data);
				component_data.name = option.name;

				component_data.resource.ImageId = option.imageId;
				component_data.resource.InstanceType = 'm1.small';
				component_data.resource.Placement.AvailabilityZone = option.group.availableZoneName;

				// if not kp
				if(MC.canvas_property.kp_list.length === 0){

					//default kp

				}

				component_data.resource.KeyName = "@"+MC.canvas_property.kp_list[0].DefaultKP + ".resource.KeyName";
				component_data.resource.SecurityGroupId.push("@"+MC.canvas_property.sg_list[0].uid + ".resource.GroupId");
				MC.canvas_property.sg_list[0].member.push(group.id);

				// if subnet
				if(MC.canvas_data.platform !== MC.canvas.PLATFORM_TYPE.EC2_CLASSIC){

					//default eni
					eni = $.extend(true, {}, MC.canvas.ENI_JSON.data);
					uid = MC.guid();
					eni.uid = uid;
					eni.name = "eni0";
					eni.resource.Attachment.DeviceIndex = "0";
					eni.resource.Attachment.InstanceId = "@"+group.id+".resource.InstanceId";
					eni.resource.AvailabilityZone = component_data.resource.Placement.AvailabilityZone;
					var sg_group = {};
					sg_group.GroupId = '@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupId';
					sg_group.GroupName = '@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupName';
					eni.resource.GroupSet.push(sg_group);

					if (MC.canvas_data.platform !== MC.canvas.PLATFORM_TYPE.DEFAULT_VPC){
						component_data.resource.SubnetId = '@' + option.group.subnetUId + '.resource.SubnetId';
						component_data.resource.VpcId = '@' + option.group.vpcUId + '.resource.VpcId';
						eni.resource.SubnetId = component_data.resource.SubnetId;
						eni.resource.VpcId = component_data.resource.VpcId;
					}

				}

				component_layout = $.extend(true, {}, MC.canvas.INSTANCE_JSON.layout);
				component_layout.groupUId = option.groupUId;
				component_layout.osType =  option.osType;
				component_layout.architecture =  option.architecture;
				component_layout.rootDeviceType =  option.rootDeviceType;
				component_layout.virtualizationType = option.virtualizationType;

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
				option.virtualizationType = component_layout.virtualizationType;
			}

			//os type
			os_type = option.osType + '.' + option.architecture + '.' + option.rootDeviceType;

			//check volume number,set icon
			volume_number = component_data.resource.BlockDeviceMapping.length;
			if (volume_number > 0)
			{
				icon_volume_status = 'attached-normal';
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width , height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/Instance-Canvas.png', 15, 8, 70, 70),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-instance-sg port-instance-sg-left',
					'transform': 'translate(8, 26)' + MC.canvas.PORT_RIGHT_ROTATE, //port position: right:0 top:-90 left:-180 bottom:-270
					'data-name': 'instance-sg', //for identify port
					'data-position': 'left', //port position: for calc point of junction
					'data-type': 'sg', //color of line
					'data-direction': 'in', //direction
					'data-angle': MC.canvas.PORT_LEFT_ANGLE //port angle: right:0 top:90 left:180 bottom:270
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-instance-sg port-instance-sg-right',
					'transform': 'translate(84, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'instance-sg',
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

				////6.1 volume-attached
				Canvon.image('../assets/images/ide/icon/instance-volume-' + icon_volume_status + '.png' , 21, 48, 29, 24).attr({
					'id': group.id + '_volume_status'
				}),

				//6.2 volume number
				Canvon.text(35, 60, volume_number).attr({
					'class': 'node-label volume-number',
					'id': group.id + '_volume_number'
				}),

				//6.3 hot area for volume
				Canvon.rectangle(21, 48, 29, 24).attr({
					'class': 'instance-volume',
					'data-target-id': group.id,
					'fill': 'none'
				}),

				////7. eip
				Canvon.image(MC.canvas.IMAGE.EIP_OFF, 58, 49, 14, 17).attr({
					'id': group.id + '_eip_status'
				}),

				////8. hostname
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name',
					'id': group.id + '_hostname'
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

			if(eni){
				data[eni.uid] = eni;
				MC.canvas.data.set('component', data);
			}
			$('#node_layer').append(group);

			break;
		//***** instance end *****//


		//***** volume begin *****//
		case 'AWS.EC2.EBS.Volume':

			if (create_mode)
			{//write

				//set deviceName
				ami_info = MC.data.config[MC.canvas_data.component[option.instance_id].resource.Placement.AvailabilityZone.slice(0,-1)].ami[MC.canvas_data.component[option.instance_id].resource.ImageId];
				device_name = null;
				if(ami_info.virtualizationType != 'hvm'){
					device_name = ['f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
				}
				else{
					device_name = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p'];
				}


				$.each(ami_info.blockDeviceMapping, function (key, value){
					if(key.slice(0,4) == '/dev/'){
						k = key.slice(-1);
						index = device_name.indexOf(k);
						if(index>=0){
							device_name.splice(index, 1);
						}
					}
				});
				$.each(MC.canvas_data.component[option.instance_id].resource.BlockDeviceMapping, function (key, value){
					volume_uid = value.slice(1);
					k = MC.canvas_data.component[volume_uid].name.slice(-1);
					index = device_name.indexOf(k);
					if(index>=0){
						device_name.splice(index, 1);
					}
				});
				if (device_name.length === 0)
				{
					//no valid deviceName
					notification('warning', 'No valid device name to assign,cancel!', false);
					return null;
				}

				if(ami_info.virtualizationType != 'hvm'){
					option.name = '/dev/sd' + device_name[0];
				}else{
					option.name = 'xvd' + device_name[0];
				}


				component_data = $.extend(true, {}, MC.canvas.VOLUME_JSON.data);
				component_data.name = option.name;
				component_data.resource.Size = option.volumeSize;
				component_data.resource.AttachmentSet.InstanceId = '@' + option.instance_id + '.resource.InstanceId';
				component_data.resource.AvailabilityZone = MC.canvas_data.component[option.instance_id].resource.Placement.AvailabilityZone;
				component_data.resource.SnapshotId = option.snapshotId;

				component_data.resource.AttachmentSet.Device =  option.name;

				if (option.snapshotId)
				{
					component_data.resource.SnapshotId = option.snapshotId;
				}
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;
				option.volumeSize = component_data.resource.AttachmentSet.Size;
			}

			//set data
			component_data.uid = group.id;
			data[group.id] = component_data;
			MC.canvas.data.set('component', data);

			return group;

			break;
		//***** volume end *****//

		//***** elb begin *****//
		case 'AWS.ELB':

			var icon_scheme = 'internal';

			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.ELB_JSON.data);
				component_data.name = option.name;
				component_data.resource.LoadBalancerName = option.name;

				if(MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.EC2_VPC || MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.CUSTOM_VPC){

					component_data.resource.VpcId = '@' + option.group.vpcUId + '.resource.VpdId';
					component_data.resource.SecurityGroups.push('@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupId');

				}else if (MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.DEFAULT_VPC){
					component_data.resource.SecurityGroups.push('@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupId');
				}else {
					component_data.resource.Scheme = 'internet-facing'
				}

				component_layout = $.extend(true, {}, MC.canvas.ELB_JSON.layout);
				component_layout.groupUId = option.groupUId;

				component_data.resource.Scheme = icon_scheme;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];

				icon_scheme = component_data.resource.Scheme;
			}

			icon_scheme = component_data.resource.Scheme === 'internal' ? 'internal' : 'internet';

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/elb-' + icon_scheme + '-canvas.png', 15, 28, 70, 53).attr({
					'id' : group.id + '_elb_scheme'
				}),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'id' : group.id + '_elb_sg_in',
					'class': 'port port-blue port-elb-sg-in',
					'transform': 'translate(7, 45)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-sg-in',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'id' : group.id + '_elb_sg_out',
					'class': 'port port-blue port-elb-sg-out',
					'transform': 'translate(85, 56)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-sg-out',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'id' : group.id + '_elb_assoc',
					'class': 'port port-gray port-elb-assoc',
					'transform': 'translate(85, 32)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'elb-assoc',
					'data-position': 'right',
					'data-type': 'association',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5. elb_name
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name',
					'id' : group.id + '_elb_name'
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
			main_icon = '';
			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.ROUTETABLE_JSON.data);
				component_data.name = option.name;
				if(MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.EC2_VPC || MC.canvas_data.platform === MC.canvas.PLATFORM_TYPE.CUSTOM_VPC){
					component_data.resource.VpcId = '@' + option.group.vpcUId + '.resource.VpdId';
				}
				if(option.main){
					main_icon = "main-";
				}

				component_layout = $.extend(true, {}, MC.canvas.ROUTETABLE_JSON.layout);
				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;
				if(component_data.resource.AssociationSet.length > 0 && component_data.resource.AssociationSet[0].Main === 'true'){
					main_icon = "main-";
				}
				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/RT-'+main_icon+'canvas.png', 10, 13, 60, 57).attr({
					'id': group.id + '_rt_status'
				}),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-rtb-tgt-left',
					'transform': 'translate(11, 25)' + MC.canvas.PORT_LEFT_ROTATE,
					'data-name': 'rtb-tgt-left',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-rtb-tgt-right',
					'transform': 'translate(69, 25)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'rtb-tgt-right',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				//4 path: top port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-rtb-src port-rtb-src-top',
					'transform': 'translate(41, -4)' + MC.canvas.PORT_UP_ROTATE,
					'data-name': 'rtb-src',
					'data-position': 'top',
					'data-type': 'association',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_UP_ANGLE
				}),

				//5 path: bottom port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-gray port-rtb-src port-rtb-src-bottom',
					'transform': 'translate(41, 66)' + MC.canvas.PORT_DOWN_ROTATE,
					'data-name': 'rtb-src',
					'data-position': 'bottom',
					'data-type': 'association',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_DOWN_ANGLE
				}),

				////6. routetable name
				Canvon.text(41, 30, option.name).attr({
					'class': 'node-label name',
					'id': group.id + '_rt_name'
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
				component_data.resource.AttachmentSet[0].VpcId = '@' + option.group.vpcUId + '.resource.VpdId';

				// disable drag when add one

				$.each($(".resource-item"), function ( idx, item){

					var data = $(item).data();

					if(data.type === 'AWS.VPC.InternetGateway'){
						$(item)
							.data('enable', false)
							.addClass('resource-disabled')
							.data("tooltip", "VPC can only have one IGW. There is already one IGW in current VPC.");
						return false;
					}
				});

				component_layout = $.extend(true, {}, MC.canvas.IGW_JSON.layout);
				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/igw-canvas.png', 10, 15, 60, 46),

				//2 path: left port
				// Canvon.path(MC.canvas.PATH_D_PORT).attr({
				// 	'class': 'port port-blue port-igw-unknown',
				// 	'transform': 'translate(12, 25)' + MC.canvas.PORT_LEFT_ROTATE,
				// 	'data-name': 'igw-unknown',
				// 	'data-position': 'left',
				// 	'data-type': 'sg',
				// 	'data-direction': 'out',
				// 	'data-angle': MC.canvas.PORT_LEFT_ANGLE
				// }),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-igw-tgt',
					'transform': 'translate(76, 25)' + MC.canvas.PORT_LEFT_ROTATE,
					'data-name': 'igw-tgt',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////4. igw name
				Canvon.text(40, 70, option.name).attr({
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
				component_data.resource.Attachments[0].VpcId = '@' + option.group.vpcUId + '.resource.VpdId';
				$.each($(".resource-item"), function ( idx, item){

					var data = $(item).data();

					if(data.type === 'AWS.VPC.VPNGateway'){
						$(item)
							.data('enable', false)
							.addClass('resource-disabled')
							.data("tooltip", "VPC can only have one VGW. There is already one VGW in current VPC.");
						return false;
					}
				});
				component_layout = $.extend(true, {}, MC.canvas.VGW_JSON.layout);
				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/vgw-canvas.png', 10, 15, 60, 46),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-blue port-vgw-tgt',
					'transform': 'translate(4, 25)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'vgw-tgt',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-purple port-vgw-vpn',
					'transform': 'translate(69, 25)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'vgw-vpn',
					'data-position': 'right',
					'data-type': 'vpn',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////4. vgw name
				Canvon.text(40, 70, option.name).attr({
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

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),
				Canvon.image('../assets/images/ide/icon/cgw-canvas.png', 13, 10, 167, 76),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-purple port-cgw-vpn',
					'transform': 'translate(7, 35)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'cgw-vpn',
					'data-position': 'left',
					'data-type': 'vpn',
					'data-direction': 'in',
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				////3. cgw name
				Canvon.text(50, 90, option.name).attr({
					'class': 'node-label name',
					'id': group.id + '_name'
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

			var attached = 'unattached';
			if (create_mode)
			{//write
				component_data = $.extend(true, {}, MC.canvas.ENI_JSON.data);
				component_data.name = option.name;
				component_data.resource.SubnetId = '@' + option.group.subnetUId + '.resource.SubnetId';
				component_data.resource.VpcId = '@' + option.group.vpcUId + '.resource.SubnetId';

				var sg_group = {};
				sg_group.GroupId = '@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupId';
				sg_group.GroupName = '@' + MC.canvas_property.sg_list[0].uid + '.resource.GroupName';
				component_data.resource.GroupSet.push(sg_group);

				component_layout = $.extend(true, {}, MC.canvas.ENI_JSON.layout);
				component_layout.groupUId = option.groupUId;
			}
			else
			{//read
				component_data = data[group.id];
				option.name = component_data.name;

				if(component_data.resource.Attachment.InstanceId){
					attached = 'attached'
				}

				component_layout = layout.node[group.id];

				coordinate.x = component_layout.coordinate[0];
				coordinate.y = component_layout.coordinate[1];
			}

			width = MC.canvas.COMPONENT_SIZE[type][0] * MC.canvas.GRID_WIDTH;
			height = MC.canvas.COMPONENT_SIZE[type][1] * MC.canvas.GRID_HEIGHT;

			$(group).append(
				////1. bg
				Canvon.rectangle(0, 0, width, height).attr({
					'class': 'node-background',
					'rx': 5,
					'ry': 5
				}),

				Canvon.image('../assets/images/ide/icon/eni-canvas-'+attached+'.png', 16, 28, 68, 53).attr({
					'id': group.id + '_eni_status'
				}),

				Canvon.image(MC.canvas.IMAGE.EIP_OFF, 46, 50, 14, 17).attr({
					'id': group.id + '_eip_status'
				}),

				//2 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-eni-sg port-eni-sg-left',
					'transform': 'translate(7, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-sg',
					'data-position': 'left',
					'data-type': 'sg',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//3 path: left port
				Canvon.path(MC.canvas.PATH_D_PORT).attr({
					'class': 'port port-green port-eni-attach',
					'transform': 'translate(7, 52)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-attach',
					'data-position': 'left',
					'data-type': 'attachment',
					'data-direction': "in",
					'data-angle': MC.canvas.PORT_LEFT_ANGLE
				}),

				//4 path: right port
				Canvon.path(MC.canvas.PATH_D_PORT2).attr({
					'class': 'port port-blue port-eni-sg port-eni-sg-right',
					'transform': 'translate(85, 26)' + MC.canvas.PORT_RIGHT_ROTATE,
					'data-name': 'eni-sg',
					'data-position': 'right',
					'data-type': 'sg',
					'data-direction': 'out',
					'data-angle': MC.canvas.PORT_RIGHT_ANGLE
				}),

				////5. eni_name
				Canvon.text(43, 85, option.name, {
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

	if (create_mode)
	{
		$("#svg_canvas").trigger("CANVAS_COMPONENT_CREATE", group.id);
	}

	return group;
};
