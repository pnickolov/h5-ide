// MC.Canvas
// Author: Angel
MC.canvas = {
	zoomOut: function ()
	{
		var canvas_container = $('#canvas_container'),
			content = $('#main_body_content'),
			width = canvas_container.width(),
			height = canvas_container.height();

		scrollbar.scroll_to_top(content, 0);
		scrollbar.scroll_to_left(content, 0);

		canvas_container.css({
			'width': width / 2,
			'height': height / 2
		});

		$('#svg_canvas').css('zoom', 0.5);
		$('#node_container').css('zoom', 0.5);
		$('#canvas_body').addClass('zoomed');

		$('#top_btn_zoom_in').removeClass('disabled').on('click', MC.canvas.zoomIn);
		$('#top_btn_zoom_out').addClass('disabled').off('click', MC.canvas.zoomOut);
	},

	zoomIn: function ()
	{
		var canvas_container = $('#canvas_container'),
			width = canvas_container.width(),
			height = canvas_container.height();

		canvas_container.css({
			'width': width * 2,
			'height': height * 2
		});
		$('#svg_canvas').css('zoom', 1);
		$('#node_container').css('zoom', 1);
		$('#canvas_body').removeClass('zoomed');

		$('#top_btn_zoom_in').addClass('disabled').off('click', MC.canvas.zoomIn);
		$('#top_btn_zoom_out').removeClass('disabled').on('click', MC.canvas.zoomOut);
	},

	focused_node: [],
	/**
	 * Add node to canvas
	 * @param {boject} option 
	 * @param {[type]} x      [description]
	 * @param {[type]} y      [description]
	 */
	add: function (option, x, y)
	{
		var new_uid = MC.guid(),
			target_zoneX = Math.ceil(x / 140) - 1,
			target_zoneY = Math.ceil(y / 100) - 1;

		MC.canvas.create(new_uid, option);
		MC.canvas.position(new_uid, [target_zoneX, target_zoneY]);

		return new_uid;
	},

	// Create new component according option
	create: function (uid, option)
	{
		var html,
			property;

		switch (option.type)
		{
			case 'instance':
				html = '<div id="' + uid + '" class="instance node dragable focusable" data-placement="zone">' +
				'<div class="node_icon node_amazon"></div>' +
				'<div class="port_in_Firewall port connectable" data-connect-name="port_in_Firewall"></div>' +
				'<div class="port_out_SecurityGroup port connectable" data-connect-name="port_out_SecurityGroup" data-connect="port_in_Firewall" data-connect-color="#6d9ee1"></div>' +
				'<div class="port_out_Volume port connectable" data-connect-name="port_out_Volume" data-connect="port_in_Volume" data-connect-color="#97bf7d"></div>' +
				'<div class="attachment_keyPairs"></div>' +
				'<div class="attachment_eip"></div>' +
				'</div>';
				property = {
					"type": "instance",
					"class": "node",
					"connection": {
						"port_out_Volume": [],
						"port_in_Firewall": [],
						"port_out_SecurityGroup": []
					},
					"placement": "zone",
					"attachment": [],
					"coordinate": [0, 0],
					"size": [1, 1]
				};
				break;
			case 'volume':
				html = '<div id="' + uid + '" class="volume node dragable focusable" data-placement="zone">' +
				'<div class="port_in_Volume port connectable" data-connect-name="port_in_Volume"></div>' +
				'</div>';
				property = {
					"type": "volume",
					"class": "node",
					"connection": {
						"port_in_Volume": []
					},
					"placement": "zone",
					"coordinate": [0, 0],
					"size": [1, 1]
				};
				break;
			case 'elb':
				html = '<div id="' + uid + '" class="elb node dragable focusable" data-placement="canvas">' +
				'<div class="port_out_ELB port connectable" data-connect-name="port_out_ELB" data-connect="port_in_Firewall" data-connect-color="#6d9ee1"></div>' +
				'</div>';
				property = {
					"type": "elb",
					"class": "node",
					"connection": {
						"port_out_ELB": []
					},
					"placement": "canvas",
					"coordinate": [0, 0],
					"size": [1, 1]
				};
				break;
			case 'group':
				html = '<div id="' + uid + '" class="zone focusable dragable" data-placement="canvas">' + 
				'<div class="zone_title">' + option.name + '</div>' +
				'<div class="zone_resizer resizer_topleft" data-direction="topleft"></div>' +
				'<div class="zone_resizer resizer_topright" data-direction="topright"></div>' +
				'<div class="zone_resizer resizer_bottomleft" data-direction="bottomleft"></div>' +
				'<div class="zone_resizer resizer_bottomright" data-direction="bottomright"></div>' +
				'<div class="zone_resizer resizer_top" data-direction="top"></div>' +
				'<div class="zone_resizer resizer_right" data-direction="right"></div>' +
				'<div class="zone_resizer resizer_left" data-direction="left"></div>' +
				'<div class="zone_resizer resizer_bottom" data-direction="bottom"></div>' +
				'</div>';
				property = {
					"type": "group",
					"class": "zone",
					"name": "",
					"placement": "canvas",
					"coordinate": [0, 0],
					"size": [1, 1]
				};
				break;
		}

		$('#node_container').append(html);

		if (MC.layout_data[uid] == null)
		{
			$.each(option, function (name, value)
			{
				property[name] = value;
			});
			MC.layout_data[uid] = property;
		}
		else
		{
			if (MC.layout_data[uid]['class'] == 'zone')
			{
				if (option.type === 'group')
				{
					$('#' + uid).css({
						'width': MC.layout_data[uid]['size'][0] * 140 + 100,
						'height': MC.layout_data[uid]['size'][1] * 100 + 80
					});
				}
				else
				{
					$('#' + uid).css({
						'width': MC.layout_data[uid]['size'][0] * 140,
						'height': MC.layout_data[uid]['size'][1] * 100
					});
				}
			}
		}

		return html;
	},
	remove: function (node)
	{
		var node = $(node),
			node_id = node.attr('id'),
			node_data = MC.layout_data[node_id],
			connection;

		if (node_data)
		{
			connection = node_data['connection'];
		}
		if (connection)
		{
			$.each(connection, function (name, data)
			{
				$.each(data, function (key, item)
				{
					var data = item.SVG.data,
						start = MC.layout_data[data.start_uid]['connection'][data.start_target],
						end = MC.layout_data[data.end_uid]['connection'][data.end_target];

					start.splice(start.indexOf(data.start_connection), 1);
					end.splice(end.indexOf(data.end_connection), 1);
					MC.paper.clear(item.SVG);
				});
			});
		}

		node.remove();
		delete MC.layout_data[node_id];
	},
	// - component
	// - x: zone X
	// - y: zone Y
	// canvas 坐标 [2, 3]
	position: function (uid, coordinate)
	{
		if (coordinate[0] < 0 || coordinate[1] < 0)
		{
			return;
		}

		var node = $('#' + uid),
			node_class = MC.layout_data[uid]['class'],
			finalX,
			finalY;

		if (node_class == 'node')
		{
			finalX = coordinate[0] * 140 + ((140 - node.outerWidth()) / 2),
			finalY = coordinate[1] * 100 + ((100 - node.outerHeight()) / 2);
		}
		if (node_class == 'zone')
		{
			finalX = coordinate[0] * 140 - 50;
			finalY = coordinate[1] * 100 - 40;
		}

		MC.layout_data[uid]['coordinate'] = coordinate;
		node.css({
			'left': finalX,
			'top': finalY
		});
	},
	// Final 
	// - component
	// - x: drop X
	// - y: drop Y
	// 鼠标坐标 [231, 312]
	drop: function (uid, zoneX, zoneY)
	{
		var is_blank = true,
			connection;

		if (zoneX >= 0 && zoneY >= 0)
		{
			$.each(MC.layout_data, function (uid, item)
			{
				if (
					item.coordinate[0] == zoneX &&
					item.coordinate[1] == zoneY &&
					item.class == 'node'
				)
				{
					is_blank = false;
				}
			});
			if (is_blank)
			{
				MC.canvas.position(uid, [zoneX, zoneY]);
			}
			else
			{
				return;
			}
		}
		else
		{
			return;
		}

		connection = MC.layout_data[uid]['connection'];
		if (connection)
		{
			$.each(connection, function (name, data)
			{
				$.each(data, function (key, item)
				{
					MC.paper.clear(item.SVG);
					if (item.type == "out")
					{
						MC.canvas.connect($('#' + uid), name, $('#' + item.uid), item.target, item.color);
					}
					else
					{
						MC.canvas.connect($('#' + item.uid), item.target, $('#' + uid), name, item.color);
					}
				});
			});
		}
	},
	move: function (uid, zoneX, zoneY)
	{
		if (zoneX > 0 && zoneY > 0)
		{
			MC.canvas.position(uid, [zoneX, zoneY]);
		}
		else
		{
			return;
		}

		var connection = MC.layout_data[uid]['connection'];
		if (connection)
		{
			$.each(connection, function (name, data)
			{
				$.each(data, function (key, item)
				{
					MC.paper.clear(item.SVG);
					if (item.type == "out")
					{
						MC.canvas.connect($('#' + uid), name, $('#' + item.uid), item.target, item.color);
					}
					else
					{
						MC.canvas.connect($('#' + item.uid), item.target, $('#' + uid), name, item.color);
					}
				});
			});
		}
	},
	connect: function (start_node, start_target, end_node, end_target, color)
	{
		var canvas_offset = $('#svg_canvas').offset(),
			start_uid = start_node.attr('id'),
			end_uid = end_node.attr('id'),
			start_port = start_node.find('.' + start_target),
			end_port = end_node.find('.' + end_target),
			start_port_offset = start_port.offset(),
			end_port_offset = end_port.offset(),
			startX = start_port_offset.left - canvas_offset.left + start_port.width(),
			startY = start_port_offset.top - canvas_offset.top + (start_port.height() / 2),
			endX = end_port_offset.left - canvas_offset.left,
			endY = end_port_offset.top - canvas_offset.top + (start_port.height() / 2),
			start_connection,
			end_connection,
			paddingY,
			connector,
			is_start_connected,
			is_end_connected,
			is_connected,
			line_path;

		if (MC.layout_data[start_uid]['connection'][start_target] == undefined)
		{
			MC.layout_data[start_uid]['connection'][start_target] = [];
		}

		if (MC.layout_data[end_uid]['connection'][end_target] == undefined)
		{
			MC.layout_data[end_uid]['connection'][end_target] = [];
		}

		MC.paper.start({
			'fill': 'none',
			'stroke': color,
			'stroke-linejoin': 'round',
			'stroke-width': 4
		});

		if (startX > endX)
		{
			paddingY = ( startY > endY ) ? startY - 30 : startY + 30;
			line_path = [
				// Start
				[startX, startY],
				// To start padding
				[startX + 10, startY],
				// To center line
				// [startX + 10, (startY + endY) / 2],
				[startX + 10, paddingY],
				// Center line
				// [endX - 10, (startY + endY) / 2],
				[endX - 10, paddingY],
				// Center line padding
				[endX - 10, endY],
				// Center line to end
				[endX, endY]
			];
		}
		else
		{
			line_path = [
				// Start
				[startX, startY],
				// To center line
				[(startX + endX) / 2, startY],
				// Center line
				[(startX + endX) / 2, endY],
				// Center line to end
				[endX, endY]
			];
		}

		MC.paper.polyline(line_path, {
			'fill': 'none',
			'stroke': '#aaa',
			'stroke-linejoin': 'round',
			'stroke-width': 5
		});
		MC.paper.polyline(line_path);
		connector = MC.paper.save();

		$.each(MC.layout_data[start_uid]['connection'][start_target], function (key, data)
		{
			if (data.uid === end_uid)
			{
				data.SVG = connector;
				is_start_connected = true;
				start_connection = data;
			}
		});

		if (is_start_connected != true)
		{
			start_connection = {
				"type": "out",
				"color": color,
				"SVG": connector,
				"target": end_target,
				"uid": end_uid
			};
			MC.layout_data[start_uid]['connection'][start_target].push(start_connection);
		}

		$.each(MC.layout_data[end_uid]['connection'][end_target], function (key, data)
		{
			if (data.uid === start_uid)
			{
				data.SVG = connector;
				is_end_connected = true;
				end_connection = data;
			}
		});

		if (is_end_connected != true)
		{
			end_connection = {
				"type": "in",
				"color": color,
				"SVG": connector,
				"target": start_target,
				"uid": start_uid
			};
			MC.layout_data[end_uid]['connection'][end_target].push(end_connection);
		}

		connector.data = {
			'start_uid': start_uid,
			'start_target': start_target,
			'start_connection': start_connection,
			'end_uid': end_uid,
			'end_target': end_target,
			'end_connection': end_connection,
			'color': color
		};

		$(connector).on({
			'click': MC.canvas.connection.focus,
			'dblclick': MC.canvas.connection.setting
		});
	},

	propertyInit: function (key, option)
	{
		var attachment = option.attachment;
		if (attachment && attachment != [])
		{
			$.each(attachment, function (i, name)
			{
				$('#' + key).addClass('attached_' + name);
			});
		}
	},
	// Layout initialization
	layout: {
		init: function (data)
		{
			var data = layout;

			MC.layout_data = data;
			$.each(data, function (key, option)
			{
				MC.canvas.create(key, option);
				MC.canvas.propertyInit(key, option);
				MC.canvas.position(key, option.coordinate);
			});

			$.each(data, function (key, option)
			{
				if (option.connection)
				{
					$.each(option.connection, function (name, data)
					{
						$.each(data, function (i, item)
						{
							if (item.type == 'out')
							{
								MC.canvas.connect($('#' + key), name, $('#' + item.uid), item.target, item.color);
							}
						});
					});
				}
			});
		},
		save: function ()
		{
			var layout_data = MC.layout_data;
			$.each(layout_data, function (uid, item)
			{
				if (item.connection)
				{
					$.each(item.connection, function (key, data)
					{
						$.each(data, function (i, connection)
						{
							delete connection.SVG;
						});
					});
				}
			});
			return JSON.stringify(layout_data);
		},
		analysis: function (data)
		{
			topo_map = {};
			topo_map['children'] = [];

			var groupID = 'sg-906987fb',
			 	appName = 'app-7585c21b';

			var data = data.data,
			 	data_ELBs = data.DescribeLoadBalancersResponse.DescribeLoadBalancersResult.LoadBalancerDescriptions.member,
			 	data_Volumes = data.DescribeVolumesResponse.volumeSet.item,
			 	data_Instances = data.DescribeInstancesResponse.reservationSet.item,
			 	data_SecurityGroup = data.DescribeSecurityGroupsResponse.securityGroupInfo.item,
			 	ELBs = [],
			 	volumes = [],
			 	instances = [],
			 	zone = {},
			 	topo_root,
			 	placement,
			 	hasELB,
			 	instanceId,
			 	port_out_Volume,
			 	topo_top,
			 	ELB_center,
			 	ELB_start,
			 	zone_width,
			 	zone_height,
			 	zone_uid,
			 	zone_top;

			 // Private_IP = {};
			 // Pubilc_IP = {};
			 // SecurityGroup_Rule = {};

			 if (data_ELBs != null)
			 {
			 	if (data_ELBs.length)
			 	{
					$.each(data_ELBs, function (i, item)
					{
						if (item.LoadBalancerName.indexOf(appName) > -1)
						{
							ELBs.push({'name': item.LoadBalancerName, 'data': item});
						}
					});
				}
				else
				{
					ELBs.push({'name': data_ELBs.LoadBalancerName, 'data': data_ELBs});
				}
			}

			 $.each(data_Instances, function (i, instance)
			 {
			 	// Private IP
			 	var instance_id = instance.instancesSet.item.instanceId,
			 		instance_private_ip = instance.instancesSet.item.privateIpAddress,
			 		instance_public_ip = instance.instancesSet.item.IpAddress,
			 		instance_sg_id = instance.instancesSet.item.groupSet.item.groupId;

			 	if (instance_private_ip)
			 	{
			 		if (Private_IP[instance_private_ip] == undefined)
			 		{
			 			Private_IP[instance_private_ip] = [];
			 		}
			 		Private_IP[instance_private_ip].push(instance_id);
			 	}

			 	// Public IP
			 	if (instance_public_ip)
			 	{
			 		if (Pubilc_IP[instance_public_ip] == undefined)
			 		{
			 			Pubilc_IP[instance_public_ip] = [];
			 		}
			 		Pubilc_IP[instance_public_ip].push(instance_id);
			 	}

			 	// SecurityGroup
				$.each(data_SecurityGroup, function (i, item)
				{
					if (item.groupId == instance_sg_id)
					{
						if (item.ipPermissions)
						{
							if (item.ipPermissions.item.length)
							{
								$.each(item.ipPermissions.item, function (i, sgData)
								{
									// For ipRanges
									var ipRanges = sgData.ipRanges.item;

									if (ipRanges != null && !ipRanges.length)
									{
										ipRanges = [ipRanges];
									}
									$.each(ipRanges, function (i, range)
									{
										var ip = range.cidrIp.replace('/32', '');
										if (range.cidrIp.indexOf('/32') != -1)
										{
											if (SecurityGroup_Rule[ip] == undefined)
											{
												SecurityGroup_Rule[ip] = [];
											}
											SecurityGroup_Rule[ip].push(instance_id);
										}
									});

									// For Groups
									var ip_security_group = sgData.groups;

									if (ip_security_group != null && !ip_security_group.length)
									{
										ip_security_group = [ip_security_group];
									}
									$.each(ip_security_group, function (i, group)
									{
										if (group.groupId)
										{
											if (SecurityGroup_Rule[group.groupId] == undefined)
											{
												SecurityGroup_Rule[group.groupId] = [];
											}
											SecurityGroup_Rule[group.groupId].push(instance_id);
										}
									});
								});
							}
						}
					}
				});

			 	// Find target instances by groupID
			 	if (
			 		instance.groupSet.item != undefined &&
			 		instance.groupSet.item.groupId == groupID
			 	)
			 	{
			 		placement = instance.instancesSet.item.placement.availabilityZone;

			 		if (zone[placement] == undefined)
			 		{
			 			zone[placement] = [];
			 		}

			 		zone[placement].push({
			 			'name': instance.instancesSet.item.instanceId,
			 			'data': instance.instancesSet.item
			 		});
			 	}
			 });

			$.each(zone, function (key, instance_wrap)
			{
				$.each(instance_wrap, function (i, data)
				{
					instances.push(data);
				});
			});

			// List all instances
			$.each(instances, function (i, instance)
			{
				instanceId = instance.data.instanceId;

				// Place instance
				topo_data = {};
				topo_data['name'] = instanceId;

				// Check instances and remove from instance stack.

				// Check volume
				port_out_Volume = [];
				rootVolume = instance['data']['rootDeviceName'];

				if (instance.data.blockDeviceMapping.item != undefined)
				{
					instance_volumes = instance.data.blockDeviceMapping.item;
					if (instance_volumes.length)
					{
						$.each(instance_volumes, function (i, item)
						{
							if (item.deviceName != rootVolume)
							{
								if (topo_data['children'] == undefined)
								{
									topo_data['children'] = [];
								}
								topo_data['children'].push({'name': item.ebs.volumeId});

								layout[item.ebs.volumeId] = {
									"type": "volume",
									"class": "node",
									"connection": {
										"port_in_Volume": [
											{
												"type": "in",
												"target": "port_out_Volume",
												"uid": instanceId,
												"color": "#97bf7d"
											}
										]
									},
									"placement": "zone",
									"zone": "",
									"coordinate": [],
									"size": [1, 1]
								};
								port_out_Volume.push({
									"type": "out",
									"target": "port_in_Volume",
									"uid": item.ebs.volumeId,
									"color": "#97bf7d"
								});
							}
						});
					}
				}

				layout[instanceId] = {
					"type": "instance",
					"class": "node",
					"connection": {
						"port_out_Volume": port_out_Volume,
						"port_in_Firewall": [],
						"port_out_SecurityGroup": []
					},
					"attachment": [],
					"placement": "zone",
					"zone": "",
					"coordinate": [],
					"size": [1, 1]
				};

				topo_map['children'].push(topo_data);
			});
			
			MC.topo(topo_map);

			// Place ELB
			if (ELBs.length > 0)
			{
				topo_top = topo_map['children'];
				ELB_center = Math.ceil((topo_top[0].coordinate[1] + topo_top[topo_top.length - 1].coordinate[1]) / 2);
				ELB_port = [];

				ELB_start = ELB_center - (ELBs.length - 1);
				ELB_start = ELB_start <= 1 ? 1 : ELB_start;

				$.each(ELBs, function (i, ELB)
				{
					$.each(ELB.data.Instances.member, function (i, item)
					{
						layout[item.InstanceId]['connection']['port_in_Firewall'].push({
							"type": "in",
							"target": "port_out_ELB",
							"uid": ELB.data.LoadBalancerName,
							"color": "#6d9ee1"
						});
						ELB_port.push({
							"type": "out",
							"target": "port_in_Firewall",
							"uid": item.InstanceId,
							"color": "#6d9ee1"
						});
					});

					layout[ELB.data.LoadBalancerName] = {
						"type": "elb",
						"class": "node",
						"connection": {
							"port_out_ELB": ELB_port
						},
						"placement": "canvas",
						"coordinate": [0, ELB_start],
						"size": [1, 1]
					};

					ELB_start += 2;
				});					
			}

			// Calculate zone width and height
			function zoneNode(node, zone_uid)
			{
				if (node.children != undefined)
				{
					$.each(node.children, function (i, item)
					{
						zoneNode(item, zone_uid);
					});
				}
				else
				{
					if (node.coordinate[0] > zone_width)
					{
						zone_width = node.coordinate[0];
					}
					if (node.coordinate[1] > zone_height)
					{
						zone_height = node.coordinate[1];
					}
				}
				layout[node.name]['zone'] = zone_uid;
			}

			zone_top = 1;
			$.each(zone, function (key, instance_wrap)
			{
				zone_width = 1;
				zone_height = 1;
				zone_uid = MC.guid();

				$.each(instance_wrap, function (i, instance_item)
				{
					$.each(topo_map.children, function (i, item)
					{
						if (item.name == instance_item.name)
						{
							zoneNode(item, zone_uid);
						}
					});
				});

				layout[zone_uid] = {
					"type": "group",
					"class": "zone",
					"placement": "canvas",
					"name": key,
					"coordinate": [1, zone_top],
					"size": [zone_width, zone_height]
				};

				zone_top += zone_height;
			});
		}
	},
	connection: {
		focus: function (event)
		{
			var target = event.target;
			target.style.stroke = '#B25B91';

			$(target.parentNode).off({
			 	'click': MC.canvas.connection.focus
			});
			setTimeout(function ()
			{
				$(document).on({
					'click': MC.canvas.connection.blur,
					'keyup': MC.canvas.connection.remove
				}, {"focused_connector": target});
			}, 5);

			MC.canvas.focused_node = [];
		},
		blur: function (event)
		{
			var target = event.data.focused_connector;
			target.style.stroke = target.parentNode.color;

			$(document).off({
				'click': MC.canvas.connection.blur,
				'keyup': MC.canvas.connection.remove
			});

			$(target.parentNode).on({
				'click': MC.canvas.connection.focus
			});
		},
		setting: function (event)
		{
			alert('dblclick event popup comes');

			$(event.target.parentNode).on({
				'click': MC.canvas.connection.focus
			});
			return false;
		},
		remove: function (event)
		{
			if (event.which == 46)
			{
				var target = event.data.focused_connector;
					data = target.parentNode.data,
					start = MC.layout_data[data.start_uid]['connection'][data.start_target],
					end = MC.layout_data[data.end_uid]['connection'][data.end_target];

				start.splice(start.indexOf(data.start_connection), 1);
				end.splice(end.indexOf(data.end_connection), 1);
				MC.paper.clear(target.parentNode);

				$(document).off({
					'click': MC.canvas.connection.blur,
					'keyup': MC.canvas.connection.remove
				});
			}
		}
	},
	selection: {
		mousedown: function (event)
		{
			event.preventDefault();
			event.stopPropagation();

			var target = $(event.target),
				target_offset = target.offset(),
				canvas_offset = $('#svg_canvas').offset();

			$('#canvas_container').append('<div id="canvas_select_ranger"></div>');

			$(document).on({
				'mousemove': MC.canvas.selection.mousemove,
				'mouseup': MC.canvas.selection.mouseup
			}, {
				'target': target,
				'originalX': event.pageX - canvas_offset.left + 22,
				'originalY': event.pageY - canvas_offset.top + 22
			});

		},
		mousemove: function (event)
		{
			var canvas_offset = $('#canvas_container').offset(),
				originalX = event.data.originalX,
				originalY = event.data.originalY,
				currentX = event.pageX - canvas_offset.left,
				currentY = event.pageY - canvas_offset.top,
				ranger_width,
				ranger_height,
				ranger_top,
				ranger_left;

			if (currentX > originalX)
			{
				ranger_width = currentX - originalX;
				ranger_left = originalX;
			}
			else
			{
				ranger_width = originalX - currentX;
				ranger_left = currentX;
			}
			if (currentY > originalY)
			{
				ranger_height = currentY - originalY;
				ranger_top = originalY;
			}
			else
			{
				ranger_height = originalY - currentY;
				ranger_top = currentY;
			}
			$('#canvas_select_ranger').css({
				'left': ranger_left,
				'top': ranger_top,
				'width': ranger_width,
				'height': ranger_height
			});
		},
		mouseup: function (event)
		{
			var canvas_offset = $('#canvas_container').offset(),
				originalX = Math.ceil(event.data.originalX / 140) - 1,
				originalY = Math.ceil(event.data.originalY / 100) - 1,
				currentX = Math.ceil((event.pageX - canvas_offset.left) / 140) - 1,
				currentY = Math.ceil((event.pageY - canvas_offset.top) / 100) - 1,
				matched_component = [],
				startX,
				endX,
				startY,
				endY;

			if (currentX > originalX)
			{
				startX = originalX;
				endX = currentX;
			}
			else
			{
				startX = currentX;
				endX = originalX;
			}
			if (currentY > originalY)
			{
				startY = originalY;
				endY = currentY;
			}
			else
			{
				startY = currentY;
				endY = originalY;
			}

			$.each(MC.layout_data, function (uid, item)
			{
				if (
					item.coordinate[0] >= startX &&
					item.coordinate[0] <= endX &&
					item.coordinate[1] >= startY &&
					item.coordinate[1] <= endY
				)
				{
					matched_component.push(uid);
				}
			});

			$.each(matched_component, function(i, uid)
			{
				$('#' + uid).addClass('focused');
			});

			MC.canvas.focused_node = matched_component;

			$('#canvas_select_ranger').remove();
			$(document).off({
				'mousemove': MC.canvas.selection.mousemove,
				'mouseup': MC.canvas.selection.mouseup
			});
		}
	},

	line_connect: {
		originalX: 0,
		originalY: 0,

		isConnected: false,
		connectedTarget: null,

		mousedown: function (event)
		{
			var canvas_offset = $('#svg_canvas').offset(),
				target = $(event.target),
				target_offset = target.offset(),
				connect_name = target.data('connect-name'),
				connect_target = target.data('connect'),
				node_id = target.parent().attr('id');

			$(document).on({
				'mousemove': MC.canvas.line_connect.mousemove,
				'mouseup': MC.canvas.line_connect.mouseup,
			}, {
				'connect': target.data('connect'),
				'originalTarget': target
			});

			$('#canvas_body .port').each(function (i, port)
			{
				var port = $(port);
				if (port.parent().attr('id') != node_id && (port.data('connect') == connect_name || port.data('connect-name') == connect_target))
				{
					port.addClass('attachable');
				}
			});

			$('.focusable').removeClass('focused');
			MC.canvas.focused_node = [];

			MC.canvas.line_connect.originalX = target_offset.left - canvas_offset.left + (target.width() / 2);
			MC.canvas.line_connect.originalY = target_offset.top - canvas_offset.top + (target.height() / 2);

			return false;
		},
		mousemove: function (event)
		{
			var canvas_offset = $('#svg_canvas').offset(),
				startX = MC.canvas.line_connect.originalX,
				startY = MC.canvas.line_connect.originalY,
				endX = event.pageX - canvas_offset.left,
				endY = event.pageY - canvas_offset.top,
				arrow_length = 8,
				line_offset = 20,
				angle = Math.atan2(endY - startY, endX - startX),
				arrowPI = Math.PI / 6;

			if (MC.paper.drewLine)
			{
				MC.paper.clear(MC.paper.drewLine);
			}

			MC.paper.start({
				'fill': 'none',
				'stroke': '#09c'
			});
			MC.paper.line(startX, startY, endX, endY, {
				'stroke-width': 5
			});
			MC.paper.polygon([
				[endX, endY],
				[endX - arrow_length * Math.cos(angle - arrowPI), endY - arrow_length * Math.sin(angle - arrowPI)],
				[endX - arrow_length * Math.cos(angle + arrowPI), endY - arrow_length * Math.sin(angle + arrowPI)]
			], {
				'stroke-width': 3
			});
			MC.paper.drewLine = MC.paper.save();

			return false;
		},
		drawConnector: function (event)
		{
			event.preventDefault();
			event.stopPropagation();

			$(document).off('mouseover', MC.canvas.line_connect.drawConnector);

			if ($(event.target).hasClass(event.data.connect))
			{
				start_port = event.data.originalTarget;
				end_port = $(event.target);
			}
			else
			{
				if (event.data.originalTarget.hasClass($(event.target).data('connect')))
				{
					start_port = $(event.target);
					end_port = event.data.originalTarget;
				}
				else
				{
					return false;
				}
			}

			var start_uid = start_port.parent().attr('id'),
				end_uid = end_port.parent().attr('id'),
				is_connected;

			if (start_uid === end_uid)
			{
				return false;
			}

			$.each(MC.layout_data[start_uid]['connection'][start_port.data('connect-name')], function (key, data)
			{
				if (data.uid === end_uid)
				{
					is_connected = true;
				}
			});

			if (is_connected)
			{
				return false;
			}

			MC.canvas.connect(start_port.parent(), start_port.data('connect-name'), end_port.parent(), end_port.data('connect-name'), start_port.data('connect-color'));

			return true;
		},
		mouseup: function (event)
		{
			MC.paper.clear(MC.paper.drewLine);

			$('#node_container').css('zIndex', '99');
			$(document).on('mouseover', event.data, MC.canvas.line_connect.drawConnector);
			$('#node_container').css('zIndex', '-1');

			$(document).off({
				'mousemove': MC.canvas.line_connect.mousemove,
				'mouseup': MC.canvas.line_connect.mouseup
			});

			$('#canvas_body .port').removeClass('attachable');

			return false;
		}
	}
};

