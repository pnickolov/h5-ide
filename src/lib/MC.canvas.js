// MC.Canvas
// Author: Angel

MC.canvas = {
	selected_node: [],
	current_tab: '',

	_addPad: function (point, adjust)
	{
		//add by xjimmy, adjust point
		switch (point.connectionAngle)
		{
			case 0:
				point.x += MC.canvas.PORT_PADDING;
				point.y -= adjust;
				break;

			case 90:
				point.x -= adjust;
				point.y -= MC.canvas.PORT_PADDING;
				break;

			case 180:
				point.x -= MC.canvas.PORT_PADDING;
				point.y -= adjust;
				break;

			case 270:
				point.x -= adjust;
				point.y += MC.canvas.PORT_PADDING;
				break;
		}
	},

	_getPath: function (prev, current, next)
	{
		//add by xjimmy, generate path by three point
		var sign = 0,
			delta = 0,
			cornerRadius = MC.canvas.CORNER_RADIUS, //8
			closestRange = 2 * MC.canvas.CORNER_RADIUS; //2*cornerRadius

		/*1.above or below*/
		if (prev[0] === current[0])
		{
			//1.1 calc p1
			delta = current[1] - prev[1];
			if (Math.abs(delta) <= closestRange )
			{
				//use middle point between prev and current
				p1 = [current[0], (prev[1] + current[1]) / 2];
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p1 = [current[0], current[1] - cornerRadius * sign];
			}

			//1.2 calc p2
			delta = current[0] - next[0];
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between current and next
				p2 = [(current[0] + next[0]) / 2, current[1]];
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p2 = [current[0] - cornerRadius * sign, current[1]];
			}
		}
		else
		{
			/*2.left or right*/
			//2.1 calc p1
			delta = current[0] - prev[0];
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between prev and current
				p1 = [(prev[0] + current[0]) / 2, current[1]];
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p1 = [current[0] - cornerRadius * sign, current[1]];
			}

			//2.2 calc p2
			delta = current[1] - next[1];
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between current and next
				p2 = [current[0], (current[1] + next[1]) / 2];
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p2 = [current[0], current[1] - cornerRadius * sign];
			}
		}

		return ' L ' + p1[0] + ' ' + p1[1] + ' Q ' + current[0] + ' ' + current[1] + ' ' + p2[0] + ' ' + p2[1];
	},

	updateResizer: function(node, width, height)
	{
		var pad = 10,
			top = 0;

		width = width * MC.canvas.GRID_WIDTH;
		height = height * MC.canvas.GRID_HEIGHT;

		$(node).find('.resizer-wrap').empty().append(
			Canvon.rectangle(0, top, pad, pad).attr('class', 'group-resizer resizer-topleft').data('direction', 'topleft'),
			Canvon.rectangle(pad, top, width - 2 * pad, pad).attr('class', 'group-resizer resizer-top').data('direction', 'top'),
			Canvon.rectangle(width - pad, top, pad, pad).attr('class', 'group-resizer resizer-topright').data('direction', 'topright'),
			Canvon.rectangle(0, top + pad, pad, height - 2 * pad).attr('class', 'group-resizer resizer-left').data('direction', 'left'),
			Canvon.rectangle(width - pad, top + pad, pad, height - 2 * pad).attr('class', 'group-resizer resizer-right').data('direction', 'right'),
			Canvon.rectangle(0, height + top - pad, pad, pad).attr('class', 'group-resizer resizer-bottomleft').data('direction', 'bottomleft'),
			Canvon.rectangle(pad, height + top - pad, width - 2 * pad, pad).attr('class', 'group-resizer resizer-bottom').data('direction', 'bottom'),
			Canvon.rectangle(width - pad, height + top - pad, pad, pad).attr('class', 'group-resizer resizer-bottomright').data('direction', 'bottomright')
		);
	},

	connect: function (from_node, from_target_port, to_node, to_target_port, line_option)
	{
		var canvas_offset = $('#svg_canvas').offset(),
			from_uid = from_node.attr('id'),
			to_uid = to_node.attr('id'),
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			from_type = layout_node_data[ from_uid ].type,
			to_type = layout_node_data[ to_uid ].type,
			connection_option = MC.canvas.CONNECTION_OPTION[ from_type ][ to_type ],
			connection_target_data = {},
			layout_connection_data,
			from_port,
			to_port,
			from_port_offset,
			to_port_offset,
			from_node_connection_data,
			to_node_connection_data,
			is_connected,
			startX,
			startY,
			endX,
			endY,
			svg_line;

		if (connection_option)
		{
			if ($.type(connection_option) === 'array')
			{
				$.each(connection_option, function (index, item)
				{
					if (item.from === from_target_port && item.to === to_target_port)
					{
						connection_option = item;
					}
				});
			}

			from_node_connection_data = layout_node_data[ from_uid ].connection || [];
			to_node_connection_data = layout_node_data[ to_uid ].connection || [];
			is_connected = false;

			$.each(from_node_connection_data, function (key, value)
			{
				if (value[ 'target' ] === to_uid && value[ 'port' ] === from_target_port)
				{
					is_connected = true;
				}
			});

			if (is_connected === false || line_option)
			{
				from_port = from_node.find('.port-' + from_target_port);
				to_port = to_node.find('.port-' + to_target_port);

				from_port_offset = from_port[0].getBoundingClientRect();
				to_port_offset = to_port[0].getBoundingClientRect();

				startX = from_port_offset.left - canvas_offset.left + (from_port_offset.width / 2);
				startY = from_port_offset.top - canvas_offset.top + (from_port_offset.height / 2);
				endX = to_port_offset.left - canvas_offset.left + (to_port_offset.width / 2);
				endY = to_port_offset.top - canvas_offset.top + (to_port_offset.height / 2);

				MC.paper.start({
					'fill': 'none',
					'stroke': connection_option.color,
					'stroke-linejoin': 'round',
					'stroke-width': 4,
					'filter' : 'url(#dropshadow)' //dropshadow of line
				});

				//add by xjimmy
				var controlPoints = [],
					//start.x>=end.x
					start_0_90 = end_0_90 = start_180_270 = end_180_270 = false,
					//start.x<end.x
					start_0_270 = end_0_270 = start_90_180 = end_90_180 = false;

					start0 = {
						x : startX,
						y : startY,
						connectionAngle: from_port.data('angle')
					},
					end0 = {
						x: endX,
						y: endY,
						connectionAngle: to_port.data('angle')
					},
					start = {},
					end = {};

				//add pad to start0 and end0
				MC.canvas._addPad(start0, 1);
				MC.canvas._addPad(end0, 1);

				if ( start0.x === end0.x || start0.y === end0.y )
				{
					//draw straight line

					MC.paper.line(start0.x, start0.y, end0.x, end0.y);
				}
				else
				{
					//deep copy
					$.extend(true, start, start0);
					$.extend(true, end, end0);

					if (Math.sqrt(Math.pow(end0.y - start0.y, 2) + Math.pow(end0.x-start0.x, 2)) > MC.canvas.PORT_PADDING * 2)
					{
						//add pad to start and end
						MC.canvas._addPad(start, 0);
						MC.canvas._addPad(end, 0);
					}

					//ensure start.y>=end.y
					if (start.y < end.y)
					{
						var tmp  = {};
						$.extend(true, tmp, start);
						$.extend(true, start, end);
						end = tmp;
						//swap start0 and end0 when swap start and end
						var tmp0  = {};
						$.extend(true, tmp0, start0);
						$.extend(true, start0, end0);
						end0 = tmp0;
					}

					if (start.x >= end.x)
					{
						start_0_90 = start.connectionAngle === 0 || start.connectionAngle === 90;
						end_0_90 = end.connectionAngle === 0 || end.connectionAngle === 90;
						start_180_270 = start.connectionAngle === 180 || start.connectionAngle === 270;
						end_180_270 = end.connectionAngle === 180 || end.connectionAngle === 270;
					}
					else
					{
						//start.x<end.x
						start_0_270 = start.connectionAngle === 0 || start.connectionAngle === 270;
						end_0_270 = end.connectionAngle === 0 || end.connectionAngle === 270;
						start_90_180 = start.connectionAngle === 90 || start.connectionAngle === 180;
						end_90_180 = end.connectionAngle === 90 || end.connectionAngle === 180;
					}

					//1.start point
					controlPoints.push([start0.x, start0.y]);
					controlPoints.push([start.x, start.y]);

					//2.control point
					if (
						(start_0_90 && end_0_90) ||
						(start_90_180 && end_90_180)
					)
					{
						//A
						controlPoints.push([start.x, end.y]);
					}
					else if (
						(start_180_270 && end_180_270) ||
						(start_0_270 && end_0_270)
					)
					{
						//B
						controlPoints.push([end.x, start.y]);
					}
					else if (
						(start_0_90 && end_180_270) ||
						(start_90_180 && end_0_270)
					)
					{
						//C
						controlPoints.push([start.x, (start.y + end.y) / 2]);
						controlPoints.push([end.x, (start.y + end.y) / 2]);
					}
					else if (
						(start_180_270 && end_0_90) ||
						(start_0_270 && end_90_180)
					)
					{
						//D
						controlPoints.push([(start.x + end.x) / 2, start.y]);
						controlPoints.push([(start.x + end.x) / 2, end.y]);
					}

					//3.end point
					controlPoints.push([end.x, end.y]);
					controlPoints.push([end0.x, end0.y]);

					//draw fold line
					//MC.paper.polyline(controlPoints);

					//draw round corner line
					var d = "",
						last_p = [];

					$.each(controlPoints, function (idx, value)
					{
						if (idx === 0)
						{
							//start0 point
							d = 'M ' + value[0] + " " + value[1];
						}
						else if (idx === (controlPoints.length - 1))
						{
							//end0 point
							d += ' L ' + value[0] + ' ' + value[1];
						}
						else
						{
							//middle point
							prev_p = controlPoints[idx - 1]; //prev point
							next_p = controlPoints[idx + 1]; //next point

							if (
								(prev_p[0] === value[0] && next_p[0] === value[0]) ||
								(prev_p[1] === value[1] && next_p[1] === value[1])
							)
							{
								//three point one line
								d += ' L ' + value[0] + ' ' + value[1];
							}
							else
							{
								//fold line
								d += MC.canvas._getPath(prev_p, value, next_p);
							}
						}
						last_p = value;
					});

					if (d !== "")
					{
						MC.paper.path(d);
					}

				}

				svg_line = MC.paper.save();

				$('#line_layer').append(svg_line);

				$(svg_line).attr({
					'class': 'line',
					'data-type': 'line'
				});

				if (line_option)
				{
					svg_line.id = line_option['line_uid'];
				}
				else
				{
					svg_line.id = MC.guid();

					from_node_connection_data.push({
						'target': to_uid,
						'port': from_target_port,
						'line': svg_line.id
					});

					to_node_connection_data.push({
						'target': from_uid,
						'port': to_target_port,
						'line': svg_line.id
					});

					MC.canvas.data.set('layout.component.node.' + from_uid + '.connection', from_node_connection_data);
					MC.canvas.data.set('layout.component.node.' + to_uid + '.connection', to_node_connection_data);
				}

				layout_connection_data = MC.canvas.data.get('layout.connection.' + svg_line.id) || {};

				if (!line_option)
				{
					connection_target_data[ from_uid ] = from_target_port;
					connection_target_data[ to_uid ] = to_target_port;

					layout_connection_data = {
						'target': connection_target_data,
						'auto': true,
						'point': []
					}
				}
				MC.canvas.data.set('layout.connection.' + svg_line.id, layout_connection_data);
			}
		}
	},

	position: function (node, x, y)
	{
		x = x > 0 ? x : 0;
		y = y > 0 ? y : 0;

		var target = $(node),
			offset = node.getBoundingClientRect(),
			coordinate_x = x * MC.canvas.GRID_WIDTH,
			coordinate_y = y * MC.canvas.GRID_HEIGHT;

		MC.canvas.data.set('layout.component.' + target.data('type') + '.' + node.id + '.coordinate', [x, y]);
		target.attr('transform', 'translate(' + coordinate_x + ',' + coordinate_y + ')');
	},

	remove: function (node)
	{
		var node_id = node.id,
			node_type = $(node).data('type');

		if (node_type === 'line')
		{
			var line_data = MC.canvas.data.get('layout.connection.' + node_id),
				layout_node_data = MC.canvas.data.get('layout.component.node'),
				target_connection,
				new_connection_data;

			$.each(line_data.target, function (target_id, target_port)
			{
				target_connection = layout_node_data[ target_id ].connection;
				new_connection_data = [];

				$.each(target_connection, function (i, option)
				{
					if (option.line !== node_id)
					{
						new_connection_data.push(option);
					}
				});

				MC.canvas.data.set('layout.component.node.' + target_id + '.connection', new_connection_data);
			});

			MC.canvas.data.delete('layout.connection.' + node_id);
		}

		if (node_type === 'node')
		{
			var	layout_node_data = MC.canvas.data.get('layout.component.node'),
				layout_connection_data = MC.canvas.data.get('layout.connection'),
				line_layer = $("#line_layer")[0],
				connections = layout_node_data[ node_id ].connection,
				new_connection_data,
				connection_data,
				connected_data;

			$.each(connections, function (index, value)
			{
				connection_data = layout_connection_data[ value.line ];
				new_connection_data = [];

				line_layer.removeChild($('#' + value.line)[0]);

				$.each(connection_data.target, function (key, item)
				{
					if (key !== node_id)
					{
						connected_node = key;
					}
				});

				connected_data = layout_node_data[ connected_node ].connection;

				$.each(connected_data, function (i, option)
				{
					if (option.line !== value.line && option.target !== node_id)
					{
						new_connection_data.push(option);
					}
				});

				MC.canvas.data.set('layout.component.node.' + connected_node + '.connection', new_connection_data);
				MC.canvas.data.delete('layout.connection.' + value.line);
			});

			MC.canvas.data.delete('layout.component.' + node_type + '.' + node_id);
			MC.canvas.data.delete('component.' + node_id);
		}

		$(node).remove();
	},

	pixelToGrid: function (x, y)
	{
		return {
			'x': Math.ceil(x / MC.canvas.GRID_WIDTH),
			'y': Math.ceil(y / MC.canvas.GRID_HEIGHT)
		};
	},

	matchPoint: function (x, y)
	{

	},

	isMatchPlace: function (type, x, y)
	{
		var matchGroup = MC.canvas.matchGroup(x, y).type,
			platform = MC.canvas.data.get('platform');

		matchGroup = matchGroup === undefined ? 'Canvas' : matchGroup;

		platform = platform === 'custome-vpc' ? 'ec2-vpc' : platform;

		return $.inArray(matchGroup, MC.canvas.MATCH_PLACEMENT[ platform ][ type ]) > -1;
	},

	isBlank: function (type, target_id, x, y)
	{
		var children = MC.canvas.data.get('layout.component.' + type),
			start_x = x,
			start_y = y,
			end_x = x + MC.canvas.COMPONENT_WIDTH_GRID,
			end_y = y + MC.canvas.COMPONENT_HEIGHT_GRID,
			isBlank = true,
			coordinate;

		$.each(children, function (key, item)
		{
			coordinate = item.coordinate;

			if (key !== target_id)
			{
				if (
					(
						(coordinate[0] > start_x &&
						coordinate[0] < end_x)
						||
						(coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID > start_x &&
						coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID < end_x)
						||
						coordinate[0] === start_x
					)
					&&
					(
						(coordinate[1] > start_y &&
						coordinate[1] < end_y)
						||
						(coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID > start_y &&
						coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID < end_y)
						||
						coordinate[1] === start_y
					)
				)
				{
					isBlank = false;
				}
			}
		});

		return isBlank;
	},

	matchGroup: function (x, y)
	{
		var layout_group_data = MC.canvas.data.get('layout.component.group'),
			result = {},
			group_data;

		$.each([
			$('#subnet_layer').children(),
			$('#az_layer').children(),
			$('#vpc_layer').children()
		], function (index, layer_data)
		{
			if (layer_data)
			{
				$.each(layer_data, function (index, item)
				{
					group_data = layout_group_data[ item.id ];

					if (
						x > group_data.coordinate[0] &&
						x < group_data.size[0] + group_data.coordinate[0] &&
						y > group_data.coordinate[1] &&
						y < group_data.size[1] + group_data.coordinate[1]
					)
					{
						result = {
							'id': item.id,
							'type': group_data.type
						};
					}
				});

				if (!$.isEmptyObject(result))
				{
					return false;
				}
			}
		});

		return result;
	},

	groupChild: function (group_node)
	{
		var children = MC.canvas.data.get('layout.component.node'),
			groups = MC.canvas.data.get('layout.component.group'),
			group_data = groups[ group_node.id ],
			start_x = group_data.coordinate[0],
			start_y = group_data.coordinate[1],
			end_x = start_x + group_data.size[0],
			end_y = start_y + group_data.size[1],
			matched = [],
			group_weight = MC.canvas.GROUP_WEIGHT[ group_data.type ],
			coordinate;

		$.each(children, function (key, item)
		{
			coordinate = item.coordinate;

			if (
				coordinate[0] >= start_x &&
				coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID <= end_x &&
				coordinate[1] >= start_y &&
				coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID <= end_y
			)
			{
				matched.push($('#' + key)[0]);
			}
		});

		$.each(groups, function (key, item)
		{
			coordinate = item.coordinate;

			if (
				key !== group_node.id &&
				$.inArray(item.type, group_weight) > -1 &&
				coordinate[0] >= start_x &&
				coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID <= end_x &&
				coordinate[1] >= start_y &&
				coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID <= end_y
			)
			{
				matched.push($('#' + key)[0]);
			}
		});

		return matched;
	}
};

