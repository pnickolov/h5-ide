// MC.Canvas
// Author: Angel

//json data for current tab
MC.canvas_data = {};

//variable for current tab
MC.canvas_property = {
	// sg_list: [],
	// kp_list: [],
	// SCALE_RATIO: 1
};

MC.canvas = {

	selected_node: [],

	zoomIn: function ()
	{
		var canvas_size = MC.canvas.data.get('layout.size');

		if (MC.canvas_property.SCALE_RATIO > 1)
		{
			MC.canvas_property.SCALE_RATIO = (MC.canvas_property.SCALE_RATIO * 10 - 2) / 10;

			$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] * MC.canvas_property.SCALE_RATIO + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1] * MC.canvas_property.SCALE_RATIO);

			$('#canvas_body').css('background-image', 'url("../assets/images/ide/grid_x' + MC.canvas_property.SCALE_RATIO + '.png")');
		}
	},

	zoomOut: function ()
	{
		var canvas_size = MC.canvas.data.get('layout.size');

		if (MC.canvas_property.SCALE_RATIO < 1.6)
		{
			MC.canvas_property.SCALE_RATIO = (MC.canvas_property.SCALE_RATIO * 10 + 2) / 10;

			$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] * MC.canvas_property.SCALE_RATIO + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1] * MC.canvas_property.SCALE_RATIO);

			$('#canvas_body').css('background-image', 'url("../assets/images/ide/grid_x' + MC.canvas_property.SCALE_RATIO + '.png")');
		}
	},

	screenshotInit: function ()
	{
		var layout_node_data = MC.canvas.data.get('layout.component.node'),
			layout_group_data = MC.canvas.data.get('layout.component.group'),
			node_minX = [],
			node_minY = [],
			node_maxX = [],
			node_maxY = [],
			node_data,
			group_node_data,
			screen_maxX,
			screen_maxY,
			group_minX,
			group_minY;

		$.each(layout_node_data, function (index, data)
		{
			node_maxX.push(data.coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID);
			node_maxY.push(data.coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID);
		});

		$.each(layout_group_data, function (index, data)
		{
			node_maxX.push(data.coordinate[0] + data.size[0]);
			node_maxY.push(data.coordinate[1] + data.size[1]);
		});

		screen_maxX = Math.max.apply(Math, node_maxX) * MC.canvas.GRID_WIDTH;
		screen_maxY = Math.max.apply(Math, node_maxY) * MC.canvas.GRID_HEIGHT;

		$('#svg_canvas, #screenshot_canvas_body').css({
			'width': screen_maxX,
			'height': screen_maxY
		});
	},

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
		if (prev.x === current.x)
		{
			//1.1 calc p1
			delta = current.y - prev.y;
			if (Math.abs(delta) <= closestRange )
			{
				//use middle point between prev and current
				p1 = { 'x': current.x, 'y': (prev.y + current.y) / 2};
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p1 = { 'x': current.x, 'y': current.y - cornerRadius * sign};
			}

			//1.2 calc p2
			delta = current.x - next.x;
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between current and next
				p2 = { 'x': (current.x + next.x) / 2, 'y': current.y};
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p2 = { 'x': current.x - cornerRadius * sign, 'y': current.y};
			}
		}
		else
		{
			/*2.left or right*/
			//2.1 calc p1
			delta = current.x - prev.x;
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between prev and current
				p1 = { 'x': (prev.x + current.x) / 2, 'y': current.y};
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p1 = { 'x': current.x - cornerRadius * sign, 'y': current.y};
			}

			//2.2 calc p2
			delta = current.y - next.y;
			if (Math.abs(delta) <= closestRange)
			{
				//use middle point between current and next
				p2 = { 'x': current.x, 'y': (current.y + next.y) / 2};
			}
			else
			{
				sign = delta ? (delta < 0 ? -1 : 1) : 0;
				p2 = { 'x': current.x, 'y': current.y - cornerRadius * sign};
			}
		}

		return ' L ' + p1.x + ' ' + p1.y + ' Q ' + current.x + ' ' + current.y + ' ' + p2.x + ' ' + p2.y;
	},

	_round_corner: function (controlPoints)
	{
		//add by xjimmy, draw round corner of fold line

		var last_p = {},
			prev_p = {},
			next_p = {};

		$.each(controlPoints, function (idx, value)
		{
			if (idx === 0)
			{
				//start0 point
				d = 'M ' + value.x + " " + value.y;
			}
			else if (idx === (controlPoints.length - 1))
			{
				//end0 point
				d += ' L ' + value.x + ' ' + value.y;
			}
			else
			{
				//middle point
				prev_p = controlPoints[idx - 1]; //prev point
				next_p = controlPoints[idx + 1]; //next point

				if (
					(prev_p.x === value.x && next_p.x === value.x) ||
					(prev_p.y === value.y && next_p.y === value.y)
				)
				{
					//three point one line
					d += ' L ' + value.x + ' ' + value.y;
				}
				else
				{
					//fold line
					d += MC.canvas._getPath(prev_p, value, next_p);
				}
			}
			last_p = value;
		});

		return d;
	},

	_route: function(controlPoints, fromPt, fromDir, toPt, toDir)
	{
		//add by xjimmy, connection algorithm (from ManhattanConnectionRouter of draw2d)

		var xDiff = fromPt.x - toPt.x;
		var yDiff = fromPt.y - toPt.y;
		var point;
		var dir;
		var pos;

		if(((xDiff * xDiff) < (this.TOLxTOL)) && ((yDiff * yDiff) < (this.TOLxTOL))) {
			controlPoints.push({ 'x': toPt.x, 'y': toPt.y });
			return;
		}
		if(fromDir === this.PORT_LEFT_ANGLE) {
			if((xDiff > 0) && ((yDiff * yDiff) < this.TOL) && (toDir === this.PORT_RIGHT_ANGLE)) {
				point = toPt;
				dir = toDir;
			} else {
				if(xDiff < 0) {
					point = { 'x': fromPt.x - this.MINDIST, 'y': fromPt.y };
				} else {
					if(((yDiff > 0) && (toDir === this.PORT_DOWN_ANGLE)) || ((yDiff < 0) && (toDir === this.PORT_UP_ANGLE))) {
						point = { 'x': toPt.x, 'y': fromPt.y };
					} else {
						if(fromDir == toDir) {
							pos = Math.min(fromPt.x, toPt.x) - this.MINDIST;
							point = { 'x': pos, 'y': fromPt.y };
						} else {
							point = { 'x': fromPt.x - (xDiff / 2), 'y': fromPt.y };
						}
					}
				}
				if(yDiff > 0) {
					dir = this.PORT_UP_ANGLE;
				} else {
					dir = this.PORT_DOWN_ANGLE;
				}
			}
		} else {
			if(fromDir === this.PORT_RIGHT_ANGLE) {
				if((xDiff < 0) && ((yDiff * yDiff) < this.TOL) && (toDir === this.PORT_LEFT_ANGLE)) {
					point = toPt;
					dir = toDir;
				} else {
					if(xDiff > 0) {
						point = { 'x': fromPt.x + this.MINDIST, 'y': fromPt.y };
					} else {
						if(((yDiff > 0) && (toDir === this.PORT_DOWN_ANGLE)) || ((yDiff < 0) && (toDir === this.PORT_UP_ANGLE))) {
							point = { 'x': toPt.x, 'y': fromPt.y };
						} else {
							if(fromDir === toDir) {
								pos = Math.max(fromPt.x, toPt.x) + this.MINDIST;
								point = { 'x': pos, 'y': fromPt.y };
							} else {
								point = { 'x': fromPt.x - (xDiff / 2), 'y': fromPt.y };
							}
						}
					}
					if(yDiff > 0) {
						dir = this.PORT_UP_ANGLE;
					} else {
						dir = this.PORT_DOWN_ANGLE;
					}
				}
			} else {
				if(fromDir === this.PORT_DOWN_ANGLE) {
					if(((xDiff * xDiff) < this.TOL) && (yDiff < 0) && (toDir === this.PORT_UP_ANGLE)) {
						point = toPt;
						dir = toDir;
					} else {
						if(yDiff > 0) {
							point = { 'x': fromPt.x, 'y': fromPt.y + this.MINDIST };
						} else {
							if(((xDiff > 0) && (toDir === this.PORT_RIGHT_ANGLE)) || ((xDiff < 0) && (toDir === this.PORT_LEFT_ANGLE))) {
								point = { 'x': fromPt.x, 'y': toPt.y };
							} else {
								if(fromDir === toDir) {
									pos = Math.max(fromPt.y, toPt.y) + this.MINDIST;
									point = { 'x': fromPt.x, 'y': pos };
								} else {
									point = { 'x': fromPt.x, 'y': fromPt.y - (yDiff / 2) };
								}
							}
						}
						if(xDiff > 0) {
							dir = this.PORT_LEFT_ANGLE;
						} else {
							dir = this.PORT_RIGHT_ANGLE;
						}
					}
				} else {
					if(fromDir === this.PORT_UP_ANGLE) {
						if(((xDiff * xDiff) < this.TOL) && (yDiff > 0) && (toDir === this.PORT_DOWN_ANGLE)) {
							point = toPt;
							dir = toDir;
						} else {
							if(yDiff < 0) {
								point = { 'x': fromPt.x, 'y': fromPt.y - this.MINDIST };
							} else {
								if(((xDiff > 0) && (toDir === this.PORT_RIGHT_ANGLE)) || ((xDiff < 0) && (toDir === this.PORT_LEFT_ANGLE))) {
									point = { 'x': fromPt.x, 'y': toPt.y };
								} else {
									if(fromDir === toDir) {
										pos = Math.min(fromPt.y, toPt.y) - this.MINDIST;
										point = { 'x': fromPt.x, 'y': pos };
									} else {
										point = { 'x': fromPt.x, 'y': fromPt.y - (yDiff / 2) };
									}
								}
							}
							if(xDiff > 0) {
								dir = this.PORT_LEFT_ANGLE;
							} else {
								dir = this.PORT_RIGHT_ANGLE;
							}
						}
					}
				}
			}
		}
		this._route(controlPoints, point, dir, toPt, toDir);
		controlPoints.push(fromPt);
	},

	_route2: function (controlPoints, start0, end0)
	{
		//add by xjimmy, connection algorithm (xjimmy's algorithm)

		var start = {},
			end = {},
			//start.x>=end.x
			start_0_90 = end_0_90 = start_180_270 = end_180_270 = false,
			//start.x<end.x
			start_0_270 = end_0_270 = start_90_180 = end_90_180 = false;

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
		controlPoints.push( { 'x': start0.x, 'y': start0.y });
		controlPoints.push( { 'x': start.x, 'y': start.y });

		//2.control point
		if (
			(start_0_90 && end_0_90) ||
			(start_90_180 && end_90_180)
		)
		{
			//A
			controlPoints.push( { 'x': start.x, 'y': end.y });
		}
		else if (
			(start_180_270 && end_180_270) ||
			(start_0_270 && end_0_270)
		)
		{
			//B
			controlPoints.push( { 'x': end.x, 'y': start.y });
		}
		else if (
			(start_0_90 && end_180_270) ||
			(start_90_180 && end_0_270)
		)
		{
			//C
			controlPoints.push( { 'x': start.x, 'y': (start.y + end.y) / 2 });
			controlPoints.push( { 'x': end.x, 'y': (start.y + end.y) / 2 });
		}
		else if (
			(start_180_270 && end_0_90) ||
			(start_0_270 && end_90_180)
		)
		{
			//D
			controlPoints.push( { 'x': (start.x + end.x) / 2, 'y': start.y });
			controlPoints.push( { 'x': (start.x + end.x) / 2, 'y': end.y });
		}

		//3.end point
		controlPoints.push( { 'x': end.x, 'y': end.y });
		controlPoints.push( { 'x': end0.x, 'y': end0.y });

		return controlPoints;

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

				startX = (from_port_offset.left - canvas_offset.left + (from_port_offset.width / 2)) * MC.canvas_property.SCALE_RATIO;
				startY = (from_port_offset.top - canvas_offset.top + (from_port_offset.height / 2)) * MC.canvas_property.SCALE_RATIO;
				endX = (to_port_offset.left - canvas_offset.left + (to_port_offset.width / 2)) * MC.canvas_property.SCALE_RATIO;
				endY = (to_port_offset.top - canvas_offset.top + (to_port_offset.height / 2)) * MC.canvas_property.SCALE_RATIO;

				//add by xjimmy
				var controlPoints = [],
					start0 = {
						x : startX,
						y : startY,
						connectionAngle: from_port.data('angle')
					},
					end0 = {
						x: endX,
						y: endY,
						connectionAngle: to_port.data('angle')
					};

				//add pad to start0 and end0
				MC.canvas._addPad(start0, 1);
				MC.canvas._addPad(end0, 1);


				//draw rectangle for vertical / horizontal line
				// if ( start0.x === end0.x )
				// {
				// 	//draw vertical line
				// 	MC.paper.start({
				// 		'filter': 'url(#dropshadow)',
				// 		'stroke': 'none',
				// 		'stroke-width': 0,
				// 		'fill': connection_option.color
				// 	});

				// 	var top_p = start0;
				// 	var bottom_p = end0;
				// 	if ( start0.y > end0.y )
				// 	{
				// 		top_p = end0;
				// 		bottom_p = start0;
				// 	}
				// 	MC.paper.rectangle(top_p.x, top_p.y, MC.canvas.LINE_STROKE_WIDTH , bottom_p.y - top_p.y );
				// }
				// else if ( start0.y === end0.y )
				// {
				// 	//draw horizontal line
				// 	MC.paper.start({
				// 		'filter': 'url(#dropshadow)',
				// 		'stroke': 'none',
				// 		'stroke-width': 0,
				// 		'fill': connection_option.color
				// 	});

				// 	var left_p = start0;
				// 	var right_p = end0;
				// 	if ( start0.y > end0.y )
				// 	{
				// 		left_p = end0;
				// 		right_p = start0;
				// 	}
				// 	MC.paper.rectangle(left_p.x, left_p.y-2, right_p.x - left_p.x, MC.canvas.LINE_STROKE_WIDTH);
				// }



				if ( start0.x === end0.x || start0.y === end0.y )
				{
					//draw straight line
					MC.paper.start({
						'stroke': connection_option.color,
						'stroke-width': MC.canvas.LINE_STROKE_WIDTH,
						'fill': 'none'
					});

					MC.paper.line(start0.x, start0.y, end0.x, end0.y);
				}
				else
				{
					//draw fold line
					MC.paper.start({
						'stroke': connection_option.color,
						'stroke-width': MC.canvas.LINE_STROKE_WIDTH,
						'fill': 'none'
					});

					///// route 1 (xjimmy's algorithm)/////
					//MC.canvas._route2( controlPoints, start0, end0 );

					///// route 2 (ManhattanConnectionRouter, draw2d's algorithm) /////
					MC.canvas._route( controlPoints, start0, from_port.data('angle'), end0, to_port.data('angle') );

					///// draw fold line /////
					if (controlPoints.length>0)
					{
						////// draw polyline /////
						//MC.paper.polyline(controlPoints);

						/////draw round corner line /////
						var d = MC.canvas._round_corner( controlPoints );
						if (d !== "")
						{
							MC.paper.path(d);
						}
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

		var target = $(node);

		MC.canvas.data.set('layout.component.' + target.data('type') + '.' + node.id + '.coordinate', [x, y]);
		target.attr('transform', 'translate(' + (x * MC.canvas.GRID_WIDTH) + ',' + (y * MC.canvas.GRID_HEIGHT) + ')');
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

				line_layer.removeChild(document.getElementById( value.line ));

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

		if (node_type === 'group')
		{
			var group_child = MC.canvas.groupChild(node);

			$.each(group_child, function (index, item)
			{
				MC.canvas.remove(item);
			});

			MC.canvas.data.delete('layout.component.group.' + node_id);
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
		var children = MC.canvas.data.get('layout.component.node'),
			coordinate = MC.canvas.pixelToGrid(x, y),
			matched,
			node_coordinate;

		$.each(children, function (key, item)
		{
			node_coordinate = item.coordinate;

			if (
				node_coordinate &&
				node_coordinate[0] < coordinate.x &&
				node_coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID > coordinate.x &&
				node_coordinate[1] < coordinate.y &&
				node_coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID > coordinate.y
			)
			{
				matched = document.getElementById( key );

				return false;
			}
		});

		return matched;
	},

	isMatchPlace: function (target_id, node_type, x, y, width, height)
	{
		var layout_group_data = MC.canvas.data.get('layout.component.group'),
			platform = MC.canvas.data.get('platform'),
			group_stack = [
				$('#subnet_layer').children(),
				$('#az_layer').children(),
				$('#vpc_layer').children()
			],
			is_option_canvas = ($.inArray('Canvas', MC.canvas.MATCH_PLACEMENT[ platform ][ node_type ]) > -1),
			result = {},
			group_data,
			coordinate,
			size;

		x = x * MC.canvas_property.SCALE_RATIO;
		y = y * MC.canvas_property.SCALE_RATIO;

		if (is_option_canvas)
		{
			$.each(group_stack, function (index, layer_data)
			{
				if (layer_data)
				{
					$.each(layer_data, function (i, item)
					{
						group_data = layout_group_data[ item.id ];
						coordinate = group_data.coordinate;
						size = group_data.size;

						if (
							target_id !== item.id &&
							(
								(x >= coordinate[0] &&
								x <= coordinate[0] + size[0])
								||
								(x + width >= coordinate[0] &&
								x + width <= coordinate[0] + size[0])
							)
							&&
							(
								(y >= coordinate[1] &&
								y <= coordinate[1] + size[1])
								||
								(y + height >= coordinate[1] &&
								y + height <= coordinate[1] + size[1])
							)
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
		}
		else
		{
			$.each(group_stack, function (index, layer_data)
			{
				if (layer_data)
				{
					$.each(layer_data, function (i, item)
					{
						group_data = layout_group_data[ item.id ];
						coordinate = group_data.coordinate;
						size = group_data.size;

						if (
							target_id !== item.id &&
							x >= coordinate[0] &&
							x + width <= coordinate[0] + size[0] &&
							y >= coordinate[1] &&
							y + height <= coordinate[1] + size[1]
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
		}

		matchGroup = result.type;

		matchGroup = matchGroup === undefined ? 'Canvas' : matchGroup;

		platform = platform === 'custome-vpc' ? 'ec2-vpc' : platform;

		return {
			'is_matched': ($.inArray(matchGroup, MC.canvas.MATCH_PLACEMENT[ platform ][ node_type ]) > -1 || target_id === matchGroup.id),
			'target': result.id
		};
	},

	isBlank: function (type, target_id, x, y)
	{
		var children = MC.canvas.data.get('layout.component.' + type),
			start_x = x * MC.canvas_property.SCALE_RATIO,
			start_y = y * MC.canvas_property.SCALE_RATIO,
			end_x = x + MC.canvas.COMPONENT_WIDTH_GRID * MC.canvas_property.SCALE_RATIO,
			end_y = y + MC.canvas.COMPONENT_HEIGHT_GRID * MC.canvas_property.SCALE_RATIO,
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

	parentGroup: function (node_id, node_type, start_x, start_y, end_x, end_y)
	{
		var groups = MC.canvas.data.get('layout.component.group'),
			group_parent_type = MC.canvas.GROUP_PARENT[ node_type ],
			matched;

		$.each(groups, function (key, item)
		{
			coordinate = item.coordinate;
			size = item.size;

			if (
				node_id !== key &&
				item.type === group_parent_type &&
				(
					(
						coordinate[0] > start_x ||
						coordinate[0] < end_x
					)
					&&
					(
						coordinate[1] > start_y ||
						coordinate[1] < end_y
					)
				)
			)
			{
				matched = document.getElementById( key );
			}
		});

		return matched;
	},

	areaChild: function (node_id, start_x, start_y, end_x, end_y)
	{
		var children = MC.canvas.data.get('layout.component.node'),
			groups = MC.canvas.data.get('layout.component.group'),
			matched = [],
			coordinate,
			size;

		$.each(children, function (key, item)
		{
			coordinate = item.coordinate;

			if (
				node_id !== key &&
				(
					(coordinate[0] > start_x &&
					coordinate[0] < end_x)
					||
					(coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID > start_x &&
					coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID < end_x)
				)
				&&
				(
					(coordinate[1] > start_y &&
					coordinate[1] < end_y)
					||
					(coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID > start_y &&
					coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID < end_y)
				)
			)
			{
				matched.push(document.getElementById( key ));
			}
		});

		$.each(groups, function (key, item)
		{
			coordinate = item.coordinate;
			size = item.size;

			if (
				node_id !== key &&
				(
					(coordinate[0] > start_x &&
					coordinate[0] < end_x)
					||
					(coordinate[0] + size[0] > start_x &&
					coordinate[0] + size[0] < end_x)
				)
				&&
				(
					(coordinate[1] > start_y &&
					coordinate[1] < end_y)
					||
					(coordinate[1] + size[1] > start_y &&
					coordinate[1] + size[1] < end_y)
				)
			)
			{
				matched.push(document.getElementById( key ));
			}
		});

		return matched;
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
			coordinate,
			size;

		$.each(children, function (key, item)
		{
			coordinate = item.coordinate;

			if (
				(
					(coordinate[0] > start_x &&
					coordinate[0] < end_x)
					||
					(coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID > start_x &&
					coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID < end_x)
				)
				&&
				(
					(coordinate[1] > start_y &&
					coordinate[1] < end_y)
					||
					(coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID > start_y &&
					coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID < end_y)
				)
			)
			{
				matched.push(document.getElementById( key ));
			}
		});

		$.each(groups, function (key, item)
		{
			coordinate = item.coordinate;
			size = item.size;

			if (
				key !== group_node.id &&
				$.inArray(item.type, group_weight) > -1 &&
				(
					(coordinate[0] > start_x &&
					coordinate[0] < end_x)
					||
					(coordinate[0] + size[0] > start_x &&
					coordinate[0] + size[0] < end_x)
				)
				&&
				(
					(coordinate[1] > start_y &&
					coordinate[1] < end_y)
					||
					(coordinate[1] + size[1] > start_y &&
					coordinate[1] + size[1] < end_y)
				)
			)
			{
				matched.push(document.getElementById( key ));
			}
		});

		return matched;
	}
};

MC.canvas.layout = {
	init: function ()
	{
		var layout_data = MC.canvas.data.get("layout"),
			connection_target_id;

		//temp
		MC.canvas_property = $.extend(true, {}, MC.canvas.STACK_PROPERTY);
	
		components = MC.canvas.data.get("component");
		
		$.each(components, function (key, value){
			if(value.type==='AWS.EC2.KeyPair'){
				tmp = {};
				tmp[value.name] = value.uid;
				MC.canvas_property.kp_list.push(tmp);
			}
			if(value.type === "AWS.EC2.SecurityGroup"){
				tmp = {};
				tmp.name = value.name;
				tmp.uid = value.uid;
				tmp.member = [];
				$.each(components, function (k, v){
					if(v.type === "AWS.EC2.Instance" ){
						sg_uids = v.resource.SecurityGroupId;
						$.each(sg_uids, function (id, sg_ref){
							if(sg_ref.split('.')[0].slice(1) === tmp.uid){
								tmp.member.push(v.uid);
							}
						})
					}
				});
				MC.canvas_property.sg_list.push(tmp);
			}
		});
		
		$.each(MC.canvas_property.sg_list, function (key, value){
			if(value.name === "DefaultSG" && key !== 0){
				tmp = value;
				MC.canvas_property.sg_list.splice(key,key);
				MC.canvas_property.sg_list.unshift(value);
				return false;
			}
		});
		
		$.each(MC.canvas_property.kp_list, function (key, value){
			if(value.DefaultKP !== undefined && key !== 0){
				tmp = value;
				MC.canvas_property.kp_list.splice(key,key);
				MC.canvas_property.kp_list.unshift(value);
				return false;
			}
		});
		
		$('#svg_canvas').attr({
			'width': layout_data.size[0] * MC.canvas.GRID_WIDTH,
			'height': layout_data.size[1] * MC.canvas.GRID_HEIGHT
		});

		$.each(layout_data.component.node, function (id, data)
		{
			MC.canvas.add(id);
		});

		$.each(layout_data.component.group, function (id, data)
		{
			MC.canvas.add(id);
		});

		$.each(layout_data.connection, function (line, data)
		{
			connection_target_id = [];

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

		return true;
	},

	create: function (option)
	{
		//clone MC.canvas.STACK_JSON to MC.canvas_data
		MC.canvas_data = $.extend(true, {}, MC.canvas.STACK_JSON);

		//clone MC.canvas.STACK_PROPERTY to MC.canvas_property
		MC.canvas_property = $.extend(true, {}, MC.canvas.STACK_PROPERTY);

		//set region and platform
		MC.canvas_data.region = option.region;
		MC.canvas_data.platform = option.platform;

		var canvas_size = MC.canvas.data.get('layout.size');

		if (option.platform === MC.canvas.PLATFORM_TYPE.CUSTOM_VPC || option.platform === MC.canvas.PLATFORM_TYPE.EC2_VPC)
		{
			//has vpc (create vpc, az, and subnet by default)
			var node_vpc = MC.canvas.add('AWS.VPC.VPC', {
				'name': 'vpc1'
			},{
				'x': 2,
				'y': 2
			});

			//var node_az = MC.canvas.add('AWS.EC2.AvailabilityZone', {
			//	'name': 'ap-northeast-1'
			//},{
			//	'x': 19,
			//	'y': 16
			//});

			//var node_subnet = MC.canvas.add('AWS.VPC.Subnet', {
			//	'name': 'subnet1'
			//},{
			//	'x': 23,
			//	'y': 20
			//});
		}


		$('#svg_canvas').attr({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT
		});

		return true;
	},

	save: function ()
	{
		return JSON.stringify( MC.canvas_data );
	}
};

MC.canvas.data = {
	get: function (key)
	{
		var context = MC.canvas_data,
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
		var context = MC.canvas_data,
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
		var context = MC.canvas_data,
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

		var target = $(this),
			target_offset = this.getBoundingClientRect(),
			node_type = target.data('type'),
			canvas_offset = $('#svg_canvas').offset(),
			shadow = target.clone();

		shadow.attr('class', shadow.attr('class') + ' shadow');
		$('#svg_canvas').append(shadow);

		if (node_type !== 'group')
		{
			//$('#canvas_body').addClass('dragging');
		}

		$(document.body).on({
			'mousemove': MC.canvas.event.dragable.mousemove,
			'mouseup': MC.canvas.event.dragable.mouseup
		}, {
			'target': target,
			'target_type': node_type,
			'shadow': $(shadow),
			'offsetX': event.pageX - target_offset.left + canvas_offset.left,
			'offsetY': event.pageY - target_offset.top + canvas_offset.top,
			'groupChild': node_type === 'group' ? MC.canvas.groupChild(this) : null,
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

		var offset = (event.data.shadow.data('type') === 'node') ? 0 : 2 * MC.canvas.GRID_HEIGHT;

		event.data.shadow.attr('transform',
			'translate(' +
				Math.round((event.pageX - event.data.offsetX) / (MC.canvas.GRID_WIDTH / MC.canvas_property.SCALE_RATIO)) * (MC.canvas.GRID_WIDTH / MC.canvas_property.SCALE_RATIO) * MC.canvas_property.SCALE_RATIO + ',' +
				(offset + Math.round((event.pageY - event.data.offsetY) / (MC.canvas.GRID_HEIGHT / MC.canvas_property.SCALE_RATIO)) * (MC.canvas.GRID_HEIGHT / MC.canvas_property.SCALE_RATIO) * MC.canvas_property.SCALE_RATIO) +
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
			event.data.target.attr('class', function (index, key)
			{
				return key + ' selected';
			});
			MC.canvas.selected_node.push(event.data.target[0]);

			uid = event.data.target.attr("id");

			//dispatch event when select node
			$("#svg_canvas").trigger("CANVAS_NODE_SELECTED", uid);
		}
		else
		{
			var target = event.data.target,
				target_id = target.attr('id'),
				target_type = event.data.target_type,
				canvas_offset = $('#svg_canvas').offset(),
				shadow_offset = event.data.shadow[0].getBoundingClientRect(),
				layout_node_data = MC.canvas.data.get('layout.component.node'),
				layout_connection_data = MC.canvas.data.get('layout.connection'),
				node_type = target.data('class'),
				line_layer = $("#line_layer")[0],
				match_place,
				coordinate;

			if (target_type === 'node')
			{
				coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top);

				match_place = MC.canvas.isMatchPlace(target_id, node_type, coordinate.x, coordinate.y, MC.canvas.COMPONENT_WIDTH_GRID, MC.canvas.COMPONENT_HEIGHT_GRID);
				if (
					coordinate.x > 0 &&
					coordinate.y > 0 &&
					//MC.canvas.isBlank("node", target_id, coordinate.x, coordinate.y) &&
					match_place.is_matched
				)
				{
					node_connections = layout_node_data[ target_id ].connection || {};

					MC.canvas.position(target[0], coordinate.x  * MC.canvas_property.SCALE_RATIO, coordinate.y * MC.canvas_property.SCALE_RATIO);

					$.each(node_connections, function (index, value)
					{
						line_connection = layout_connection_data[ value.line ];

						line_layer.removeChild(document.getElementById( value.line ));

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
					layout_group_data = MC.canvas.data.get('layout.component.group'),
					group_data = layout_group_data[ target_id ],
					group_coordinate = group_data.coordinate,
					group_size = group_data.size,
					group_offsetX = coordinate.x - group_coordinate[0],
					group_offsetY = coordinate.y - group_coordinate[1],
					match_place = MC.canvas.isMatchPlace(target_id, node_type, coordinate.x, coordinate.y, group_size[0], group_size[1]),
					areaChild = MC.canvas.areaChild(target_id, coordinate.x, coordinate.y, coordinate.x + group_size[0], coordinate.y + group_size[1]),
					child_stack = [],
					unique_stack = [],
					matched_child,
					child_data,
					child_type;

				$.each(areaChild, function (index, item)
				{
					child_stack.push(item.id);
				});

				$.each(event.data.groupChild, function (index, item)
				{
					child_stack.push(item.id);
				});

				$.each(child_stack, function (index, item)
				{
					if ($.inArray(item, unique_stack) === -1)
					{
						unique_stack.push(item);
					}
				});

				if (
					coordinate.x > 0 &&
					coordinate.y > 0 &&
					match_place.is_matched &&
					event.data.groupChild.length === unique_stack.length
				)
				{
					MC.canvas.position(event.data.target[0], coordinate.x, coordinate.y);

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

								line_layer.removeChild(document.getElementById( value.line ));

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

		$(document.body).off({
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

		$(document.body).on({
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

							target_data = layout_node_data[ item.id ];

							$.each(node_connections, function (index, data)
							{
								if (data.port === value.from)
								{
									is_connected = true;
								}
							});

							if (is_connected)
							{
								return;
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
								if (option.from === value.to)
								{
									$.each(target_data.connection, function (index, data)
									{
										if (option.relation === 'unique')
										{
											if (data.port === option.from && data.target === node_id)
											{
												is_connected = true;
											}
										}
										else
										{
											if (data.port === value.to && data.target === node_id)
											{
												is_connected = true;
											}
										}
									});
								}
							});

							if (is_connected)
							{
								return;
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
			arrowPI = Math.PI / 6,
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
		$('#svg_canvas').off('mouseover', '.node', MC.canvas.event.drawConnection.draw);

		var from_node = event.data.originalTarget,
			to_node = $(this),
			port_name = event.data.port_name,
			to_port_name = to_node.find('.connectable-port').data('name');

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
		}, 100);

		$(document.body).off({
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
			node_type = target.data('type'),
			target_component_type = target.data('component-type'),
			shadow,
			clone_node,
			default_width,
			default_height;

		$(document.body).append('<div id="drag_shadow"></div>');
		shadow = $('#drag_shadow');

		if (target_component_type === 'group')
		{
			size = MC.canvas.GROUP_DEFAULT_SIZE[ node_type ];

			shadow
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50,
					'width': size[0] * MC.canvas.GRID_WIDTH,
					'height': size[1] * MC.canvas.GRID_HEIGHT
				})
				.addClass(node_type.replace(/\./ig, '-'))
				.show();
		}
		else
		{
			clone_node = target.find('.resource-icon').clone();
			shadow.append(clone_node);

			shadow
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50
				})
				.show();
		}

		if (node_type === 'AWS.EC2.EBS.Volume')
		{
			$('.AWS-EC2-Instance').attr('class', function (index, key)
			{
				return 'attachable ' + key;
			});

			$(document.body).on({
				'mousemove': MC.canvas.event.siderbarDrag.volumeMove,
				'mouseup': MC.canvas.event.siderbarDrag.volumeUp
			}, {
				'target': target,
				'canvas_offset': $('#svg_canvas').offset(),
				'shadow': shadow
			});
		}
		else
		{
			$('#canvas_body').addClass('dragging');

			$(document.body).on({
				'mousemove': MC.canvas.event.siderbarDrag.mousemove,
				'mouseup': MC.canvas.event.siderbarDrag.mouseup
			}, {
				'target': target,
				'shadow': shadow
			});
		}

		MC.canvas.event.clearSelected();

		return false;
	},

	mousemove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		event.data.shadow.css({
			'top': event.pageY - 50,
			'left': event.pageX - 50
		});

		return false;
	},

	mouseup: function (event)
	{
		var target = $(event.data.target),
			target_id = target.attr('id') || '',
			target_component_type = target.data('component-type'),
			node_type = target.data('type'),
			canvas_offset = $('#svg_canvas').offset(),
			shadow_offset = event.data.shadow.position(),
			node_option = target.data('option'),
			coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top),
			match_place,
			default_group_width,
			default_group_height;

		if (coordinate.x > 0 && coordinate.y > 0)
		{
			if (
				target_component_type === 'node' &&
				MC.canvas.isBlank("node", '', coordinate.x, coordinate.y)
			)
			{
				match_place = MC.canvas.isMatchPlace(target_id, node_type, coordinate.x, coordinate.y, MC.canvas.COMPONENT_WIDTH_GRID, MC.canvas.COMPONENT_WIDTH_GRID);

				if (match_place.is_matched)
				{
					if($("#"+match_place.target).data().class === "AWS.VPC.Subnet"){
						node_option.subnet = "@"+match_place.target + ".resource.SubnetId";
						node_option.zone = MC.canvas_data.component[match_place.target].resource.AvailabilityZone
					}
					if($("#"+match_place.target).data().class === "AWS.EC2.AvailabilityZone"){
						node_option.zone = $("#"+match_place.target).text();
					}
					MC.canvas.add(node_type, node_option, coordinate);
				}
			}

			if (
				target_component_type === 'group' &&
				MC.canvas.isBlank("group", '', coordinate.x, coordinate.y)
			)
			{
				default_group_size = MC.canvas.GROUP_DEFAULT_SIZE[ node_type ];
				match_place = MC.canvas.isMatchPlace(target_id, node_type, coordinate.x, coordinate.y, default_group_size[0], default_group_size[1]);

				if (match_place.is_matched)
				{
					if(match_place.target && $("#"+match_place.target).data().class === "AWS.EC2.AvailabilityZone"){
						node_option.zone = $("#"+match_place.target).text()
					}
					
					MC.canvas.add(node_type, node_option, coordinate);
				}
			}
		}

		event.data.shadow.remove();
		$('#canvas_body').removeClass('dragging');

		$(document.body).off({
			'mousemove': MC.canvas.event.mousemove,
			'mouseup': MC.canvas.event.mouseup
		});
	},

	volumeMove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		event.data.shadow.css({
			'top': event.pageY - 50,
			'left': event.pageX - 50
		});

		match_node = MC.canvas.matchPoint(
			event.pageX - event.data.canvas_offset.left,
			event.pageY - event.data.canvas_offset.top
		);

		if ($(match_node).data('class') === 'AWS.EC2.Instance')
		{
			MC.canvas.volumeBubble(match_node);
		}
		else
		{
			var bubble_box = $('#volume-bubble-box');

			if (bubble_box[0])
			{
				target_id = bubble_box.data('target-id');
				bubble_box.remove();

				$('#' + target_id + '_volume_status').attr('href', '../assets/images/ide/icon/instance-volume-attached-normal.png');
			}
		}

		return false;
	},

	volumeUp: function (event)
	{
		var target = $(event.data.target),
			target_component_type = target.data('component-type'),
			node_type = target.data('type'),
			node_option = target.data('option'),
			bubble_box = $('#volume-bubble-box'),
			target_id,
			target_volume_data,
			new_volume,
			data_option;

		$('.AWS-EC2-Instance').attr('class', function (index, key)
		{
			return key.replace('attachable ', '');
		});

		if (bubble_box[0])
		{
			target_id = bubble_box.data('target-id');
			target_node = $('#' + target_id);
			target_offset = target_node[0].getBoundingClientRect();
			target_volume_data = MC.canvas.data.get('component.' + target_id + '.resource.BlockDeviceMapping');

			data_option = target.data('option');
			new_volume = MC.canvas.add('AWS.EC2.EBS.Volume', data_option, {});

			$('#instance_volume_list').append('<li><a href="#" id="' + new_volume.id +'" class="volume_item"><span class="volume_name">' + data_option.name + '</span><span class="volume_size">' + data_option.volumeSize + 'GB</span></a></li>');

			target_volume_data.push('#' + new_volume.id);

			$('#instance_volume_number, #' + target_id + '_volume_number').text(target_volume_data.length);

			MC.canvas.data.set('component.' + target_id + '.resource.BlockDeviceMapping', target_volume_data);

			MC.canvas.event.volumeSelect.call( $('#' + new_volume.id )[0] );

			bubble_box.css('top',  target_offset.top - ((bubble_box.height() - target_offset.height) / 2));
		}

		event.data.shadow.remove();

		$(document.body).off({
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

		$(document.body).on({
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
			'originalTranslate': parent.attr('transform'),
			'canvas_offset': canvas_offset,
			'offsetX': event.pageX - canvas_offset.left,
			'offsetY': event.pageY - canvas_offset.top,
			'direction': $(target).data('direction'),
			'group_border': parseInt(group.css('stroke-width'),10)
		});
	},
	mousemove: function (event)
	{
		var direction = event.data.direction,
			group_border = event.data.group_border * 2,
			left = Math.round((event.pageX - event.data.originalLeft) / 10) * 10,
			max_left = event.data.originalWidth - MC.canvas.GROUP_MIN_PADDING,
			top = Math.round((event.pageY - event.data.originalTop) / 10) * 10,
			max_top = event.data.originalHeight - MC.canvas.GROUP_MIN_PADDING,
			prop;

		switch (direction)
		{
			case 'topleft':
				prop = {
					'y': top > max_top ? max_top : top,
					'x': left > max_left ? max_left : left,
					'width': event.data.originalWidth - left,
					'height': event.data.originalHeight - top
				};
				break;

			case 'topright':
				prop = {
					'y': top > max_top ? max_top : top,
					'width': Math.round((event.data.originalWidth + event.pageX - event.data.originalX) / 10) * 10,
					'height': event.data.originalHeight - top
				};
				break;

			case 'bottomleft':
				prop = {
					'x': left > max_left ? max_left : left,
					'width': event.data.originalWidth - left,
					'height': Math.round((event.data.originalHeight + event.pageY - event.data.originalY) / 10) * 10
				};
				break;

			case 'bottomright':
				prop = {
					'width': Math.round((event.data.originalWidth + event.pageX - event.data.originalX) / 10) * 10,
					'height': Math.round((event.data.originalHeight + event.pageY - event.data.originalY) / 10) * 10
				};
				break;

			case 'top':
				prop = {
					'y': top > max_top ? max_top : top,
					'height': event.data.originalHeight - top
				};
				break;

			case 'right':
				prop = {
					'width': Math.round((event.data.originalWidth + event.pageX - event.data.originalX) / 10) * 10
				};
				break;

			case 'bottom':
				prop = {
					'height': Math.round((event.data.originalHeight + event.pageY - event.data.originalY) / 10) * 10
				};
				break;

			case 'left':
				prop = {
					'x': left > max_left ? max_left : left,
					'width': event.data.originalWidth - left
				};
				break;
			default :
				console.info('unknown direction:' + direction);
				break;
		}

		if (prop.width && prop.width < MC.canvas.GROUP_MIN_PADDING)
		{
			prop.width = MC.canvas.GROUP_MIN_PADDING;
		}

		if (prop.height && prop.height < MC.canvas.GROUP_MIN_PADDING)
		{
			prop.height = MC.canvas.GROUP_MIN_PADDING;
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
			group_left = Math.ceil((parent_offset.left - canvas_offset.left + offsetX ) / 10),
			group_top = Math.ceil((parent_offset.top - canvas_offset.top + offsetY ) / 10) + 1,
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			layout_group_data = MC.canvas.data.get('layout.component.group'),
			node_minX = [],
			node_minY = [],
			node_maxX = [],
			node_maxY = [],
			group_padding = MC.canvas.GROUP_PADDING,
			parentGroup = MC.canvas.parentGroup(group_id, parent.data('class'), group_left, group_top, group_left + group_width, group_top + group_height),
			node_data,
			group_node_data,
			group_maxX,
			group_maxY,
			group_minX,
			group_minY;

		//adjust group_left
		if (offsetX < 0 )
		{
			//when resize by left,topleft, bottomleft
			group_left = Math.ceil((parent_offset.left - canvas_offset.left) / 10);
		}

		//adjust group_top
		if (direction === 'top' || direction === 'topleft' || direction === 'topright')
		{
			//when resize by left,topleft, bottomleft
			if (offsetY<0)
			{//move up
				group_top = Math.ceil((parent_offset.top - canvas_offset.top) / 10) + 1;//group title is 1 grid
			}
			else if (offsetY>0)
			{//move down
				group_top = Math.ceil((parent_offset.top - canvas_offset.top + offsetY) / 10);
			}
		}

		$.each(event.data.group_child, function (index, item)
		{
			if (layout_node_data[ item.id ])
			{
				node_data = layout_node_data[ item.id ];

				node_minX.push(node_data.coordinate[0]);
				node_minY.push(node_data.coordinate[1]);
				node_maxX.push(node_data.coordinate[0] + MC.canvas.COMPONENT_WIDTH_GRID);
				node_maxY.push(node_data.coordinate[1] + MC.canvas.COMPONENT_HEIGHT_GRID);
			}

			if (layout_group_data[ item.id ])
			{
				group_node_data = layout_group_data[ item.id ];

				node_minX.push(group_node_data.coordinate[0]);
				node_minY.push(group_node_data.coordinate[1]);
				node_maxX.push(group_node_data.coordinate[0] + group_node_data.size[0]);
				node_maxY.push(group_node_data.coordinate[1] + group_node_data.size[1]);
			}
		});

		group_maxX = Math.max.apply(Math, node_maxX) + group_padding;
		group_maxY = Math.max.apply(Math, node_maxY) + group_padding;
		group_minX = Math.min.apply(Math, node_minX) - group_padding;
		group_minY = Math.min.apply(Math, node_minY) - group_padding;

		switch (direction)
		{
			case 'topleft':
				if (group_left >= group_minX)
				{
					group_width += (group_left - group_minX);
					group_left = group_minX;
				}

				if (group_top >= group_minY)
				{
					group_height += (group_top - group_minY);
					group_top = group_minY;
				}
				break;

			case 'topright':
				group_width = group_width + group_left >= group_maxX ? group_width : group_maxX - group_left;

				if (group_top >= group_minY)
				{
					group_height += (group_top - group_minY);
					group_top = group_minY;
				}
				break;

			case 'bottomleft':
				if (group_left >= group_minX)
				{
					group_width += (group_left - group_minX);
					group_left = group_minX;
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
					group_height += (group_top - group_minY);
					group_top = group_minY;
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
					group_width += (group_left - group_minX);
					group_left = group_minX;
				}
				break;
		}

		if (event.data.group_child.length === MC.canvas.areaChild(group_id, group_left, group_top, group_left + group_width, group_top + group_height).length)
		{
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

			//update group-resizer
			MC.canvas.updateResizer(parent, group_width, group_height);
		}
		else
		{
			parent.attr('transform', event.data.originalTranslate);

			target.attr({
				'x': 0,
				'y': 0,
				'width': event.data.originalWidth,
				'height': event.data.originalHeight
			});

			group_title.attr({
				'x': 1,
				'y': -6
			});
		}

		$(document.body).off({
			'mousemove': MC.canvas.event.groupResize.mousemove,
			'mouseup': MC.canvas.event.groupResize.mouseup
		});
	}
};

MC.canvas.volumeBubble = function (node)
{
	if (!$('#volume-bubble-box')[0])
	{
		var target = $(node),
			component_data = MC.canvas.data.get('component'),
			node_volume_data = component_data[ node.id ].resource.BlockDeviceMapping,

			data = {'list': []},
			coordinate = {},
			volume_id,
			width,
			height,
			target_offset,
			target_width,
			target_height;

		$(document.body).append('<div id="volume-bubble-box"><div class="arrow"></div><div id="volume-bubble-content"></div></div>');
		bubble_box = $('#volume-bubble-box');

		$.each(node_volume_data, function (index, item)
		{
			volume_id = item.replace('#', '');
			volume_data = component_data[ volume_id ];

			data.list.push({
				'volume_id': volume_id,
				'name': volume_data.name,
				'size': volume_data.resource.Size
			});
		});

		data.volumeLength = node_volume_data.length;

		$('#volume-bubble-content').html(
			MC.template.instanceVolume( data )
		);

		target_offset = target[0].getBoundingClientRect();
		target_width = target_offset.width;
		target_height = target_offset.height;
		
		width = bubble_box.width();
		height = bubble_box.height();

		if (target_offset.left + target_width + width - document.body.scrollLeft > window.innerWidth)
		{
			coordinate.left = target_offset.left - width - 15;
			bubble_box.addClass('bubble-right');
		}
		else
		{
			coordinate.left = target_offset.left + target_width + 15;
			bubble_box.addClass('bubble-left');
		}

		coordinate.top = target_offset.top - ((height - target_height) / 2);

		bubble_box
			.data('target-id', node.id)
			.css(coordinate)
			.show();

		$('#' + node.id + '_volume_status').attr('href', '../assets/images/ide/icon/instance-volume-attached-active.png');
	}
};

MC.canvas.event.volumeShow = function (event)
{
	var bubble_box = $('#volume-bubble-box'),
		target_id = $(this).data('target-id');

	if (!bubble_box[0])
	{
		MC.canvas.volumeBubble(
			document.getElementById( target_id )
		);
	}
	else
	{
		bubble_box.remove();

		$('#' + target_id + '_volume_status').attr('href', '../assets/images/ide/icon/instance-volume-attached-normal.png');
	}

	return false;
};

MC.canvas.event.volumeSelect = function ()
{
	var volume_id = this.id;

	$('#instance_volume_list').find('.selected').removeClass('selected');

	$(this).addClass('selected');

	//dispatch event when select volume node
	$("#svg_canvas").trigger("CANVAS_NODE_SELECTED", volume_id);

	return false;
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

	//dispatch event when click blank area in canvas
	$("#svg_canvas").trigger("CANVAS_NODE_SELECTED", "");
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