MC.drag = {
	canvas: {
		mousedown: function (event)
		{
			event.preventDefault();
			event.stopPropagation();

			var target = $(event.currentTarget),
				target_offset = target.offset(),
				canvas_offset = $('#svg_canvas').offset(),
				shadow,
				clone_node;

			$('#node_container').append('<div id="drag_shadow"></div>');
			shadow = $('#drag_shadow');
			clone_node = target.clone().css({
				'top': 0,
				'left': 0,
				'zIndex': 900
			});
			shadow.append(clone_node).hide();

			$(document).on({
				'mousemove': MC.drag.canvas.mousemove,
				'mouseup': MC.drag.canvas.mouseup
			}, {
				'target': target,
				'shadow': shadow,
				'offsetX': event.pageX - target_offset.left + canvas_offset.left,
				'offsetY': event.pageY - target_offset.top + canvas_offset.top,
				'originalX': target.css('left'),
				'originalY': target.css('top'),
				'zIndex': target.css('zIndex')
			});

			$('.focusable').removeClass('focused');
			MC.canvas.focused_node = [];
			$('#node_container').css('zIndex', '99');
			//target.css('zIndex', '900');

			return false;
		},
		mousemove: function (event)
		{
			event.preventDefault();
			event.stopPropagation();

			event.data.shadow.css({
				'top': event.pageY - event.data.offsetY,
				'left': event.pageX - event.data.offsetX
			}).show();

			return false;
		},
		mouseup: function (event)
		{
			event.preventDefault();
			event.stopPropagation();

			event.data.shadow.remove();

			var target = $(event.data.target),
				target_id = target.attr('id'),
				canvas_offset = $('#svg_canvas').offset(),
				node_class = MC.layout_data[target.attr('id')]['class'],
				placement = target.data('placement'),
				zone_offsetX,
				zone_offsetY,
				is_matchX,
				is_matchY,
				is_drop_place_match;

			target.css({
				'zIndex': event.data.zIndex == 'auto' ? '' : event.data.zIndex
			});

			if (node_class == 'zone')
			{
				target_zoneX = Math.round((event.pageX - event.data.offsetX + 60) / 140);
				target_zoneY = Math.round((event.pageY - event.data.offsetY + 20) / 100);

				if (target_zoneX > 0 && target_zoneY > 0)
				{
					zone_offsetX = target_zoneX - MC.layout_data[target_id]['coordinate'][0];
					zone_offsetY = target_zoneY - MC.layout_data[target_id]['coordinate'][1];
					$.each(MC.layout_data, function (uid, item)
					{
						if (item.placement == 'zone' && item.zone == target_id)
						{
							MC.canvas.move(uid, item['coordinate'][0] + zone_offsetX, item['coordinate'][1] + zone_offsetY, false);
						}
					});

					MC.canvas.move(target_id, target_zoneX, target_zoneY);
				}
				else
				{
					target.css({
						'left': event.data.originalX,
						'top': event.data.originalY
					});
				}
			}
			if (node_class == 'node')
			{
				target_zoneX = Math.ceil((event.pageX - canvas_offset.left) / 140) - 1;
				target_zoneY = Math.ceil((event.pageY - canvas_offset.top) / 100) - 1;

				if (placement == 'zone')
				{
					$.each(MC.layout_data, function (uid, item)
					{
						if (item.class == 'zone')
						{
							if (
								(target_zoneX >= item.coordinate[0] && target_zoneX < item.coordinate[0] + item.size[0]) &&
								(target_zoneY >= item.coordinate[1] && target_zoneY < item.coordinate[1] + item.size[1])
							)
							{
								is_drop_place_match = true;
								MC.layout_data[target_id]['zone'] = uid;
								MC.canvas.drop(target_id, target_zoneX, target_zoneY);
							}
						}
					});
				}
				if (placement == 'canvas')
				{
					$.each(MC.layout_data, function (uid, item)
					{
						if (item.class == 'zone')
						{
							if (
								(target_zoneX < item.coordinate[0] || target_zoneX > item.coordinate[0] + item.size[0]) ||
								(target_zoneY < item.coordinate[1] || target_zoneY > item.coordinate[1] + item.size[1])
							)
							{
								is_drop_place_match = true;
								MC.canvas.drop(target_id, target_zoneX, target_zoneY);
							}
						}
					});
				}

				if (!is_drop_place_match)
				{
					target.css({
						'left': event.data.originalX,
						'top': event.data.originalY
					});
				}
			}

			$(document).off({
				'mousemove': MC.drag.canvas.mousemove,
				'mouseup': MC.drag.canvas.mouseup
			});

			$('#node_container').css('zIndex', '-1');
		}
	},
	component: {
		mousedown: function (event)
		{
			event.preventDefault();
			event.stopPropagation();

			var target = $(event.target),
				target_offset = target.offset();

			$(document.body).append('<div id="component_drag_shadow"></div>');
			$(document).on({
				'mousemove': MC.drag.component.mousemove,
				'mouseup': MC.drag.component.mouseup
			}, {
				'target': target
			});

			$('#component_drag_shadow').css('backgroundImage', target.css('backgroundImage'));
		},
		mousemove: function (event)
		{
			event.preventDefault();
			event.stopPropagation();

			$('#component_drag_shadow').css({
				'top': event.pageY - 40,
				'left': event.pageX - 40
			});

			return false;
		},
		mouseup: function (event)
		{
			var canvas_offset = $('#svg_canvas').offset(),
				mouseX = event.pageX - canvas_offset.left,
				mouseY = event.pageY - canvas_offset.top,
				target_zoneX = Math.ceil(mouseX / 140) - 1,
				target_zoneY = Math.ceil(mouseY / 100) - 1,
				option = event.data.target.data('option'),
				is_drop_place_match,
				match_zone,
				new_uid;

			if (mouseX > 0 && mouseY > 0)
			{
				if (option.placement == 'zone')
				{
					$.each(MC.layout_data, function (uid, item)
					{
						if (item.class == 'zone')
						{
							if (
								(target_zoneX >= item.coordinate[0] && target_zoneX < item.coordinate[0] + item.size[0]) &&
								(target_zoneY >= item.coordinate[1] && target_zoneY < item.coordinate[1] + item.size[1])
							)
							{
								is_drop_place_match = true;
								match_zone = uid;
							}
						}
					});
					if (is_drop_place_match)
					{
						new_uid = MC.canvas.add(option, mouseX, mouseY);
						MC.layout_data[new_uid]['zone'] = match_zone;
					}
				}
				if (option.placement == 'canvas')
				{
					is_drop_place_match = true;
					$.each(MC.layout_data, function (uid, item)
					{
						if (item.class == 'zone')
						{
							if (
								(target_zoneX >= item.coordinate[0] && target_zoneX <= item.coordinate[0] + item.size[0] - 1) &&
								(target_zoneY >= item.coordinate[1] && target_zoneY <= item.coordinate[1] + item.size[1] - 1)
							)
							{
								is_drop_place_match = false;
							}
						}
					});

					if (is_drop_place_match)
					{
						MC.canvas.add(option, mouseX, mouseY);
					}
				}
				if (option.placement == 'node')
				{
					$.each(MC.layout_data, function (uid, item)
					{
						if (item.class == 'node' && item.type == 'instance')
						{
							if (
								target_zoneX == item.coordinate[0] &&
								target_zoneY == item.coordinate[1] &&
								item.attachment.indexOf(option.type) == -1
							)
							{
								$('#' + uid).addClass('attached_' + option.type);
								MC.layout_data[uid]['attachment'].push(option.type);
							}
						}
					});
				}
			}

			$(document).off({
				'mousemove': MC.drag.component.mousemove,
				'mouseup': MC.drag.component.mouseup
			});
			$('#component_drag_shadow').remove();
		}
	},
	resize: {
		mousedown: function (event)
		{
			event.preventDefault();
			event.stopPropagation();

			var target = event.target,
				zone = $(target.parentNode),
				zone_offset = $(zone).offset(),
				direction = $(target).data('direction');

			$(document).on({
				'mousemove': MC.drag.resize.mousemove,
				'mouseup': MC.drag.resize.mouseup
			}, {
				'resizer': target,
				'target': target.parentNode,
				'originalX': zone_offset.left,
				'originalY': zone_offset.top,
				'originalWidth': zone.width(),
				'originalHeight': zone.height(),
				'originalTop': zone.position().top,
				'originalLeft': zone.position().left,
				'direction': direction
			});
		},
		mousemove: function (event)
		{
			var target = event.data.target,
				direction = event.data.direction,
				zone_border = 4 * 2,
				left = event.data.originalLeft + event.pageX - event.data.originalX,
				max_left = event.data.originalLeft + event.data.originalWidth,
				top = event.data.originalTop + event.pageY - event.data.originalY,
				max_top = event.data.originalTop + event.data.originalHeight;

			switch (direction)
			{
				case 'topleft':
					$(target).css({
						'top': top > max_top ? max_top : top,
						'left': left > max_left ? max_left : left,
						'width': event.data.originalWidth - event.pageX + event.data.originalX + zone_border,
						'height': event.data.originalHeight - event.pageY + event.data.originalY + zone_border
					});
					break;

				case 'topright':
					$(target).css({
						'top': top > max_top ? max_top : top,
						'width': event.pageX - event.data.originalX,
						'height': event.data.originalHeight - event.pageY + event.data.originalY + zone_border
					});
					break;

				case 'bottomleft':
					$(target).css({
						'left': left > max_left ? max_left : left,
						'width': event.data.originalWidth - event.pageX + event.data.originalX + zone_border,
						'height': event.pageY - event.data.originalY
					});
					break;

				case 'bottomright':
					$(target).css({
						'width': event.pageX - event.data.originalX,
						'height': event.pageY - event.data.originalY
					});
					break;

				case 'top':
					$(target).css({
						'top': top > max_top ? max_top : top,
						'height': event.data.originalHeight - event.pageY + event.data.originalY + zone_border
					});
					break;

				case 'right':
					$(target).css({
						'width': event.pageX - event.data.originalX
					});
					break;

				case 'bottom':
					$(target).css({
						'height': event.pageY - event.data.originalY
					});
					break;

				case 'left':
					$(target).css({
						'left': left > max_left ? max_left : left,
						'width': event.data.originalWidth - event.pageX + event.data.originalX + zone_border
					});
					break;
			}
		},
		mouseup: function (event)
		{
			var target = event.data.target,
				canvas_offset = $('#svg_canvas').offset(),
				direction = event.data.direction,
				zone_id = target.id,
				zone_data = MC.layout_data[zone_id],
				left = event.pageX - canvas_offset.left,
				top = event.pageY - canvas_offset.top,
				mouseX,
				mouseY,
				max_left,
				max_top,
				zone_width,
				zone_height,
				zone_top,
				zone_left,
				zone_minX,
				zone_minY,
				zone_maxX,
				zone_maxY,
				zone_available_X = [],
				zone_available_Y = [];

			zone_top = event.data.originalTop;
			zone_left = event.data.originalLeft;

			switch (direction)
			{
				case 'topleft':
					zone_top = top < event.data.originalTop + event.data.originalHeight - 240 ? top : event.data.originalTop + event.data.originalHeight - 100;
					zone_left = left < event.data.originalLeft + event.data.originalWidth - 320 ? left : event.data.originalLeft;

					mouseX = event.data.originalX + event.data.originalWidth - event.pageX;
					mouseY = event.data.originalY + event.data.originalHeight - event.pageY;

					if (mouseY < 240)
					{
						zone_top = event.data.originalTop + event.data.originalHeight - 200;
						mouseY = 100;
					}

					if (mouseX < 320)
					{
						zone_left = event.data.originalLeft + event.data.originalWidth - 320;
						mouseX = 140;
					}
					break;

				case 'topright':

					zone_top = top < event.data.originalTop + event.data.originalHeight - 240 ? top : event.data.originalTop + event.data.originalHeight - 100;

					zone_left = event.data.originalLeft;

					mouseY = event.data.originalHeight - event.pageY + event.data.originalY;
					if (mouseY < 240)
					{
						zone_top = event.data.originalTop + event.data.originalHeight - 200;
						mouseY = 100;
					}

					mouseX = event.pageX - event.data.originalX;
					break;

				case 'bottomleft':

					zone_left = left < event.data.originalLeft + event.data.originalWidth - 320 ? left : event.data.originalLeft;
					zone_top = event.data.originalTop;

					mouseX = event.data.originalWidth - event.pageX + event.data.originalX;
					if (mouseX < 320)
					{
						zone_left = event.data.originalLeft + event.data.originalWidth - 320;
						mouseX = 140;
					}
					mouseY = event.pageY - event.data.originalY;
					break;

				case 'bottomright':
					mouseX = event.pageX - event.data.originalX;
					mouseY = event.pageY - event.data.originalY;
					break;

				case 'top':
					zone_top = top < event.data.originalTop + event.data.originalHeight - 240 ? top : event.data.originalTop + event.data.originalHeight - 100;
					mouseY = event.data.originalY + event.data.originalHeight - event.pageY;

					if (mouseY < 240)
					{
						zone_top = event.data.originalTop + event.data.originalHeight - 200;
						mouseY = 100;
					}
					//mouseX = event.data.originalWidth + event.data.originalLeft - 140;
					break;

				case 'right':
					zone_left = event.data.originalLeft;
					//mouseY = event.data.originalHeight + event.data.originalTop - 100;
					mouseX = event.pageX - event.data.originalX;
					break;

				case 'bottom':
					zone_top = event.data.originalTop;
					mouseY = event.pageY - event.data.originalY;
					//mouseX = event.data.originalWidth + event.data.originalLeft - 140;
					break;

				case 'left':
					zone_left = left < event.data.originalLeft + event.data.originalWidth - 320 ? left : event.data.originalLeft;
					mouseX = event.data.originalWidth - event.pageX + event.data.originalX;

					if (mouseX < 320)
					{
						zone_left = event.data.originalLeft + event.data.originalWidth - 320;
						mouseX = 140;
					}
					//mouseY = event.data.originalHeight + event.data.originalTop - 100;
					break;
			}

			$.each(MC.layout_data, function (i, item)
			{
				if (item.zone && item.zone == zone_id)
				{
					zone_available_X.push(item.coordinate[0]);
					zone_available_Y.push(item.coordinate[1]);
				}
			});

			zone_left = Math.ceil(zone_left / 140);
			zone_top = Math.ceil(zone_top / 100);
			zone_width = Math.ceil(mouseX / 140);
			zone_height = Math.ceil(mouseY / 100);
			zone_maxX = Math.max.apply(Math, zone_available_X);
			zone_maxY = Math.max.apply(Math, zone_available_Y);
			zone_minX = Math.min.apply(Math, zone_available_X);
			zone_minY = Math.min.apply(Math, zone_available_Y);

			zone_width = zone_width < 2 ? 2 : zone_width;
			zone_height = zone_height < 2 ? 2 : zone_height;

			switch (direction)
			{
				case 'topleft':
					if (zone_left > zone_minX)
					{
						zone_left = zone_minX;
						zone_width = zone_maxX - zone_minX + 2;
					}

					if (zone_top > zone_minY)
					{
						zone_top = zone_minY;
						zone_height = zone_maxY - zone_minY + 2;
					}
					break;

				case 'topright':
					zone_width = zone_width + MC.layout_data[zone_id]['coordinate'][0] - 1 > zone_maxX ? zone_width : zone_maxX - MC.layout_data[zone_id]['coordinate'][0] + 2;

					if (zone_top > zone_minY)
					{
						zone_top = zone_minY;
						zone_height = zone_maxY - zone_minY + 2;
					}
					break;

				case 'bottomleft':
					if (zone_left > zone_minX)
					{
						zone_left = zone_minX;
						zone_width = zone_maxX - zone_minX + 2;
					}

					zone_height = zone_height + MC.layout_data[zone_id]['coordinate'][1] - 1 > zone_maxY ? zone_height : zone_maxY - MC.layout_data[zone_id]['coordinate'][1] + 2;
					break;

				case 'bottomright':
					zone_width = zone_width + MC.layout_data[zone_id]['coordinate'][0] - 1 > zone_maxX ? zone_width : zone_maxX - MC.layout_data[zone_id]['coordinate'][0] + 2;
					zone_height = zone_height + MC.layout_data[zone_id]['coordinate'][1] - 1 > zone_maxY ? zone_height : zone_maxY - MC.layout_data[zone_id]['coordinate'][1] + 2;
					break;

				case 'top':
					if (zone_top > zone_minY)
					{
						zone_top = zone_minY;
						zone_height = zone_maxY - zone_minY + 2;
					}
					break;

				case 'right':
					zone_width = zone_width + MC.layout_data[zone_id]['coordinate'][0] - 1 > zone_maxX ? zone_width : zone_maxX - MC.layout_data[zone_id]['coordinate'][0] + 2;
					break;

				case 'bottom':
					zone_height = zone_height + MC.layout_data[zone_id]['coordinate'][1] - 1 > zone_maxY ? zone_height : zone_maxY - MC.layout_data[zone_id]['coordinate'][1] + 2;
					break;

				case 'left':
					if (zone_left > zone_minX)
					{
						zone_left = zone_minX;
						zone_width = zone_maxX - zone_minX + 2;
					}
					break;
			}

			$(target).css({
				'top': zone_top * 100 - 40,
				'left': zone_left * 140 - 50,
				'width': (zone_width - 1) * 140 + 100,
				'height': (zone_height - 1) * 100 + 80
			});

			zone_width = isNaN(zone_width) ? zone_data['size'][0] + 1 : zone_width;
			zone_height = isNaN(zone_height) ? zone_data['size'][1] + 1 : zone_height;

			zone_data['coordinate'] = [zone_left, zone_top];
			zone_data['size'] = [zone_width - 1, zone_height - 1];

			$(document).off({
				'mousemove': MC.drag.resize.mousemove,
				'mouseup': MC.drag.resize.mouseup
			});
		}
	}
};

MC.KeyRemoveNode = function (event)
{
	if (event.which == 46 && MC.canvas.focused_node.length > 0)
	{
		$.each(MC.canvas.focused_node, function (i, uid)
		{
			var focused_node = $('#' + uid),
				zone_id;

			if (focused_node.hasClass('zone'))
			{
				zone_id = focused_node.attr('id');
				$.each(MC.layout_data, function (uid, item)
				{
					if (item.zone == zone_id)
					{
						MC.canvas.remove($('#' + uid));
					}
				});
				focused_node.remove();
				delete MC.layout_data[zone_id];
			}
			else
			{
				MC.canvas.remove(focused_node);
			}
		});
		MC.canvas.focused_node = [];
	}
};