MC.canvas.layout = {
	init: function ()
	{
		var canvas_size = MC.canvas.data.get("layout.size"),
			component = MC.canvas.data.get("component"),
			connections = MC.canvas.data.get('layout.connection'),
			connection_target_id = [];

		$('#canvas_body').css({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT
		});

		$.each(component, function (id, data)
		{
			MC.canvas.add(id);
		});

		$.each(connections, function (line, data)
		{
			$.each(data.target, function (key, value)
			{
				connection_target_id.push(key);
			});

			MC.canvas.connect(
				$('#' + connection_target_id[0]),
				data.target[ connection_target_id[0] ],
				$('#' + connection_target_id[1]),
				data.target[ connection_target_id[1] ],
				{
					'line_uid': line
				}
			);
		});
	},

	create: function ()
	{
		var canvas_size = MC.canvas.data.get("layout.size");

		$('#canvas_body').css({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT
		});
	},

	save: function ()
	{
		return JSON.stringify( MC.tab[ MC.canvas.current_tab ].data );
	}
};

MC.canvas.data = {
	get: function (key)
	{
		var context = MC.tab[ MC.canvas.current_tab ].data,
			namespaces = key.split('.'),
			last = namespaces.pop(),
			i = 0,
			length = namespaces.length,
			context;

		for (; i < length; i++)
		{
			context = context[ namespaces[ i ] ];
		}

		return context[ last ];
	},

	set: function (key, value)
	{
		var context = MC.tab[ MC.canvas.current_tab ].data,
			namespaces = key.split('.'),
			last = namespaces.pop(),
			i = 0,
			length = namespaces.length,
			context;

		for (; i < length; i++)
		{
			context = context[ namespaces[ i ] ];
		}

		return context[ last ] = value;
	},

	delete: function (key)
	{
		var context = MC.tab[ MC.canvas.current_tab ].data,
			namespaces = key.split('.'),
			last = namespaces.pop(),
			i = 0,
			length = namespaces.length,
			context;

		for (; i < length; i++)
		{
			context = context[ namespaces[ i ] ];
		}

		delete context[ last ];
	}
};


MC.canvas.event = {};
MC.canvas.event.dragable = {
	mousedown: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = this,
			target_offset = this.getBoundingClientRect(),
			node_type = $(target).data('type'),
			canvas_offset = $('#svg_canvas').offset(),
			shadow = $(target).clone();

		shadow.attr('class', shadow.attr('class') + ' shadow');
		$('#svg_canvas').append(shadow);

		if (node_type !== 'group')
		{
			$('#canvas_body').addClass('dragging');
		}

		$(document).on({
			'mousemove': MC.canvas.event.dragable.mousemove,
			'mouseup': MC.canvas.event.dragable.mouseup
		}, {
			'target': target,
			'shadow': $(shadow),
			'offsetX': event.pageX - target_offset.left + canvas_offset.left,
			'offsetY': event.pageY - target_offset.top + canvas_offset.top,
			'groupChild': node_type === 'group' ? MC.canvas.groupChild(target) : null,
			'originalPageX': event.pageX,
			'originalPageY': event.pageY
		});

		MC.canvas.event.clearSelected();

		return false;
	},
	mousemove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		event.data.shadow.attr('transform',
			'translate(' +
				Math.round((event.pageX - event.data.offsetX) / 10) * 10 + ',' +
				Math.round((event.pageY - event.data.offsetY) / 10) * 10 +
			')'
		);

		return false;
	},
	mouseup: function (event)
	{
		// Selected
		if (
			event.pageX === event.data.originalPageX &&
			event.pageY === event.data.originalPageY
		)
		{
			$(event.data.target).attr('class', function (index, key)
			{
				return key + ' selected';
			});
			MC.canvas.selected_node.push(event.data.target);
		}
		else
		{
			var target = $(event.data.target),
				target_id = target.attr('id'),
				target_type = target.data('type'),
				canvas_offset = $('#svg_canvas').offset(),
				shadow_offset = event.data.shadow[0].getBoundingClientRect(),
				layout_node_data = MC.canvas.data.get('layout.component.node'),
				layout_connection_data = MC.canvas.data.get('layout.connection'),
				line_layer = $("#line_layer")[0],
				coordinate;

			if (target_type === 'node')
			{
				coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top);

				if (
					MC.canvas.isBlank("node", target_id, coordinate.x, coordinate.y) &&
					MC.canvas.isMatchPlace(layout_node_data[ target_id ].type, coordinate.x, coordinate.y)
				)
				{
					node_connections = layout_node_data[ target_id ].connection || {};

					MC.canvas.position(event.data.target, coordinate.x, coordinate.y);

					$.each(node_connections, function (index, value)
					{
						line_connection = layout_connection_data[ value.line ];

						line_layer.removeChild($('#' + value.line)[0]);

						MC.canvas.connect(
							$('#' + target_id), line_connection['target'][ target_id ],
							$('#' + value.target), line_connection['target'][ value.target ],
							{'line_uid': value['line']}
						);
					});
				}
			}

			if (target_type === 'group')
			{
				var coordinate = MC.canvas.pixelToGrid(
						shadow_offset.left - canvas_offset.left,
						shadow_offset.top - canvas_offset.top - MC.canvas.GROUP_LABEL_OFFSET + parseInt(target.find('.group').css('stroke-width'))
					),
					layout_node_data = MC.canvas.data.get('layout.component.node'),
					layout_connection_data = MC.canvas.data.get('layout.connection'),
					layout_group_data = MC.canvas.data.get('layout.component.group'),
					group_coordinate = layout_group_data[ target_id ].coordinate,
					group_offsetX = coordinate.x - group_coordinate[0],
					group_offsetY = coordinate.y - group_coordinate[1],
					child_data,
					child_type;

				MC.canvas.position(event.data.target, coordinate.x, coordinate.y);

				if (event.data.groupChild.length > 0)
				{
					$.each(event.data.groupChild, function (index, item)
					{
						child_type = $(item).data('type');

						if (child_type === 'node')
						{
							node_data = layout_node_data[ item.id ];

							MC.canvas.position(item, node_data.coordinate[0] + group_offsetX, node_data.coordinate[1] + group_offsetY);

							$.each(node_data.connection, function (i, value)
							{
								line_connection = layout_connection_data[ value.line ];

								line_layer.removeChild(line_connection.SVG);

								MC.canvas.connect(
									$('#' + item.id), line_connection['target'][ item.id ],
									$('#' + value.target), line_connection['target'][ value.target ],
									{'line_uid': value['line']}
								);
							});
						}

						if (child_type === 'group')
						{
							node_data = layout_group_data[ item.id ];

							MC.canvas.position(item, node_data.coordinate[0] + group_offsetX, node_data.coordinate[1] + group_offsetY);
						}
					});
				}
			}
		}

		$('#canvas_body').removeClass('dragging');
		event.data.shadow.remove();

		$(document).off({
			'mousemove': MC.canvas.event.mousemove,
			'mouseup': MC.canvas.event.mouseup
		});
	}
};

MC.canvas.event.drawConnection = {
	mousedown: function (event)
	{
		event.preventDefault();

		var canvas_offset = $('#svg_canvas').offset(),
			target = $(this),
			target_offset = this.getBoundingClientRect(),
			node_id = target.parent().attr('id'),
			node_type = MC.canvas.data.get('component.' + node_id + '.type'),
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			node_connections = layout_node_data[ node_id ].connection,
			offset = {},
			position = target.data('position'),
			port_type = target.data('type'),
			port_name = target.data('name'),
			connection_option = MC.canvas.CONNECTION_OPTION[ node_type ],
			target_connection_option,
			target_data,
			is_connected;

		//calculate point of junction
		switch (position)
		{
			case 'left':
				offset.left = target_offset.left - 8;
				offset.top  = target_offset.top  + 8;
				break;

			case 'right':
				offset.left = target_offset.left + 8;
				offset.top  = target_offset.top + 8;
				break;

			case 'top':
				offset.left = target_offset.left + 8;
				offset.top  = target_offset.top - 0;
				break;

			case 'bottom':
				offset.left = target_offset.left + 8;
				offset.top  = target_offset.top + 8;
				break;
		}

		$(document).on({
			'mousemove': MC.canvas.event.drawConnection.mousemove,
			'mouseup': MC.canvas.event.drawConnection.mouseup
		}, {
			'connect': target.data('connect'),
			'originalTarget': target.parent(),
			'originalX': offset.left - canvas_offset.left,
			'originalY': offset.top - canvas_offset.top,
			'strokeColor': MC.canvas.LINE_COLOR[ port_type ] || "#000000",
			'option': connection_option,
			'port_name': port_name,
			'canvas_offset': canvas_offset
		});

		MC.canvas.event.clearSelected();

		// Highlight connectable node
		$.each(connection_option, function (type, option)
		{
			if ($.type(option) !== 'array')
			{
				option = [option];
			}

			$.each(option, function (index, value)
			{
				if (value.from === port_name)
				{
					$('.' + type.replace(/\./ig, '-') + ':not(#' + node_id + ')').each(function (index, item)
					{
						if (value.relation === 'unique')
						{
							is_connected = false;
							$.each(node_connections, function (index, data)
							{
								if (data.port === value.from)
								{
									is_connected = true;
								}
							});

							if (is_connected)
							{
								return false;
							}
						}
						if (value.relation === 'multiple')
						{
							is_connected = false;

							target_data = layout_node_data[ item.id ];
							target_connection_option = MC.canvas.CONNECTION_OPTION[ target_data.type ][ node_type ];

							if ($.type(target_connection_option) !== 'array')
							{
								target_connection_option = [target_connection_option];
							}
							$.each(target_connection_option, function (index, option)
							{
								$.each(target_data.connection, function (index, data)
								{
									if (data.port === value.to)
									{
										is_connected = true;
									}
								});
							});

							if (is_connected)
							{
								return false;
							}
						}
						$(this)
							.attr("class", function (index, key)
							{
								return "connectable " + key;
							})
							.find('.port-' + value.to).attr("class", function (index, key)
							{
								return "connectable-port " + key;
							});
					});
				}
			});
		});

		return false;
	},

	mousemove: function (event)
	{
		var canvas_offset = event.data.canvas_offset,
			startX = event.data.originalX,
			startY = event.data.originalY,
			endX = event.pageX - canvas_offset.left,
			endY = event.pageY - canvas_offset.top,
			arrow_length = 8,
			angle = Math.atan2(endY - startY, endX - startX),
			arrowPI = Math.PI / 6
			arrowAngleA = angle - arrowPI,
			arrowAngleB = angle + arrowPI;

		if (MC.paper.drewLine)
		{
			MC.paper.clear(MC.paper.drewLine);
		}

		MC.paper.start({
			'fill': 'none',
			'stroke': event.data.strokeColor
		});
		MC.paper.line(startX, startY, endX, endY, {
			'stroke-width': 5
		});
		MC.paper.polygon([
			[endX, endY],
			[endX - arrow_length * Math.cos(arrowAngleA), endY - arrow_length * Math.sin(arrowAngleA)],
			[endX - arrow_length * Math.cos(arrowAngleB), endY - arrow_length * Math.sin(arrowAngleB)]
		], {
			'stroke-width': 3
		});
		MC.paper.drewLine = MC.paper.save();

		return false;
	},

	draw: function (event)
	{
		//event.preventDefault();
		//event.stopPropagation();

		$('#svg_canvas').off('mouseover', '.node', MC.canvas.event.drawConnection.draw);

		var from_node = event.data.originalTarget,
			to_node = $(this),
			port_name = event.data.port_name,
			to_port_name = to_node.find('.connectable-port').data('name');
		// if ($(event.target).hasClass(event.data.connect))
		// {
		// 	start_port = event.data.originalTarget;
		// 	end_port = $(event.target);
		// }
		// else
		// {
		// 	if (event.data.originalTarget.hasClass($(event.target).data('connect')))
		// 	{
		// 		start_port = $(event.target);
		// 		end_port = event.data.originalTarget;
		// 	}
		// 	else
		// 	{
		// 		return false;
		// 	}
		// }

		if (!from_node.is(to_node) && to_port_name !== undefined)
		{
			MC.canvas.connect(event.data.originalTarget, port_name, to_node, to_port_name);
		}

		return true;
	},
	mouseup: function (event)
	{
		MC.paper.clear(MC.paper.drewLine);

		$('#svg_canvas').on('mouseover', '.node', event.data, MC.canvas.event.drawConnection.draw);

		setTimeout(function ()
		{
			$.each(event.data.option, function (type, value)
			{
				$('.' + type.replace(/\./ig, '-'))
					.attr('class', function (index, key)
					{
						return key.replace('connectable ', '');
					})
					.find('.connectable-port').attr("class", function (index, key)
					{
						return key.replace('connectable-port ', '');
					});
			});
		}, 50);

		$(document).off({
			'mousemove': MC.canvas.event.drawConnection.mousemove,
			'mouseup': MC.canvas.event.drawConnection.mouseup,
		});

		return false;
	}
};

MC.canvas.event.siderbarDrag = {
	mousedown: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = $(this),
			target_offset = target.offset(),
			canvas_offset = $('#svg_canvas').offset(),
			shadow,
			clone_node;

		$(document.body).append('<div id="drag_shadow"></div>');
		shadow = $('#drag_shadow');
		clone_node = target.clone();
		shadow.append(clone_node);

		$('#canvas_body').addClass('dragging');

		$(document).on({
			'mousemove': MC.canvas.event.siderbarDrag.mousemove,
			'mouseup': MC.canvas.event.siderbarDrag.mouseup
		}, {
			'target': target,
			'shadow': $(shadow),
			'offsetX': event.pageX - target_offset.left,
			'offsetY': event.pageY - target_offset.top,
		});

		MC.canvas.event.clearSelected();

		return false;
	},
	mousemove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		event.data.shadow.css({
			'top': event.pageY - event.data.offsetY,
			'left': event.pageX - event.data.offsetX
		});

		return false;
	},
	mouseup: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = $(event.data.target),
			target_id = target.attr('id') || '',
			target_component_type = target.data('component-type'),
			node_type = target.data('type'),
			canvas_offset = $('#svg_canvas').offset(),
			shadow_offset = event.data.shadow.position(),
			coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top);

		if (
			target_component_type === 'node' &&
			MC.canvas.isBlank("node", target_id, coordinate.x, coordinate.y) &&
			MC.canvas.isMatchPlace(node_type, coordinate.x, coordinate.y)
		)
		{
			var new_node = MC.canvas.add(node_type, target.data('option'), coordinate );
		}

		if (
			target_component_type === 'group' &&
			MC.canvas.isMatchPlace(node_type, coordinate.x, coordinate.y)
		)
		{
			MC.canvas.add(node_type, target.data('option'), coordinate);
		}

		event.data.shadow.remove();
		$('#canvas_body').removeClass('dragging');

		$(document).off({
			'mousemove': MC.canvas.event.mousemove,
			'mouseup': MC.canvas.event.mouseup
		});
	}
};

MC.canvas.event.groupResize = {
	mousedown: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = event.target,
			parent = $(target.parentNode.parentNode),
			group = parent.find('.group'),
			group_offset = group[0].getBoundingClientRect(),
			canvas_offset = $('#svg_canvas').offset();

		$(document).on({
			'mousemove': MC.canvas.event.groupResize.mousemove,
			'mouseup': MC.canvas.event.groupResize.mouseup
		}, {
			'parent': parent,
			'resizer': target,
			'group_title': parent.find('.group-label'),
			'target': group,
			'group_child': MC.canvas.groupChild(target.parentNode.parentNode),
			'originalX': event.pageX,
			'originalY': event.pageY,
			'originalWidth': group_offset.width,
			'originalHeight': group_offset.height,
			'originalTop': group_offset.top,
			'originalLeft': group_offset.left,
			'canvas_offset': canvas_offset,
			'offsetX': event.pageX - canvas_offset.left,
			'offsetY': event.pageY - canvas_offset.top,
			'direction': $(target).data('direction'),
			'group_border': parseInt(group.css('stroke-width'))
		});
	},
	mousemove: function (event)
	{
		var direction = event.data.direction,
			//group = event.data.group,
			group_border = event.data.group_border * 2,
			left = event.pageX - event.data.originalLeft,
			max_left = event.data.originalWidth,
			top = event.pageY - event.data.originalTop,
			max_top = event.data.originalHeight,
			prop;

		switch (direction)
		{
			case 'topleft':
				prop = {
					'y': top > max_top ? max_top : top,
					'x': left > max_left ? max_left : left,
					'width': event.data.originalWidth - event.pageX + event.data.originalX + group_border,
					'height': event.data.originalHeight - event.pageY + event.data.originalY + group_border
				};
				break;

			case 'topright':
				prop = {
					'y': top > max_top ? max_top : top,
					'width': event.data.originalWidth + event.pageX - event.data.originalX,
					'height': event.data.originalHeight - event.pageY + event.data.originalY + group_border
				};
				break;

			case 'bottomleft':
				prop = {
					'x': left > max_left ? max_left : left,
					'width': event.data.originalWidth - event.pageX + event.data.originalX + group_border,
					'height': event.data.originalHeight + event.pageY - event.data.originalY
				};
				break;

			case 'bottomright':
				prop = {
					'width': event.data.originalWidth + event.pageX - event.data.originalX,
					'height': event.data.originalHeight + event.pageY - event.data.originalY
				};
				break;

			case 'top':
				prop = {
					'y': top > max_top ? max_top : top,
					'height': event.data.originalHeight - event.pageY + event.data.originalY + group_border
				};
				break;

			case 'right':
				prop = {
					'width': event.data.originalWidth + event.pageX - event.data.originalX
				};
				break;

			case 'bottom':
				prop = {
					'height': event.data.originalHeight + event.pageY - event.data.originalY
				};
				break;

			case 'left':
				prop = {
					'x': left > max_left ? max_left : left,
					'width': event.data.originalWidth - event.pageX + event.data.originalX + group_border
				};
				break;
		}

		if (prop.width && prop.width < group_border)
		{
			prop.width = group_border;
		}

		if (prop.height && prop.height < group_border)
		{
			prop.height = group_border;
		}

		event.data.target.attr(prop);

		if (prop.x)
		{
			event.data.group_title.attr('x', prop.x + 1);
		}
		if (prop.y)
		{
			event.data.group_title.attr('y', prop.y - 6);
		}
	},
	mouseup: function (event)
	{
		// var target = event.data.target,
		// 	canvas_offset = $('#svg_canvas').offset(),
		// 	direction = event.data.direction,
		// 	group_id = target.id,
		// 	group_data = MC.canvas.data.get('layout.component.group.' + group_id),
		// 	//zone_data = MC.tab[current_tab].data[zone_id],
		// 	left = event.pageX - canvas_offset.left,
		// 	top = event.pageY - canvas_offset.top,
		// 	mouseX,
		// 	mouseY,
		// 	max_left,
		// 	max_top,
		// 	zone_width,
		// 	zone_height,
		// 	zone_top,
		// 	zone_left,
		// 	zone_minX,
		// 	zone_minY,
		// 	zone_maxX,
		// 	zone_maxY,
		// 	zone_available_X = [],
		// 	zone_available_Y = [];

		var parent = event.data.parent,
			target = event.data.target,
			group_title = event.data.group_title,
			direction = event.data.direction,
			parent_offset = parent[0].getBoundingClientRect(),
			canvas_offset = event.data.canvas_offset,
			offsetX = target.attr('x') * 1,
			offsetY = target.attr('y') * 1,
			group_id = parent.attr('id'),
			group_width = Math.ceil(target.attr('width') / 10),
			group_height = Math.ceil(target.attr('height') / 10),
			group_left = Math.ceil((parent_offset.left - canvas_offset.left + offsetX) / 10),
			group_top = Math.ceil((
					parent_offset.top - canvas_offset.top + offsetY - MC.canvas.GROUP_LABEL_OFFSET + event.data.group_border
				) / 10),
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			node_coordinateX = [],
			node_coordinateY = [],
			group_maxX,
			group_maxY,
			group_minX,
			group_minY;

		$.each(event.data.group_child, function (index, item)
		{
			if (layout_node_data[ item.id ])
			{
				node_coordinateX.push(layout_node_data[ item.id ].coordinate[0]);
				node_coordinateY.push(layout_node_data[ item.id ].coordinate[1]);
			}
		});

		group_maxX = Math.max.apply(Math, node_coordinateX) + MC.canvas.COMPONENT_WIDTH_GRID;
		group_maxY = Math.max.apply(Math, node_coordinateY) + MC.canvas.COMPONENT_HEIGHT_GRID;
		group_minX = Math.min.apply(Math, node_coordinateX);
		group_minY = Math.min.apply(Math, node_coordinateY);

		switch (direction)
		{
			case 'topleft':
				if (group_left >= group_minX)
				{
					group_left = group_minX;
					group_width = group_maxX - group_minX;
				}

				if (group_top >= group_minY)
				{
					group_top = group_minY;
					group_height = group_maxY - group_minY;
				}
				break;

			case 'topright':
				group_width = group_width + group_left >= group_maxX ? group_width : group_maxX - group_left;

				if (group_top >= group_minY)
				{
					group_top = group_minY;
					group_height = group_maxY - group_minY;
				}
				break;

			case 'bottomleft':
				if (group_left >= group_minX)
				{
					group_left = group_minX;
					group_width = group_maxX - group_minX;
				}

				group_height = group_height + group_top >= group_maxY ? group_height : group_maxY - group_top;
				break;

			case 'bottomright':
				group_width = group_width + group_left >= group_maxX ? group_width : group_maxX - group_left;
				group_height = group_height + group_top >= group_maxY ? group_height : group_maxY - group_top;
				break;

			case 'top':
				if (group_top >= group_minY)
				{
					group_top = group_minY;
					group_height = group_maxY - group_minY;
				}
				break;

			case 'right':
				group_width = group_width + group_left >= group_maxX ? group_width : group_maxX - group_left;
				break;

			case 'bottom':
				group_height = group_height + group_top >= group_maxY ? group_height : group_maxY - group_top;
				break;

			case 'left':
				if (group_left >= group_minX)
				{
					group_left = group_minX;
					group_width = group_maxX - group_minX;
				}
				break;
		}

		parent.attr('transform',
			'translate(' +
				group_left * 10 + ',' +
				group_top * 10 +
			')'
		);

		target.attr({
			'x': 0,
			'y': 0,
			'width': group_width * 10,
			'height': group_height * 10
		});

		group_title.attr({
			'x': 1,
			'y': -6
		});

		MC.canvas.data.set('layout.component.group.' + group_id + '.coordinate', [group_left, group_top]);
		MC.canvas.data.set('layout.component.group.' + group_id + '.size', [group_width, group_height]);

		$(document).off({
			'mousemove': MC.canvas.event.groupResize.mousemove,
			'mouseup': MC.canvas.event.groupResize.mouseup
		});

		//update group-resizer
		MC.canvas.updateResizer(parent, group_width, group_height);
	}
};

MC.canvas.event.selectLine = function (event)
{
	event.preventDefault();
	event.stopPropagation();

	MC.canvas.event.clearSelected();

	var line = $(this),
		clone = line.attr('class', function (index, key)
		{
			return key + ' selected';
		});

	line.remove();
	$('#line_layer').append(clone);

	MC.canvas.selected_node.push(this);
};

MC.canvas.event.clearSelected = function ()
{
	$('#svg_canvas .selected').attr('class', function (index, key)
	{
		return key.replace(' selected', '');
	});
	MC.canvas.selected_node = [];
};

MC.canvas.event.keyEvent = function (event)
{
	if (event.which === 46 && MC.canvas.selected_node.length > 0)
	{
		$.each(MC.canvas.selected_node, function (i, node)
		{
			MC.canvas.remove(node);
		});
		MC.canvas.selected_node = [];
	}
};

// MC.canvas = {
// 	zoomOut: function ()
// 	{
// 		var canvas_container = $('#canvas_container'),
// 			content = $('#main_body_content'),
// 			width = canvas_container.width(),
// 			height = canvas_container.height();

// 		scrollbar.scroll_to_top(content, 0);
// 		scrollbar.scroll_to_left(content, 0);

// 		canvas_container.css({
// 			'width': width / 2,
// 			'height': height / 2
// 		});

// 		$('#svg_canvas').css('zoom', 0.5);
// 		$('#node_container').css('zoom', 0.5);
// 		$('#canvas_body').addClass('zoomed');

// 		$('#top_btn_zoom_in').removeClass('disabled').on('click', MC.canvas.zoomIn);
// 		$('#top_btn_zoom_out').addClass('disabled').off('click', MC.canvas.zoomOut);
// 	},

// 	zoomIn: function ()
// 	{
// 		var canvas_container = $('#canvas_container'),
// 			width = canvas_container.width(),
// 			height = canvas_container.height();

// 		canvas_container.css({
// 			'width': width * 2,
// 			'height': height * 2
// 		});
// 		$('#svg_canvas').css('zoom', 1);
// 		$('#node_container').css('zoom', 1);
// 		$('#canvas_body').removeClass('zoomed');

// 		$('#top_btn_zoom_in').addClass('disabled').off('click', MC.canvas.zoomIn);
// 		$('#top_btn_zoom_out').removeClass('disabled').on('click', MC.canvas.zoomOut);
// 	},

// 	focused_node: [],
// 	/**
// 	 * Add node to canvas
// 	 * @param {boject} option
// 	 * @param {[type]} x      [description]
// 	 * @param {[type]} y      [description]
// 	 */
// 	add: function (option, x, y)
// 	{
// 		var new_uid = MC.guid(),
// 			target_zoneX = Math.ceil(x / 140) - 1,
// 			target_zoneY = Math.ceil(y / 100) - 1;

// 		MC.canvas.create(new_uid, option);
// 		MC.canvas.position(new_uid, [target_zoneX, target_zoneY]);

// 		return new_uid;
// 	},

// 	// Create new component according option
// 	create: function (uid, option)
// 	{
// 		var html,
// 			property;

// 		switch (option.type)
// 		{
// 			case 'instance':
// 				html = '<div id="' + uid + '" class="instance node dragable focusable" data-placement="zone">' +
// 				'<div class="node_icon node_amazon"></div>' +
// 				'<div class="port_in_Firewall port connectable" data-connect-name="port_in_Firewall"></div>' +
// 				'<div class="port_out_SecurityGroup port connectable" data-connect-name="port_out_SecurityGroup" data-connect="port_in_Firewall" data-connect-color="#6d9ee1"></div>' +
// 				'<div class="port_out_Volume port connectable" data-connect-name="port_out_Volume" data-connect="port_in_Volume" data-connect-color="#97bf7d"></div>' +
// 				'<div class="attachment_keyPairs"></div>' +
// 				'<div class="attachment_eip"></div>' +
// 				'</div>';
// 				property = {
// 					"type": "instance",
// 					"class": "node",
// 					"connection": {
// 						"port_out_Volume": [],
// 						"port_in_Firewall": [],
// 						"port_out_SecurityGroup": []
// 					},
// 					"placement": "zone",
// 					"attachment": [],
// 					"coordinate": [0, 0],
// 					"size": [1, 1]
// 				};
// 				break;
// 			case 'volume':
// 				html = '<div id="' + uid + '" class="volume node dragable focusable" data-placement="zone">' +
// 				'<div class="port_in_Volume port connectable" data-connect-name="port_in_Volume"></div>' +
// 				'</div>';
// 				property = {
// 					"type": "volume",
// 					"class": "node",
// 					"connection": {
// 						"port_in_Volume": []
// 					},
// 					"placement": "zone",
// 					"coordinate": [0, 0],
// 					"size": [1, 1]
// 				};
// 				break;
// 			case 'elb':
// 				html = '<div id="' + uid + '" class="elb node dragable focusable" data-placement="canvas">' +
// 				'<div class="port_out_ELB port connectable" data-connect-name="port_out_ELB" data-connect="port_in_Firewall" data-connect-color="#6d9ee1"></div>' +
// 				'</div>';
// 				property = {
// 					"type": "elb",
// 					"class": "node",
// 					"connection": {
// 						"port_out_ELB": []
// 					},
// 					"placement": "canvas",
// 					"coordinate": [0, 0],
// 					"size": [1, 1]
// 				};
// 				break;
// 			case 'group':
// 				html = '<div id="' + uid + '" class="zone focusable dragable" data-placement="canvas">' +
// 				'<div class="zone_title">' + option.name + '</div>' +
// 				'<div class="zone_resizer resizer_topleft" data-direction="topleft"></div>' +
// 				'<div class="zone_resizer resizer_topright" data-direction="topright"></div>' +
// 				'<div class="zone_resizer resizer_bottomleft" data-direction="bottomleft"></div>' +
// 				'<div class="zone_resizer resizer_bottomright" data-direction="bottomright"></div>' +
// 				'<div class="zone_resizer resizer_top" data-direction="top"></div>' +
// 				'<div class="zone_resizer resizer_right" data-direction="right"></div>' +
// 				'<div class="zone_resizer resizer_left" data-direction="left"></div>' +
// 				'<div class="zone_resizer resizer_bottom" data-direction="bottom"></div>' +
// 				'</div>';
// 				property = {
// 					"type": "group",
// 					"class": "zone",
// 					"name": "",
// 					"placement": "canvas",
// 					"coordinate": [0, 0],
// 					"size": [1, 1]
// 				};
// 				break;
// 		}

// 		$('#node_container').append(html);

// 		if (MC.tab[current_tab].data[uid] == null)
// 		{
// 			$.each(option, function (name, value)
// 			{
// 				property[name] = value;
// 			});
// 			MC.tab[current_tab].data[uid] = property;
// 		}
// 		else
// 		{
// 			if (MC.tab[current_tab].data[uid]['class'] == 'zone')
// 			{
// 				if (option.type === 'group')
// 				{
// 					$('#' + uid).css({
// 						'width': MC.tab[current_tab].data[uid]['size'][0] * 140 + 100,
// 						'height': MC.tab[current_tab].data[uid]['size'][1] * 100 + 80
// 					});
// 				}
// 				else
// 				{
// 					$('#' + uid).css({
// 						'width': MC.tab[current_tab].data[uid]['size'][0] * 140,
// 						'height': MC.tab[current_tab].data[uid]['size'][1] * 100
// 					});
// 				}
// 			}
// 		}

// 		return html;
// 	},
// 	remove: function (node)
// 	{
// 		var node = $(node),
// 			node_id = node.attr('id'),
// 			node_data = MC.tab[current_tab].data[node_id],
// 			connection;

// 		if (node_data)
// 		{
// 			connection = node_data['connection'];
// 		}
// 		if (connection)
// 		{
// 			$.each(connection, function (name, data)
// 			{
// 				$.each(data, function (key, item)
// 				{
// 					var data = item.SVG.data,
// 						start = MC.tab[current_tab].data[data.start_uid]['connection'][data.start_target],
// 						end = MC.tab[current_tab].data[data.end_uid]['connection'][data.end_target];

// 					start.splice(start.indexOf(data.start_connection), 1);
// 					end.splice(end.indexOf(data.end_connection), 1);
// 					MC.paper.clear(item.SVG);
// 				});
// 			});
// 		}

// 		node.remove();
// 		delete MC.tab[current_tab].data[node_id];
// 	},
// 	// - component
// 	// - x: zone X
// 	// - y: zone Y
// 	// canvas 坐标 [2, 3]
// 	position: function (uid, coordinate)
// 	{
// 		if (coordinate[0] < 0 || coordinate[1] < 0)
// 		{
// 			return;
// 		}

// 		var node = $('#' + uid),
// 			node_class = MC.tab[current_tab].data[uid]['class'],
// 			finalX,
// 			finalY;

// 		if (node_class == 'node')
// 		{
// 			finalX = coordinate[0] * 140 + ((140 - node.outerWidth()) / 2),
// 			finalY = coordinate[1] * 100 + ((100 - node.outerHeight()) / 2);
// 		}
// 		if (node_class == 'zone')
// 		{
// 			finalX = coordinate[0] * 140 - 50;
// 			finalY = coordinate[1] * 100 - 40;
// 		}

// 		MC.tab[current_tab].data[uid]['coordinate'] = coordinate;
// 		node.css({
// 			'left': finalX,
// 			'top': finalY
// 		});
// 	},
// 	// Final
// 	// - component
// 	// - x: drop X
// 	// - y: drop Y
// 	// 鼠标坐标 [231, 312]
// 	drop: function (uid, zoneX, zoneY)
// 	{
// 		var is_blank = true,
// 			connection;

// 		if (zoneX >= 0 && zoneY >= 0)
// 		{
// 			$.each(MC.tab[current_tab].data, function (uid, item)
// 			{
// 				if (
// 					item.coordinate[0] == zoneX &&
// 					item.coordinate[1] == zoneY &&
// 					item.class == 'node'
// 				)
// 				{
// 					is_blank = false;
// 				}
// 			});
// 			if (is_blank)
// 			{
// 				MC.canvas.position(uid, [zoneX, zoneY]);
// 			}
// 			else
// 			{
// 				return;
// 			}
// 		}
// 		else
// 		{
// 			return;
// 		}

// 		connection = MC.tab[current_tab].data[uid]['connection'];
// 		if (connection)
// 		{
// 			$.each(connection, function (name, data)
// 			{
// 				$.each(data, function (key, item)
// 				{
// 					MC.paper.clear(item.SVG);
// 					if (item.type == "out")
// 					{
// 						MC.canvas.connect($('#' + uid), name, $('#' + item.uid), item.target, item.color);
// 					}
// 					else
// 					{
// 						MC.canvas.connect($('#' + item.uid), item.target, $('#' + uid), name, item.color);
// 					}
// 				});
// 			});
// 		}
// 	},
// 	move: function (uid, zoneX, zoneY)
// 	{
// 		if (zoneX > 0 && zoneY > 0)
// 		{
// 			MC.canvas.position(uid, [zoneX, zoneY]);
// 		}
// 		else
// 		{
// 			return;
// 		}

// 		var connection = MC.tab[current_tab].data[uid]['connection'];
// 		if (connection)
// 		{
// 			$.each(connection, function (name, data)
// 			{
// 				$.each(data, function (key, item)
// 				{
// 					MC.paper.clear(item.SVG);
// 					if (item.type == "out")
// 					{
// 						MC.canvas.connect($('#' + uid), name, $('#' + item.uid), item.target, item.color);
// 					}
// 					else
// 					{
// 						MC.canvas.connect($('#' + item.uid), item.target, $('#' + uid), name, item.color);
// 					}
// 				});
// 			});
// 		}
// 	},

// 	get_path: function (prev,current,next)
// 	{
// 		//add by xjimmy, generate path by three point

// 		var sign  = 0;
// 		var delta = 0;
// 		var pad   = 10;

// 		if (prev[0] === current[0]) { /*1.above or below*/

// 			//1.1 calc p1
// 			delta = current[1] - prev[1];
// 			if (Math.abs(delta) <= pad)
// 			{
// 				p1 = prev;
// 			}
// 			else
// 			{
// 				sign  = delta ? (delta < 0 ? -1 : 1) : 0;
// 				p1    = [current[0], current[1] - pad * sign];
// 			}

// 			//1.2 calc p2
// 			delta = current[0] - next[0];
// 			if (Math.abs(delta) <= pad)
// 			{
// 				p2 = next;
// 			}
// 			else
// 			{
// 				sign  = delta ? (delta < 0 ? -1 : 1) : 0;
// 				p2    = [current[0] - pad * sign, current[1]];
// 			}

// 		} else { /*2.left or right*/

// 			//2.1 calc p1
// 			delta = current[0] - prev[0];
// 			if (Math.abs(delta) <= pad)
// 			{
// 				p1 = prev;
// 			}
// 			else
// 			{
// 				sign  = delta ? (delta < 0 ? -1 : 1) : 0;
// 				p1    = [current[0] - pad * sign, current[1]];
// 			}

// 			//2.2 calc p2
// 			delta = current[1] - next[1];
// 			if (Math.abs(delta) <= pad)
// 			{
// 				p2 = next;
// 			}
// 			else
// 			{
// 				sign  = delta ? (delta < 0 ? -1 : 1) : 0;
// 				p2    = [current[0], current[1] - pad * sign];
// 			}

// 		}
// 		return " L %d %d Q %d %d %d %d".format(p1[0], p1[1], current[0], current[1], p2[0], p2[1]);
// 	},


// 	connect: function (start_node, start_target, end_node, end_target, color)
// 	{
// 		var canvas_offset = $('#svg_canvas').offset(),
// 			start_uid = start_node.attr('id'),
// 			end_uid = end_node.attr('id'),
// 			start_offset = start_node.offset(),
// 			end_offset = end_node.offset(),
// 			// start_port = start_node.find('.' + start_target),
// 			// end_port = end_node.find('.' + end_target),
// 			// start_port_offset = start_port.offset(),
// 			// end_port_offset = end_port.offset(),
// 			startX = start_offset.left + (start_node.width() / 2) - canvas_offset.left,
// 			startY = start_offset.top + (start_node.height() / 2) - canvas_offset.top,
// 			endX = end_offset.left + (end_node.width() / 2) - canvas_offset.left,
// 			endY = end_offset.top + (end_node.height() / 2) - canvas_offset.top,
// 			start_connection,
// 			end_connection,
// 			paddingY,
// 			connector,
// 			is_start_connected,
// 			is_end_connected,
// 			is_connected,
// 			line_path;

// 		if (MC.tab[current_tab].data[start_uid]['connection'][start_target] == undefined)
// 		{
// 			MC.tab[current_tab].data[start_uid]['connection'][start_target] = [];
// 		}

// 		if (MC.tab[current_tab].data[end_uid]['connection'][end_target] == undefined)
// 		{
// 			MC.tab[current_tab].data[end_uid]['connection'][end_target] = [];
// 		}

// 		MC.paper.start({
// 			'fill': 'none',
// 			'stroke': color,
// 			'stroke-linejoin': 'round',
// 			'stroke-width': 4
// 		});

// 		// if (startX > endX)
// 		// {
// 		//	paddingY = ( startY > endY ) ? startY - 30 : startY + 30;
// 		//	line_path = [
// 		//		// Start
// 		//		[startX, startY],
// 		//		// To start padding
// 		//		[startX + 10, startY],
// 		//		// To center line
// 		//		// [startX + 10, (startY + endY) / 2],
// 		//		[startX + 10, paddingY],
// 		//		// Center line
// 		//		// [endX - 10, (startY + endY) / 2],
// 		//		[endX - 10, paddingY],
// 		//		// Center line padding
// 		//		[endX - 10, endY],
// 		//		// Center line to end
// 		//		[endX, endY]
// 		//	];
// 		// }
// 		// else
// 		// {
// 			line_path = [
// 				// Start
// 				[startX, startY],
// 				// To center line
// 				[(startX + endX) / 2, startY],
// 				// Center line
// 				[(startX + endX) / 2, endY],
// 				// Center line to end
// 				[endX, endY]
// 			];
// 		// }

// 		// MC.paper.polyline(line_path, {
// 		//	'fill': 'none',
// 		//	'stroke': '#aaa',
// 		//	'stroke-linejoin': 'round',
// 		//	'stroke-width': 5
// 		// });


// 		//add by xjimmy
// 		var style = {
// 			'fill': 'none',
// 			'stroke': '#aaa',
// 			'stroke-linejoin': 'round',
// 			'stroke-width': 5
// 		};
// 		var d = "";
// 		var last_p = [];
// 		$.each(line_path, function (idx, value) {
// 			if (idx === 0) { //start point
// 				d = "M %d %d".format(value[0], value[1]);
// 			} else if (idx === (line_path.length - 1)) { //end point
// 				d += " L %d %d".format(value[0], value[1]);
// 			} else { //middle point
// 				prev_p = line_path[idx - 1]; //prev point
// 				next_p = line_path[idx + 1]; //next point
// 				d += MC.canvas.get_path(prev_p, value, next_p);

// 				//d+=" L %d %d".format(value[0], value[1]);
// 			}

// 			last_p = value;
// 		});

// 		if (d !== "") {
// 			MC.paper.path(d, style);
// 			MC.paper.path(d);
// 		}

// 		connector = MC.paper.save();

// 		$.each(MC.tab[current_tab].data[start_uid]['connection'][start_target], function (key, data)
// 		{
// 			if (data.uid === end_uid)
// 			{
// 				data.SVG = connector;
// 				is_start_connected = true;
// 				start_connection = data;
// 			}
// 		});

// 		if (is_start_connected != true)
// 		{
// 			start_connection = {
// 				"type": "out",
// 				"color": color,
// 				"SVG": connector,
// 				"target": end_target,
// 				"uid": end_uid
// 			};
// 			MC.tab[current_tab].data[start_uid]['connection'][start_target].push(start_connection);
// 		}

// 		$.each(MC.tab[current_tab].data[end_uid]['connection'][end_target], function (key, data)
// 		{
// 			if (data.uid === start_uid)
// 			{
// 				data.SVG = connector;
// 				is_end_connected = true;
// 				end_connection = data;
// 			}
// 		});

// 		if (is_end_connected != true)
// 		{
// 			end_connection = {
// 				"type": "in",
// 				"color": color,
// 				"SVG": connector,
// 				"target": start_target,
// 				"uid": start_uid
// 			};
// 			MC.tab[current_tab].data[end_uid]['connection'][end_target].push(end_connection);
// 		}

// 		connector.data = {
// 			'start_uid': start_uid,
// 			'start_target': start_target,
// 			'start_connection': start_connection,
// 			'end_uid': end_uid,
// 			'end_target': end_target,
// 			'end_connection': end_connection,
// 			'color': color
// 		};

// 		$(connector).on({
// 			'click': MC.canvas.connection.focus,
// 			'dblclick': MC.canvas.connection.setting
// 		});
// 	},

// 	propertyInit: function (key, option)
// 	{
// 		var attachment = option.attachment;
// 		if (attachment && attachment != [])
// 		{
// 			$.each(attachment, function (i, name)
// 			{
// 				$('#' + key).addClass('attached_' + name);
// 			});
// 		}
// 	},
// 	// Layout initialization
// 	layout: {
// 		init: function (data)
// 		{
// 			var data = layout;

// 			MC.tab[current_tab] = {};

// 			MC.tab[current_tab].data = data;
// 			$.each(data, function (key, option)
// 			{
// 				MC.canvas.create(key, option);
// 				MC.canvas.propertyInit(key, option);
// 				MC.canvas.position(key, option.coordinate);
// 			});

// 			$.each(data, function (key, option)
// 			{
// 				if (option.connection)
// 				{
// 					$.each(option.connection, function (name, data)
// 					{
// 						$.each(data, function (i, item)
// 						{
// 							if (item.type == 'out')
// 							{
// 								MC.canvas.connect($('#' + key), name, $('#' + item.uid), item.target, item.color);
// 							}
// 						});
// 					});
// 				}
// 			});
// 		},
// 		save: function ()
// 		{
// 			var layout_data = MC.tab[current_tab].data;
// 			$.each(layout_data, function (uid, item)
// 			{
// 				if (item.connection)
// 				{
// 					$.each(item.connection, function (key, data)
// 					{
// 						$.each(data, function (i, connection)
// 						{
// 							delete connection.SVG;
// 						});
// 					});
// 				}
// 			});
// 			return JSON.stringify(layout_data);
// 		},
// 		analysis: function (data)
// 		{
// 			topo_map = {};
// 			topo_map['children'] = [];

// 			var groupID = 'sg-906987fb',
// 				appName = 'app-7585c21b';

// 			var data = data.data,
// 				data_ELBs = data.DescribeLoadBalancersResponse.DescribeLoadBalancersResult.LoadBalancerDescriptions.member,
// 				data_Volumes = data.DescribeVolumesResponse.volumeSet.item,
// 				data_Instances = data.DescribeInstancesResponse.reservationSet.item,
// 				data_SecurityGroup = data.DescribeSecurityGroupsResponse.securityGroupInfo.item,
// 				ELBs = [],
// 				volumes = [],
// 				instances = [],
// 				zone = {},
// 				topo_root,
// 				placement,
// 				hasELB,
// 				instanceId,
// 				port_out_Volume,
// 				topo_top,
// 				ELB_center,
// 				ELB_start,
// 				zone_width,
// 				zone_height,
// 				zone_uid,
// 				zone_top;

// 			 // Private_IP = {};
// 			 // Pubilc_IP = {};
// 			 // SecurityGroup_Rule = {};

// 			 if (data_ELBs != null)
// 			 {
// 				if (data_ELBs.length)
// 				{
// 					$.each(data_ELBs, function (i, item)
// 					{
// 						if (item.LoadBalancerName.indexOf(appName) > -1)
// 						{
// 							ELBs.push({'name': item.LoadBalancerName, 'data': item});
// 						}
// 					});
// 				}
// 				else
// 				{
// 					ELBs.push({'name': data_ELBs.LoadBalancerName, 'data': data_ELBs});
// 				}
// 			}

// 			 $.each(data_Instances, function (i, instance)
// 			 {
// 				// Private IP
// 				var instance_id = instance.instancesSet.item.instanceId,
// 					instance_private_ip = instance.instancesSet.item.privateIpAddress,
// 					instance_public_ip = instance.instancesSet.item.IpAddress,
// 					instance_sg_id = instance.instancesSet.item.groupSet.item.groupId;

// 				if (instance_private_ip)
// 				{
// 					if (Private_IP[instance_private_ip] == undefined)
// 					{
// 						Private_IP[instance_private_ip] = [];
// 					}
// 					Private_IP[instance_private_ip].push(instance_id);
// 				}

// 				// Public IP
// 				if (instance_public_ip)
// 				{
// 					if (Pubilc_IP[instance_public_ip] == undefined)
// 					{
// 						Pubilc_IP[instance_public_ip] = [];
// 					}
// 					Pubilc_IP[instance_public_ip].push(instance_id);
// 				}

// 				// SecurityGroup
// 				$.each(data_SecurityGroup, function (i, item)
// 				{
// 					if (item.groupId == instance_sg_id)
// 					{
// 						if (item.ipPermissions)
// 						{
// 							if (item.ipPermissions.item.length)
// 							{
// 								$.each(item.ipPermissions.item, function (i, sgData)
// 								{
// 									// For ipRanges
// 									var ipRanges = sgData.ipRanges.item;

// 									if (ipRanges != null && !ipRanges.length)
// 									{
// 										ipRanges = [ipRanges];
// 									}
// 									$.each(ipRanges, function (i, range)
// 									{
// 										var ip = range.cidrIp.replace('/32', '');
// 										if (range.cidrIp.indexOf('/32') != -1)
// 										{
// 											if (SecurityGroup_Rule[ip] == undefined)
// 											{
// 												SecurityGroup_Rule[ip] = [];
// 											}
// 											SecurityGroup_Rule[ip].push(instance_id);
// 										}
// 									});

// 									// For Groups
// 									var ip_security_group = sgData.groups;

// 									if (ip_security_group != null && !ip_security_group.length)
// 									{
// 										ip_security_group = [ip_security_group];
// 									}
// 									$.each(ip_security_group, function (i, group)
// 									{
// 										if (group.groupId)
// 										{
// 											if (SecurityGroup_Rule[group.groupId] == undefined)
// 											{
// 												SecurityGroup_Rule[group.groupId] = [];
// 											}
// 											SecurityGroup_Rule[group.groupId].push(instance_id);
// 										}
// 									});
// 								});
// 							}
// 						}
// 					}
// 				});

// 				// Find target instances by groupID
// 				if (
// 					instance.groupSet.item != undefined &&
// 					instance.groupSet.item.groupId == groupID
// 				)
// 				{
// 					placement = instance.instancesSet.item.placement.availabilityZone;

// 					if (zone[placement] == undefined)
// 					{
// 						zone[placement] = [];
// 					}

// 					zone[placement].push({
// 						'name': instance.instancesSet.item.instanceId,
// 						'data': instance.instancesSet.item
// 					});
// 				}
// 			 });

// 			$.each(zone, function (key, instance_wrap)
// 			{
// 				$.each(instance_wrap, function (i, data)
// 				{
// 					instances.push(data);
// 				});
// 			});

// 			// List all instances
// 			$.each(instances, function (i, instance)
// 			{
// 				instanceId = instance.data.instanceId;

// 				// Place instance
// 				topo_data = {};
// 				topo_data['name'] = instanceId;

// 				// Check instances and remove from instance stack.

// 				// Check volume
// 				port_out_Volume = [];
// 				rootVolume = instance['data']['rootDeviceName'];

// 				if (instance.data.blockDeviceMapping.item != undefined)
// 				{
// 					instance_volumes = instance.data.blockDeviceMapping.item;
// 					if (instance_volumes.length)
// 					{
// 						$.each(instance_volumes, function (i, item)
// 						{
// 							if (item.deviceName != rootVolume)
// 							{
// 								if (topo_data['children'] == undefined)
// 								{
// 									topo_data['children'] = [];
// 								}
// 								topo_data['children'].push({'name': item.ebs.volumeId});

// 								layout[item.ebs.volumeId] = {
// 									"type": "volume",
// 									"class": "node",
// 									"connection": {
// 										"port_in_Volume": [
// 											{
// 												"type": "in",
// 												"target": "port_out_Volume",
// 												"uid": instanceId,
// 												"color": "#97bf7d"
// 											}
// 										]
// 									},
// 									"placement": "zone",
// 									"zone": "",
// 									"coordinate": [],
// 									"size": [1, 1]
// 								};
// 								port_out_Volume.push({
// 									"type": "out",
// 									"target": "port_in_Volume",
// 									"uid": item.ebs.volumeId,
// 									"color": "#97bf7d"
// 								});
// 							}
// 						});
// 					}
// 				}

// 				layout[instanceId] = {
// 					"type": "instance",
// 					"class": "node",
// 					"connection": {
// 						"port_out_Volume": port_out_Volume,
// 						"port_in_Firewall": [],
// 						"port_out_SecurityGroup": []
// 					},
// 					"attachment": [],
// 					"placement": "zone",
// 					"zone": "",
// 					"coordinate": [],
// 					"size": [1, 1]
// 				};

// 				topo_map['children'].push(topo_data);
// 			});

// 			MC.topo(topo_map);

// 			// Place ELB
// 			if (ELBs.length > 0)
// 			{
// 				topo_top = topo_map['children'];
// 				ELB_center = Math.ceil((topo_top[0].coordinate[1] + topo_top[topo_top.length - 1].coordinate[1]) / 2);
// 				ELB_port = [];

// 				ELB_start = ELB_center - (ELBs.length - 1);
// 				ELB_start = ELB_start <= 1 ? 1 : ELB_start;

// 				$.each(ELBs, function (i, ELB)
// 				{
// 					$.each(ELB.data.Instances.member, function (i, item)
// 					{
// 						layout[item.InstanceId]['connection']['port_in_Firewall'].push({
// 							"type": "in",
// 							"target": "port_out_ELB",
// 							"uid": ELB.data.LoadBalancerName,
// 							"color": "#6d9ee1"
// 						});
// 						ELB_port.push({
// 							"type": "out",
// 							"target": "port_in_Firewall",
// 							"uid": item.InstanceId,
// 							"color": "#6d9ee1"
// 						});
// 					});

// 					layout[ELB.data.LoadBalancerName] = {
// 						"type": "elb",
// 						"class": "node",
// 						"connection": {
// 							"port_out_ELB": ELB_port
// 						},
// 						"placement": "canvas",
// 						"coordinate": [0, ELB_start],
// 						"size": [1, 1]
// 					};

// 					ELB_start += 2;
// 				});
// 			}

// 			// Calculate zone width and height
// 			function zoneNode(node, zone_uid)
// 			{
// 				if (node.children != undefined)
// 				{
// 					$.each(node.children, function (i, item)
// 					{
// 						zoneNode(item, zone_uid);
// 					});
// 				}
// 				else
// 				{
// 					if (node.coordinate[0] > zone_width)
// 					{
// 						zone_width = node.coordinate[0];
// 					}
// 					if (node.coordinate[1] > zone_height)
// 					{
// 						zone_height = node.coordinate[1];
// 					}
// 				}
// 				layout[node.name]['zone'] = zone_uid;
// 			}

// 			zone_top = 1;
// 			$.each(zone, function (key, instance_wrap)
// 			{
// 				zone_width = 1;
// 				zone_height = 1;
// 				zone_uid = MC.guid();

// 				$.each(instance_wrap, function (i, instance_item)
// 				{
// 					$.each(topo_map.children, function (i, item)
// 					{
// 						if (item.name == instance_item.name)
// 						{
// 							zoneNode(item, zone_uid);
// 						}
// 					});
// 				});

// 				layout[zone_uid] = {
// 					"type": "group",
// 					"class": "zone",
// 					"placement": "canvas",
// 					"name": key,
// 					"coordinate": [1, zone_top],
// 					"size": [zone_width, zone_height]
// 				};

// 				zone_top += zone_height;
// 			});
// 		}
// 	},
// 	connection: {
// 		focus: function (event)
// 		{
// 			var target = event.target;
// 			target.style.stroke = '#B25B91';

// 			$(target.parentNode).off({
// 				'click': MC.canvas.connection.focus
// 			});
// 			setTimeout(function ()
// 			{
// 				$(document).on({
// 					'click': MC.canvas.connection.blur,
// 					'keyup': MC.canvas.connection.remove
// 				}, {"focused_connector": target});
// 			}, 5);

// 			MC.canvas.focused_node = [];
// 		},
// 		blur: function (event)
// 		{
// 			var target = event.data.focused_connector;
// 			target.style.stroke = target.parentNode.color;

// 			$(document).off({
// 				'click': MC.canvas.connection.blur,
// 				'keyup': MC.canvas.connection.remove
// 			});

// 			$(target.parentNode).on({
// 				'click': MC.canvas.connection.focus
// 			});
// 		},
// 		setting: function (event)
// 		{
// 			alert('dblclick event popup comes');

// 			$(event.target.parentNode).on({
// 				'click': MC.canvas.connection.focus
// 			});
// 			return false;
// 		},
// 		remove: function (event)
// 		{
// 			if (event.which == 46)
// 			{
// 				var target = event.data.focused_connector;
// 					data = target.parentNode.data,
// 					start = MC.tab[current_tab].data[data.start_uid]['connection'][data.start_target],
// 					end = MC.tab[current_tab].data[data.end_uid]['connection'][data.end_target];

// 				start.splice(start.indexOf(data.start_connection), 1);
// 				end.splice(end.indexOf(data.end_connection), 1);
// 				MC.paper.clear(target.parentNode);

// 				$(document).off({
// 					'click': MC.canvas.connection.blur,
// 					'keyup': MC.canvas.connection.remove
// 				});
// 			}
// 		}
// 	},
// 	selection: {
// 		mousedown: function (event)
// 		{
// 			event.preventDefault();
// 			event.stopPropagation();

// 			var target = $(event.target),
// 				target_offset = target.offset(),
// 				canvas_offset = $('#svg_canvas').offset();

// 			$('#canvas_container').append('<div id="canvas_select_ranger"></div>');

// 			$(document).on({
// 				'mousemove': MC.canvas.selection.mousemove,
// 				'mouseup': MC.canvas.selection.mouseup
// 			}, {
// 				'target': target,
// 				'originalX': event.pageX - canvas_offset.left + 22,
// 				'originalY': event.pageY - canvas_offset.top + 22
// 			});

// 		},
// 		mousemove: function (event)
// 		{
// 			var canvas_offset = $('#canvas_container').offset(),
// 				originalX = event.data.originalX,
// 				originalY = event.data.originalY,
// 				currentX = event.pageX - canvas_offset.left,
// 				currentY = event.pageY - canvas_offset.top,
// 				ranger_width,
// 				ranger_height,
// 				ranger_top,
// 				ranger_left;

// 			if (currentX > originalX)
// 			{
// 				ranger_width = currentX - originalX;
// 				ranger_left = originalX;
// 			}
// 			else
// 			{
// 				ranger_width = originalX - currentX;
// 				ranger_left = currentX;
// 			}
// 			if (currentY > originalY)
// 			{
// 				ranger_height = currentY - originalY;
// 				ranger_top = originalY;
// 			}
// 			else
// 			{
// 				ranger_height = originalY - currentY;
// 				ranger_top = currentY;
// 			}
// 			$('#canvas_select_ranger').css({
// 				'left': ranger_left,
// 				'top': ranger_top,
// 				'width': ranger_width,
// 				'height': ranger_height
// 			});
// 		},
// 		mouseup: function (event)
// 		{
// 			var canvas_offset = $('#canvas_container').offset(),
// 				originalX = Math.ceil(event.data.originalX / 140) - 1,
// 				originalY = Math.ceil(event.data.originalY / 100) - 1,
// 				currentX = Math.ceil((event.pageX - canvas_offset.left) / 140) - 1,
// 				currentY = Math.ceil((event.pageY - canvas_offset.top) / 100) - 1,
// 				matched_component = [],
// 				startX,
// 				endX,
// 				startY,
// 				endY;

// 			if (currentX > originalX)
// 			{
// 				startX = originalX;
// 				endX = currentX;
// 			}
// 			else
// 			{
// 				startX = currentX;
// 				endX = originalX;
// 			}
// 			if (currentY > originalY)
// 			{
// 				startY = originalY;
// 				endY = currentY;
// 			}
// 			else
// 			{
// 				startY = currentY;
// 				endY = originalY;
// 			}

// 			$.each(MC.tab[current_tab].data, function (uid, item)
// 			{
// 				if (
// 					item.coordinate[0] >= startX &&
// 					item.coordinate[0] <= endX &&
// 					item.coordinate[1] >= startY &&
// 					item.coordinate[1] <= endY
// 				)
// 				{
// 					matched_component.push(uid);
// 				}
// 			});

// 			$.each(matched_component, function(i, uid)
// 			{
// 				$('#' + uid).addClass('focused');
// 			});

// 			MC.canvas.focused_node = matched_component;

// 			$('#canvas_select_ranger').remove();
// 			$(document).off({
// 				'mousemove': MC.canvas.selection.mousemove,
// 				'mouseup': MC.canvas.selection.mouseup
// 			});
// 		}
// 	},

// 	line_connect: {
// 		originalX: 0,
// 		originalY: 0,

// 		isConnected: false,
// 		connectedTarget: null,

// 		mousedown: function (event)
// 		{
// 			var canvas_offset = $('#svg_canvas').offset(),
// 				target = $(event.target),
// 				target_offset = target.offset(),
// 				connect_name = target.data('connect-name'),
// 				connect_target = target.data('connect'),
// 				node_id = target.parent().attr('id');

// 			$(document).on({
// 				'mousemove': MC.canvas.line_connect.mousemove,
// 				'mouseup': MC.canvas.line_connect.mouseup,
// 			}, {
// 				'connect': target.data('connect'),
// 				'originalTarget': target
// 			});

// 			$('#canvas_body .port').each(function (i, port)
// 			{
// 				var port = $(port);
// 				if (port.parent().attr('id') != node_id && (port.data('connect') == connect_name || port.data('connect-name') == connect_target))
// 				{
// 					port.addClass('attachable');
// 				}
// 			});

// 			$('.focusable').removeClass('focused');
// 			MC.canvas.focused_node = [];

// 			MC.canvas.line_connect.originalX = target_offset.left - canvas_offset.left + (target.width() / 2);
// 			MC.canvas.line_connect.originalY = target_offset.top - canvas_offset.top + (target.height() / 2);

// 			return false;
// 		},
// 		mousemove: function (event)
// 		{
// 			var canvas_offset = $('#svg_canvas').offset(),
// 				startX = MC.canvas.line_connect.originalX,
// 				startY = MC.canvas.line_connect.originalY,
// 				endX = event.pageX - canvas_offset.left,
// 				endY = event.pageY - canvas_offset.top,
// 				arrow_length = 8,
// 				line_offset = 20,
// 				angle = Math.atan2(endY - startY, endX - startX),
// 				arrowPI = Math.PI / 6;

// 			if (MC.paper.drewLine)
// 			{
// 				MC.paper.clear(MC.paper.drewLine);
// 			}

// 			MC.paper.start({
// 				'fill': 'none',
// 				'stroke': '#09c'
// 			});
// 			MC.paper.line(startX, startY, endX, endY, {
// 				'stroke-width': 5
// 			});
// 			MC.paper.polygon([
// 				[endX, endY],
// 				[endX - arrow_length * Math.cos(angle - arrowPI), endY - arrow_length * Math.sin(angle - arrowPI)],
// 				[endX - arrow_length * Math.cos(angle + arrowPI), endY - arrow_length * Math.sin(angle + arrowPI)]
// 			], {
// 				'stroke-width': 3
// 			});
// 			MC.paper.drewLine = MC.paper.save();

// 			return false;
// 		},
// 		drawConnector: function (event)
// 		{
// 			event.preventDefault();
// 			event.stopPropagation();

// 			$(document).off('mouseover', MC.canvas.line_connect.drawConnector);

// 			if ($(event.target).hasClass(event.data.connect))
// 			{
// 				start_port = event.data.originalTarget;
// 				end_port = $(event.target);
// 			}
// 			else
// 			{
// 				if (event.data.originalTarget.hasClass($(event.target).data('connect')))
// 				{
// 					start_port = $(event.target);
// 					end_port = event.data.originalTarget;
// 				}
// 				else
// 				{
// 					return false;
// 				}
// 			}

// 			var start_uid = start_port.parent().attr('id'),
// 				end_uid = end_port.parent().attr('id'),
// 				is_connected;

// 			if (start_uid === end_uid)
// 			{
// 				return false;
// 			}

// 			$.each(MC.tab[current_tab].data[start_uid]['connection'][start_port.data('connect-name')], function (key, data)
// 			{
// 				if (data.uid === end_uid)
// 				{
// 					is_connected = true;
// 				}
// 			});

// 			if (is_connected)
// 			{
// 				return false;
// 			}

// 			MC.canvas.connect(start_port.parent(), start_port.data('connect-name'), end_port.parent(), end_port.data('connect-name'), start_port.data('connect-color'));

// 			return true;
// 		},
// 		mouseup: function (event)
// 		{
// 			MC.paper.clear(MC.paper.drewLine);

// 			$('#node_container').css('zIndex', '99');
// 			$(document).on('mouseover', event.data, MC.canvas.line_connect.drawConnector);
// 			$('#node_container').css('zIndex', '1');

// 			$(document).off({
// 				'mousemove': MC.canvas.line_connect.mousemove,
// 				'mouseup': MC.canvas.line_connect.mouseup
// 			});

// 			$('#canvas_body .port').removeClass('attachable');

// 			return false;
// 		}
// 	}
// };

// MC.drag = {
// 	canvas: {
// 		mousedown: function (event)
// 		{
// 			event.preventDefault();
// 			event.stopPropagation();

// 			var target = $(event.currentTarget),
// 				target_offset = target.offset(),
// 				canvas_offset = $('#svg_canvas').offset(),
// 				shadow,
// 				clone_node;

// 			$('#node_container').append('<div id="drag_shadow"></div>');
// 			shadow = $('#drag_shadow');
// 			clone_node = target.clone().css({
// 				'top': 0,
// 				'left': 0,
// 				'zIndex': 900
// 			});
// 			shadow.append(clone_node).hide();

// 			$(document).on({
// 				'mousemove': MC.drag.canvas.mousemove,
// 				'mouseup': MC.drag.canvas.mouseup
// 			}, {
// 				'target': target,
// 				'shadow': shadow,
// 				'offsetX': event.pageX - target_offset.left + canvas_offset.left,
// 				'offsetY': event.pageY - target_offset.top + canvas_offset.top,
// 				'originalX': target.css('left'),
// 				'originalY': target.css('top'),
// 				'zIndex': target.css('zIndex')
// 			});

// 			$('.focusable').removeClass('focused');
// 			MC.canvas.focused_node = [];
// 			$('#node_container').css('zIndex', '99');
// 			//target.css('zIndex', '900');

// 			return false;
// 		},
// 		mousemove: function (event)
// 		{
// 			event.preventDefault();
// 			event.stopPropagation();

// 			event.data.shadow.css({
// 				'top': event.pageY - event.data.offsetY,
// 				'left': event.pageX - event.data.offsetX
// 			}).show();

// 			return false;
// 		},
// 		mouseup: function (event)
// 		{
// 			event.preventDefault();
// 			event.stopPropagation();

// 			event.data.shadow.remove();

// 			var target = $(event.data.target),
// 				target_id = target.attr('id'),
// 				canvas_offset = $('#svg_canvas').offset(),
// 				node_class = MC.tab[current_tab].data[target.attr('id')]['class'],
// 				placement = target.data('placement'),
// 				zone_offsetX,
// 				zone_offsetY,
// 				is_matchX,
// 				is_matchY,
// 				is_drop_place_match;

// 			target.css({
// 				'zIndex': event.data.zIndex == 'auto' ? '' : event.data.zIndex
// 			});

// 			if (node_class == 'zone')
// 			{
// 				target_zoneX = Math.round((event.pageX - event.data.offsetX + 60) / 140);
// 				target_zoneY = Math.round((event.pageY - event.data.offsetY + 20) / 100);

// 				if (target_zoneX > 0 && target_zoneY > 0)
// 				{
// 					zone_offsetX = target_zoneX - MC.tab[current_tab].data[target_id]['coordinate'][0];
// 					zone_offsetY = target_zoneY - MC.tab[current_tab].data[target_id]['coordinate'][1];
// 					$.each(MC.tab[current_tab].data, function (uid, item)
// 					{
// 						if (item.placement == 'zone' && item.zone == target_id)
// 						{
// 							MC.canvas.move(uid, item['coordinate'][0] + zone_offsetX, item['coordinate'][1] + zone_offsetY, false);
// 						}
// 					});

// 					MC.canvas.move(target_id, target_zoneX, target_zoneY);
// 				}
// 				else
// 				{
// 					target.css({
// 						'left': event.data.originalX,
// 						'top': event.data.originalY
// 					});
// 				}
// 			}
// 			if (node_class == 'node')
// 			{
// 				target_zoneX = Math.ceil((event.pageX - canvas_offset.left) / 140) - 1;
// 				target_zoneY = Math.ceil((event.pageY - canvas_offset.top) / 100) - 1;

// 				if (placement == 'zone')
// 				{
// 					$.each(MC.tab[current_tab].data, function (uid, item)
// 					{
// 						if (item.class == 'zone')
// 						{
// 							if (
// 								(target_zoneX >= item.coordinate[0] && target_zoneX < item.coordinate[0] + item.size[0]) &&
// 								(target_zoneY >= item.coordinate[1] && target_zoneY < item.coordinate[1] + item.size[1])
// 							)
// 							{
// 								is_drop_place_match = true;
// 								MC.tab[current_tab].data[target_id]['zone'] = uid;
// 								MC.canvas.drop(target_id, target_zoneX, target_zoneY);
// 							}
// 						}
// 					});
// 				}
// 				if (placement == 'canvas')
// 				{
// 					$.each(MC.tab[current_tab].data, function (uid, item)
// 					{
// 						if (item.class == 'zone')
// 						{
// 							if (
// 								(target_zoneX < item.coordinate[0] || target_zoneX > item.coordinate[0] + item.size[0]) ||
// 								(target_zoneY < item.coordinate[1] || target_zoneY > item.coordinate[1] + item.size[1])
// 							)
// 							{
// 								is_drop_place_match = true;
// 								MC.canvas.drop(target_id, target_zoneX, target_zoneY);
// 							}
// 						}
// 					});
// 				}

// 				if (!is_drop_place_match)
// 				{
// 					target.css({
// 						'left': event.data.originalX,
// 						'top': event.data.originalY
// 					});
// 				}
// 			}

// 			$(document).off({
// 				'mousemove': MC.drag.canvas.mousemove,
// 				'mouseup': MC.drag.canvas.mouseup
// 			});

// 			$('#node_container').css('zIndex', '1');
// 		}
// 	},
// 	component: {
// 		mousedown: function (event)
// 		{
// 			event.preventDefault();
// 			event.stopPropagation();

// 			var target = $(event.target),
// 				target_offset = target.offset();

// 			$(document.body).append('<div id="component_drag_shadow"></div>');
// 			$(document).on({
// 				'mousemove': MC.drag.component.mousemove,
// 				'mouseup': MC.drag.component.mouseup
// 			}, {
// 				'target': target
// 			});

// 			$('#component_drag_shadow').css('backgroundImage', target.css('backgroundImage'));
// 		},
// 		mousemove: function (event)
// 		{
// 			event.preventDefault();
// 			event.stopPropagation();

// 			$('#component_drag_shadow').css({
// 				'top': event.pageY - 40,
// 				'left': event.pageX - 40
// 			});

// 			return false;
// 		},
// 		mouseup: function (event)
// 		{
// 			var canvas_offset = $('#svg_canvas').offset(),
// 				mouseX = event.pageX - canvas_offset.left,
// 				mouseY = event.pageY - canvas_offset.top,
// 				target_zoneX = Math.ceil(mouseX / 140) - 1,
// 				target_zoneY = Math.ceil(mouseY / 100) - 1,
// 				option = event.data.target.data('option'),
// 				is_drop_place_match,
// 				match_zone,
// 				new_uid;

// 			if (mouseX > 0 && mouseY > 0)
// 			{
// 				if (option.placement == 'zone')
// 				{
// 					$.each(MC.tab[current_tab].data, function (uid, item)
// 					{
// 						if (item.class == 'zone')
// 						{
// 							if (
// 								(target_zoneX >= item.coordinate[0] && target_zoneX < item.coordinate[0] + item.size[0]) &&
// 								(target_zoneY >= item.coordinate[1] && target_zoneY < item.coordinate[1] + item.size[1])
// 							)
// 							{
// 								is_drop_place_match = true;
// 								match_zone = uid;
// 							}
// 						}
// 					});
// 					if (is_drop_place_match)
// 					{
// 						new_uid = MC.canvas.add(option, mouseX, mouseY);
// 						MC.tab[current_tab].data[new_uid]['zone'] = match_zone;
// 					}
// 				}
// 				if (option.placement == 'canvas')
// 				{
// 					is_drop_place_match = true;
// 					$.each(MC.tab[current_tab].data, function (uid, item)
// 					{
// 						if (item.class == 'zone')
// 						{
// 							if (
// 								(target_zoneX >= item.coordinate[0] && target_zoneX <= item.coordinate[0] + item.size[0] - 1) &&
// 								(target_zoneY >= item.coordinate[1] && target_zoneY <= item.coordinate[1] + item.size[1] - 1)
// 							)
// 							{
// 								is_drop_place_match = false;
// 							}
// 						}
// 					});

// 					if (is_drop_place_match)
// 					{
// 						MC.canvas.add(option, mouseX, mouseY);
// 					}
// 				}
// 				if (option.placement == 'node')
// 				{
// 					$.each(MC.tab[current_tab].data, function (uid, item)
// 					{
// 						if (item.class == 'node' && item.type == 'instance')
// 						{
// 							if (
// 								target_zoneX == item.coordinate[0] &&
// 								target_zoneY == item.coordinate[1] &&
// 								item.attachment.indexOf(option.type) == -1
// 							)
// 							{
// 								$('#' + uid).addClass('attached_' + option.type);
// 								MC.tab[current_tab].data[uid]['attachment'].push(option.type);
// 							}
// 						}
// 					});
// 				}
// 			}

// 			$(document).off({
// 				'mousemove': MC.drag.component.mousemove,
// 				'mouseup': MC.drag.component.mouseup
// 			});
// 			$('#component_drag_shadow').remove();
// 		}
// 	},
// 	resize: {
// 		mousedown: function (event)
// 		{
// 			event.preventDefault();
// 			event.stopPropagation();

// 			var target = event.target,
// 				zone = $(target.parentNode),
// 				zone_offset = $(zone).offset(),
// 				direction = $(target).data('direction');

// 			$(document).on({
// 				'mousemove': MC.drag.resize.mousemove,
// 				'mouseup': MC.drag.resize.mouseup
// 			}, {
// 				'resizer': target,
// 				'target': target.parentNode,
// 				'originalX': zone_offset.left,
// 				'originalY': zone_offset.top,
// 				'originalWidth': zone.width(),
// 				'originalHeight': zone.height(),
// 				'originalTop': zone.position().top,
// 				'originalLeft': zone.position().left,
// 				'direction': direction
// 			});
// 		},
// 		mousemove: function (event)
// 		{
// 			var target = event.data.target,
// 				direction = event.data.direction,
// 				zone_border = 4 * 2,
// 				left = event.data.originalLeft + event.pageX - event.data.originalX,
// 				max_left = event.data.originalLeft + event.data.originalWidth,
// 				top = event.data.originalTop + event.pageY - event.data.originalY,
// 				max_top = event.data.originalTop + event.data.originalHeight;

// 			switch (direction)
// 			{
// 				case 'topleft':
// 					$(target).css({
// 						'top': top > max_top ? max_top : top,
// 						'left': left > max_left ? max_left : left,
// 						'width': event.data.originalWidth - event.pageX + event.data.originalX + zone_border,
// 						'height': event.data.originalHeight - event.pageY + event.data.originalY + zone_border
// 					});
// 					break;

// 				case 'topright':
// 					$(target).css({
// 						'top': top > max_top ? max_top : top,
// 						'width': event.pageX - event.data.originalX,
// 						'height': event.data.originalHeight - event.pageY + event.data.originalY + zone_border
// 					});
// 					break;

// 				case 'bottomleft':
// 					$(target).css({
// 						'left': left > max_left ? max_left : left,
// 						'width': event.data.originalWidth - event.pageX + event.data.originalX + zone_border,
// 						'height': event.pageY - event.data.originalY
// 					});
// 					break;

// 				case 'bottomright':
// 					$(target).css({
// 						'width': event.pageX - event.data.originalX,
// 						'height': event.pageY - event.data.originalY
// 					});
// 					break;

// 				case 'top':
// 					$(target).css({
// 						'top': top > max_top ? max_top : top,
// 						'height': event.data.originalHeight - event.pageY + event.data.originalY + zone_border
// 					});
// 					break;

// 				case 'right':
// 					$(target).css({
// 						'width': event.pageX - event.data.originalX
// 					});
// 					break;

// 				case 'bottom':
// 					$(target).css({
// 						'height': event.pageY - event.data.originalY
// 					});
// 					break;

// 				case 'left':
// 					$(target).css({
// 						'left': left > max_left ? max_left : left,
// 						'width': event.data.originalWidth - event.pageX + event.data.originalX + zone_border
// 					});
// 					break;
// 			}
// 		},
// 		mouseup: function (event)
// 		{
// 			var target = event.data.target,
// 				canvas_offset = $('#svg_canvas').offset(),
// 				direction = event.data.direction,
// 				zone_id = target.id,
// 				zone_data = MC.tab[current_tab].data[zone_id],
// 				left = event.pageX - canvas_offset.left,
// 				top = event.pageY - canvas_offset.top,
// 				mouseX,
// 				mouseY,
// 				max_left,
// 				max_top,
// 				zone_width,
// 				zone_height,
// 				zone_top,
// 				zone_left,
// 				zone_minX,
// 				zone_minY,
// 				zone_maxX,
// 				zone_maxY,
// 				zone_available_X = [],
// 				zone_available_Y = [];

// 			zone_top = event.data.originalTop;
// 			zone_left = event.data.originalLeft;

// 			switch (direction)
// 			{
// 				case 'topleft':
// 					zone_top = top < event.data.originalTop + event.data.originalHeight - 240 ? top : event.data.originalTop + event.data.originalHeight - 100;
// 					zone_left = left < event.data.originalLeft + event.data.originalWidth - 320 ? left : event.data.originalLeft;

// 					mouseX = event.data.originalX + event.data.originalWidth - event.pageX;
// 					mouseY = event.data.originalY + event.data.originalHeight - event.pageY;

// 					if (mouseY < 240)
// 					{
// 						zone_top = event.data.originalTop + event.data.originalHeight - 200;
// 						mouseY = 100;
// 					}

// 					if (mouseX < 320)
// 					{
// 						zone_left = event.data.originalLeft + event.data.originalWidth - 320;
// 						mouseX = 140;
// 					}
// 					break;

// 				case 'topright':

// 					zone_top = top < event.data.originalTop + event.data.originalHeight - 240 ? top : event.data.originalTop + event.data.originalHeight - 100;

// 					zone_left = event.data.originalLeft;

// 					mouseY = event.data.originalHeight - event.pageY + event.data.originalY;
// 					if (mouseY < 240)
// 					{
// 						zone_top = event.data.originalTop + event.data.originalHeight - 200;
// 						mouseY = 100;
// 					}

// 					mouseX = event.pageX - event.data.originalX;
// 					break;

// 				case 'bottomleft':

// 					zone_left = left < event.data.originalLeft + event.data.originalWidth - 320 ? left : event.data.originalLeft;
// 					zone_top = event.data.originalTop;

// 					mouseX = event.data.originalWidth - event.pageX + event.data.originalX;
// 					if (mouseX < 320)
// 					{
// 						zone_left = event.data.originalLeft + event.data.originalWidth - 320;
// 						mouseX = 140;
// 					}
// 					mouseY = event.pageY - event.data.originalY;
// 					break;

// 				case 'bottomright':
// 					mouseX = event.pageX - event.data.originalX;
// 					mouseY = event.pageY - event.data.originalY;
// 					break;

// 				case 'top':
// 					zone_top = top < event.data.originalTop + event.data.originalHeight - 240 ? top : event.data.originalTop + event.data.originalHeight - 100;
// 					mouseY = event.data.originalY + event.data.originalHeight - event.pageY;

// 					if (mouseY < 240)
// 					{
// 						zone_top = event.data.originalTop + event.data.originalHeight - 200;
// 						mouseY = 100;
// 					}
// 					//mouseX = event.data.originalWidth + event.data.originalLeft - 140;
// 					break;

// 				case 'right':
// 					zone_left = event.data.originalLeft;
// 					//mouseY = event.data.originalHeight + event.data.originalTop - 100;
// 					mouseX = event.pageX - event.data.originalX;
// 					break;

// 				case 'bottom':
// 					zone_top = event.data.originalTop;
// 					mouseY = event.pageY - event.data.originalY;
// 					//mouseX = event.data.originalWidth + event.data.originalLeft - 140;
// 					break;

// 				case 'left':
// 					zone_left = left < event.data.originalLeft + event.data.originalWidth - 320 ? left : event.data.originalLeft;
// 					mouseX = event.data.originalWidth - event.pageX + event.data.originalX;

// 					if (mouseX < 320)
// 					{
// 						zone_left = event.data.originalLeft + event.data.originalWidth - 320;
// 						mouseX = 140;
// 					}
// 					//mouseY = event.data.originalHeight + event.data.originalTop - 100;
// 					break;
// 			}

// 			$.each(MC.tab[current_tab].data, function (i, item)
// 			{
// 				if (item.zone && item.zone == zone_id)
// 				{
// 					zone_available_X.push(item.coordinate[0]);
// 					zone_available_Y.push(item.coordinate[1]);
// 				}
// 			});

// 			zone_left = Math.ceil(zone_left / 140);
// 			zone_top = Math.ceil(zone_top / 100);
// 			zone_width = Math.ceil(mouseX / 140);
// 			zone_height = Math.ceil(mouseY / 100);
// 			zone_maxX = Math.max.apply(Math, zone_available_X);
// 			zone_maxY = Math.max.apply(Math, zone_available_Y);
// 			zone_minX = Math.min.apply(Math, zone_available_X);
// 			zone_minY = Math.min.apply(Math, zone_available_Y);

// 			zone_width = zone_width < 2 ? 2 : zone_width;
// 			zone_height = zone_height < 2 ? 2 : zone_height;

// 			switch (direction)
// 			{
// 				case 'topleft':
// 					if (zone_left > zone_minX)
// 					{
// 						zone_left = zone_minX;
// 						zone_width = zone_maxX - zone_minX + 2;
// 					}

// 					if (zone_top > zone_minY)
// 					{
// 						zone_top = zone_minY;
// 						zone_height = zone_maxY - zone_minY + 2;
// 					}
// 					break;

// 				case 'topright':
// 					zone_width = zone_width + MC.tab[current_tab].data[zone_id]['coordinate'][0] - 1 > zone_maxX ? zone_width : zone_maxX - MC.tab[current_tab].data[zone_id]['coordinate'][0] + 2;

// 					if (zone_top > zone_minY)
// 					{
// 						zone_top = zone_minY;
// 						zone_height = zone_maxY - zone_minY + 2;
// 					}
// 					break;

// 				case 'bottomleft':
// 					if (zone_left > zone_minX)
// 					{
// 						zone_left = zone_minX;
// 						zone_width = zone_maxX - zone_minX + 2;
// 					}

// 					zone_height = zone_height + MC.tab[current_tab].data[zone_id]['coordinate'][1] - 1 > zone_maxY ? zone_height : zone_maxY - MC.tab[current_tab].data[zone_id]['coordinate'][1] + 2;
// 					break;

// 				case 'bottomright':
// 					zone_width = zone_width + MC.tab[current_tab].data[zone_id]['coordinate'][0] - 1 > zone_maxX ? zone_width : zone_maxX - MC.tab[current_tab].data[zone_id]['coordinate'][0] + 2;
// 					zone_height = zone_height + MC.tab[current_tab].data[zone_id]['coordinate'][1] - 1 > zone_maxY ? zone_height : zone_maxY - MC.tab[current_tab].data[zone_id]['coordinate'][1] + 2;
// 					break;

// 				case 'top':
// 					if (zone_top > zone_minY)
// 					{
// 						zone_top = zone_minY;
// 						zone_height = zone_maxY - zone_minY + 2;
// 					}
// 					break;

// 				case 'right':
// 					zone_width = zone_width + MC.tab[current_tab].data[zone_id]['coordinate'][0] - 1 > zone_maxX ? zone_width : zone_maxX - MC.tab[current_tab].data[zone_id]['coordinate'][0] + 2;
// 					break;

// 				case 'bottom':
// 					zone_height = zone_height + MC.tab[current_tab].data[zone_id]['coordinate'][1] - 1 > zone_maxY ? zone_height : zone_maxY - MC.tab[current_tab].data[zone_id]['coordinate'][1] + 2;
// 					break;

// 				case 'left':
// 					if (zone_left > zone_minX)
// 					{
// 						zone_left = zone_minX;
// 						zone_width = zone_maxX - zone_minX + 2;
// 					}
// 					break;
// 			}

// 			$(target).css({
// 				'top': zone_top * 100 - 40,
// 				'left': zone_left * 140 - 50,
// 				'width': (zone_width - 1) * 140 + 100,
// 				'height': (zone_height - 1) * 100 + 80
// 			});

// 			zone_width = isNaN(zone_width) ? zone_data['size'][0] + 1 : zone_width;
// 			zone_height = isNaN(zone_height) ? zone_data['size'][1] + 1 : zone_height;

// 			zone_data['coordinate'] = [zone_left, zone_top];
// 			zone_data['size'] = [zone_width - 1, zone_height - 1];

// 			$(document).off({
// 				'mousemove': MC.drag.resize.mousemove,
// 				'mouseup': MC.drag.resize.mouseup
// 			});
// 		}
// 	}
// };

// MC.KeyRemoveNode = function (event)
// {
// 	if (event.which == 46 && MC.canvas.focused_node.length > 0)
// 	{
// 		$.each(MC.canvas.focused_node, function (i, uid)
// 		{
// 			var focused_node = $('#' + uid),
// 				zone_id;

// 			if (focused_node.hasClass('zone'))
// 			{
// 				zone_id = focused_node.attr('id');
// 				$.each(MC.tab[current_tab].data, function (uid, item)
// 				{
// 					if (item.zone == zone_id)
// 					{
// 						MC.canvas.remove($('#' + uid));
// 					}
// 				});
// 				focused_node.remove();
// 				delete MC.tab[current_tab].data[zone_id];
// 			}
// 			else
// 			{
// 				MC.canvas.remove(focused_node);
// 			}
// 		});
// 		MC.canvas.focused_node = [];
// 	}
// };