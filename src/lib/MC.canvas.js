// MC.Canvas
// Author: Angel

//json data for current tab
MC.canvas_data = {};

//variable for current tab
MC.canvas_property = {};

MC.canvas = {

	getState: function ()
	{
		return MC.canvas_data.stack_id !== undefined ? 'app' : 'stack';
	},

	display: function (id, key, is_visible)
	{
		var target = $('#' + id + '_' + key);

		if (is_visible === null || is_visible === undefined)
		{
			switch (target.attr('display'))
			{
				case 'none':
					is_visible = false;
					break;

				default:
					is_visible = true;
					break;
			}
			return is_visible;
		}
		else if (is_visible === true)
		{
			target.attr('display', 'inline');
		}
		else
		{
			target.attr('display', 'none');
		}
	},

	update: function (id, type, key, value)
	{
		var target = $('#' + id + '_' + key);

		switch (type)
		{
			case 'text':
				target.text(value);
				break;

			case 'image':
				target.attr('href', value);
				break;

			case 'eip':
				target.attr('data-eip-state', value);
				break
		}

		return true;
	},

	zoomIn: function ()
	{
		var canvas_size = MC.canvas.data.get('layout.size');

		if (MC.canvas_property.SCALE_RATIO > 1)
		{
			MC.canvas_property.SCALE_RATIO = (MC.canvas_property.SCALE_RATIO * 10 - 2) / 10;

			$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] * MC.canvas_property.SCALE_RATIO + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1] * MC.canvas_property.SCALE_RATIO);

			$('#canvas_body').css('background-image', 'url("../assets/images/ide/grid_x' + MC.canvas_property.SCALE_RATIO + '.png")');
		}

		if (MC.canvas_property.SCALE_RATIO === 1 && $('#canvas_body').hasClass('canvas_zoomed'))
		{
			$('#canvas_body')
				.removeClass('canvas_zoomed')
				.off('mousedown', '.dragable', MC.canvas.event.selectNode)
				.on('mousedown', '.instance-volume', MC.canvas.volume.show)
				.on('mousedown', '.eip-status', MC.canvas.event.EIPstatus)
				.on('mousedown', '.port', MC.canvas.event.drawConnection.mousedown)
				.on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
				.on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown);
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

		$('#canvas_body')
			.addClass('canvas_zoomed')
			.on('mousedown', '.dragable', MC.canvas.event.selectNode)
			.off('mousedown', '.instance-volume', MC.canvas.volume.show)
			.off('mousedown', '.eip-status', MC.canvas.event.EIPstatus)
			.off('mousedown', '.port', MC.canvas.event.drawConnection.mousedown)
			.off('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
			.off('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown);
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
			node_maxX.push(data.coordinate[0] + MC.canvas.COMPONENT_SIZE[ data.type ][0]);
			node_maxY.push(data.coordinate[1] + MC.canvas.COMPONENT_SIZE[ data.type ][1]);
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
			closestRange = 2 * MC.canvas.CORNER_RADIUS, //2*cornerRadius
			p1,
			p2;

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

		var d = '',
			last_p = {},
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

	_bezier_corner: function(controlPoints)
	{
		var d = '';

		if (controlPoints.length>=6)
		{
			var start0 = controlPoints[0],
				start = controlPoints[1],
				end = controlPoints[controlPoints.length-2],
				end0 = controlPoints[controlPoints.length-1],
				mid,
				c2,
				c3;

				/*
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = {
					x: mid.x,
					y: start.y
				};

				c3 = {
					x: mid.x,
					y: mid.y
				};

				d = 'M ' + start0.x + ' ' + start0.y + ' L ' + start.x + ' ' + start.y
					+ ' Q ' + c2.x + ' ' + c2.y + ' ' + c3.x + ' ' + c3.y
					+ ' T ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;
				*/

				/*
				//method 1
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = {
					x: mid.x,
					y: start.y
				};

				c3 = {
					x: mid.x,
					y: end.y
				};

				d = 'M ' + start0.x + ' ' + start0.y + ' L ' + start.x + ' ' + start.y
					+ ' C ' + c2.x + ' ' + c2.y + ' ' + c3.x + ' ' + c3.y
					+ ' ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;
				*/

				//method 2
				mid = {
					x: (start.x + end.x)/2,
					y: (start.y + end.y)/2
				};

				c2 = controlPoints[2];

				c3 = controlPoints[controlPoints.length - 3];

				d = 'M ' + start0.x + ' ' + start0.y + ' L ' + start.x + ' ' + start.y
					+ ' C ' + c2.x + ' ' + c2.y + ' ' + c3.x + ' ' + c3.y
					+ ' ' + end.x + ' ' + end.y
					+ ' L ' + end0.x + ' ' + end0.y;

		}
		else
		{
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
		}

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

	_adjustMidY: function (port_id, mid_y, point, sign)
	{
		switch (port_id)
		{
			case 'rtb-src':
				mid_y = point.y;
				break;
			case 'rtb-tgt-left':
			case 'rtb-tgt-right': //both left and right
				mid_y = point.y + 40 * sign;
				break;
		}
		return mid_y;
	},

	_adjustMidX: function (port_id, mid_x, point, sign)
	{
		switch (port_id)
		{
			case 'rtb-tgt-left': //for start
				mid_x = point.x + 4;
				break;
			case 'rtb-tgt-right': //for end
				mid_x = point.x - 4;
				break;
			case 'rtb-src': //both top and bottom
				mid_x = point.x + 40 * sign;
				break;
		}
		return mid_x;
	},

	_route2: function (controlPoints, start0, end0, from_type, to_type, from_port_name, to_port_name)
	{
		//add by xjimmy, connection algorithm (xjimmy's algorithm)

		var start = {},
			end = {},
			mid_x,
			mid_y,
			//start.x>=end.x
			start_0_90 = false,
			end_0_90 = false,
			start_180_270 = false,
			end_180_270 = false,
			//start.x<end.x
			start_0_270 = false,
			end_0_270 = false,
			start_90_180 = false,
			end_90_180 = false;

		//deep copy
		$.extend(true, start, start0);
		$.extend(true, end, end0);

		if (Math.sqrt(Math.pow(end0.y - start0.y, 2) + Math.pow(end0.x-start0.x, 2)) > MC.canvas.PORT_PADDING * 2)
		{
			//add pad to start and end
			MC.canvas._addPad(start, 0);
			MC.canvas._addPad(end, 0);
		}

		MC.canvas._addPad(start, 0);
		MC.canvas._addPad(end, 0);

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
			//swap from_type and to_type
			var tmp_type  = from_type;
			from_type = to_type;
			to_type = tmp_type;
			//swap from_port_name and to_port_name
			var tmp_port_name  = from_port_name;
			from_port_name = to_port_name;
			to_port_name = tmp_port_name;
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
			mid_y = (start.y + end.y) / 2;
			if (to_type === "AWS.VPC.RouteTable" && to_type !== from_type)
			{
				if (Math.abs(mid_y - end.y) > 5)
				{
					mid_y = MC.canvas._adjustMidY(to_port_name, mid_y, end, 1);
				}
			}
			else if (from_type === "AWS.VPC.RouteTable" && to_type !== from_type)
			{
				if (Math.abs(start.y - mid_y) > 5)
				{
					mid_y = MC.canvas._adjustMidY(from_port_name, mid_y, start, -1);
				}
			}
			controlPoints.push( { 'x': start.x, 'y': mid_y });
			controlPoints.push( { 'x': end.x, 'y': mid_y });
		}
		else if (
			(start_180_270 && end_0_90) ||
			(start_0_270 && end_90_180)
		)
		{
			//D
			mid_x = (start.x + end.x) / 2;
			if (to_type === 'AWS.VPC.RouteTable' && to_type !== from_type)
			{
				if (Math.abs(start.x - mid_x) > 5)
				{
					mid_x = MC.canvas._adjustMidX(to_port_name, mid_x, start, 1);
				}
			}
			else if (from_type === 'AWS.VPC.RouteTable' && to_type !== from_type)
			{
				if (Math.abs(mid_x - end.x) > 5)
				{
					if (to_type === 'AWS.VPC.InternetGateway' || to_type === 'AWS.VPC.VPNGateway')
					{
						mid_x = MC.canvas._adjustMidX(from_port_name, mid_x, end, -1);
					}
					else
					{
						mid_x = MC.canvas._adjustMidX(from_port_name, mid_x, start, -1);
					}
				}
			}
			controlPoints.push({'x': mid_x, 'y': start.y});
			controlPoints.push({'x': mid_x, 'y': end.y});
		}

		//3.end point
		controlPoints.push({'x': end.x, 'y': end.y});
		controlPoints.push({'x': end0.x, 'y': end0.y});

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
		if (typeof from_node === 'string')
		{
			from_node = $('#' + from_node);
		}

		if (typeof to_node === 'string')
		{
			to_node = $('#' + to_node);
		}

		var canvas_offset = $('#svg_canvas').offset(),
			from_uid = from_node.attr('id'),
			to_uid = to_node.attr('id'),
			layout_component_data = MC.canvas.data.get('layout.component'),
			layout_node_data = layout_component_data.node,
			from_node_type = from_node.data('type'),
			to_node_type = to_node.data('type'),
			from_data = layout_component_data[ from_node_type ][ from_uid ],
			to_data = layout_component_data[ to_node_type ][ to_uid ],
			from_type = from_data.type,
			to_type = to_data.type,
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

			from_node_connection_data = from_data.connection || [];
			to_node_connection_data = to_data.connection || [];
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
				// Special connection
				if (
					// AWS.VPC.Subnet to AWS.VPC.RouteTable
					(from_type === 'AWS.VPC.Subnet' && to_type === 'AWS.VPC.RouteTable') ||
					(to_type === 'AWS.VPC.Subnet' && from_type === 'AWS.VPC.RouteTable') ||

					// AWS.EC2.Instance to AWS.VPC.NetworkInterface
					(from_type === 'AWS.EC2.Instance' && to_type === 'AWS.VPC.NetworkInterface' && from_target_port === 'instance-sg' && to_target_port === 'eni-sg') ||
					(to_type === 'AWS.EC2.Instance' && from_type === 'AWS.VPC.NetworkInterface' && to_target_port === 'instance-sg' && from_target_port === 'eni-sg') ||

					// AWS.EC2.Instance to AWS.ELB
					(from_type === 'AWS.EC2.Instance' && to_type === 'AWS.ELB' && from_target_port === 'instance-sg' && to_target_port === 'elb-sg-out') ||
					(to_type === 'AWS.EC2.Instance' && from_type === 'AWS.ELB' && to_target_port === 'instance-sg' && from_target_port === 'elb-sg-out') ||

					(from_type === 'AWS.EC2.Instance' && to_type === 'AWS.ELB' && from_target_port === 'instance-sg' && to_target_port === 'elb-sg-in') ||
					(to_type === 'AWS.EC2.Instance' && from_type === 'AWS.ELB' && to_target_port === 'instance-sg' && from_target_port === 'elb-sg-in') ||


					// AWS.EC2.Instance to AWS.EC2.Instance
					(from_type === 'AWS.EC2.Instance' && to_type === 'AWS.EC2.Instance')
				)
				{
					if (from_type === 'AWS.VPC.Subnet')
					{
						from_port = from_node.find('.port-' + from_target_port);
						from_port_offset = from_port[0].getBoundingClientRect();

						if (from_port_offset.top > to_node[0].getBoundingClientRect().top)
						{
							to_port = to_node.find('.port-rtb-src-bottom');
						}
						else
						{
							to_port = to_node.find('.port-rtb-src-top');
						}

						to_port_offset = to_port[0].getBoundingClientRect();
					}

					if (to_type === 'AWS.VPC.Subnet')
					{
						to_port = to_node.find('.port-' + to_target_port);
						to_port_offset = to_port[0].getBoundingClientRect();

						if (to_port_offset.top > from_node[0].getBoundingClientRect().top)
						{
							from_port = from_node.find('.port-rtb-src-bottom');
						}
						else
						{
							from_port = from_node.find('.port-rtb-src-top');
						}

						from_port_offset = from_port[0].getBoundingClientRect();
					}

					if (from_type === 'AWS.VPC.NetworkInterface')
					{
						if (from_node[0].getBoundingClientRect().left > to_node[0].getBoundingClientRect().left)
						{
							from_port = from_node.find('.port-eni-sg-left');
							to_port = to_node.find('.port-instance-sg-right');
						}
						else
						{
							from_port = from_node.find('.port-eni-sg-right');
							to_port = to_node.find('.port-instance-sg-left');
						}

						from_port_offset = from_port[0].getBoundingClientRect();
						to_port_offset = to_port[0].getBoundingClientRect();
					}

					if (to_type === 'AWS.VPC.NetworkInterface')
					{
						if (from_node[0].getBoundingClientRect().left > to_node[0].getBoundingClientRect().left)
						{
							from_port = from_node.find('.port-instance-sg-left');
							to_port = to_node.find('.port-eni-sg-right');
						}
						else
						{
							from_port = from_node.find('.port-instance-sg-right');
							to_port = to_node.find('.port-eni-sg-left');
						}

						from_port_offset = from_port[0].getBoundingClientRect();
						to_port_offset = to_port[0].getBoundingClientRect();
					}

					if (from_type === 'AWS.ELB')
					{
						from_port = from_node.find('.port-' + from_target_port);

						if (from_node[0].getBoundingClientRect().left > to_node[0].getBoundingClientRect().left)
						{
							to_port = to_node.find('.port-instance-sg-right');
						}
						else
						{
							to_port = to_node.find('.port-instance-sg-left');
						}

						from_port_offset = from_port[0].getBoundingClientRect();
						to_port_offset = to_port[0].getBoundingClientRect();
					}

					if (to_type === 'AWS.ELB')
					{
						to_port = to_node.find('.port-' + to_target_port);

						if (from_node[0].getBoundingClientRect().left > to_node[0].getBoundingClientRect().left)
						{
							from_port = from_node.find('.port-instance-sg-left');
						}
						else
						{
							from_port = from_node.find('.port-instance-sg-right');
						}

						from_port_offset = from_port[0].getBoundingClientRect();
						to_port_offset = to_port[0].getBoundingClientRect();
					}

					if (from_type === 'AWS.EC2.Instance' && to_type === 'AWS.EC2.Instance')
					{
						if (from_node[0].getBoundingClientRect().left > to_node[0].getBoundingClientRect().left)
						{
							from_port = from_node.find('.port-instance-sg-left');
							to_port = to_node.find('.port-instance-sg-right');
						}
						else
						{
							from_port = from_node.find('.port-instance-sg-right');
							to_port = to_node.find('.port-instance-sg-left');
						}

						from_port_offset = from_port[0].getBoundingClientRect();
						to_port_offset = to_port[0].getBoundingClientRect();
					}
				}
				else
				{
					from_port = from_node.find('.port-' + from_target_port);
					from_port_offset = from_port[0].getBoundingClientRect();
					to_port = to_node.find('.port-' + to_target_port);
					to_port_offset = to_port[0].getBoundingClientRect();
				}

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

				//line style
				MC.paper.start({
					'stroke': connection_option.color,
					'stroke-width': MC.canvas.LINE_STROKE_WIDTH,
					'fill': 'none'
				});

				if (start0.x === end0.x || start0.y === end0.y)
				{
					//draw straight line
					MC.paper.line(start0.x, start0.y, end0.x, end0.y);

					//draw dash line
					if (
						connection_option.stroke_dasharray &&
						connection_option.color_dash &&
						connection_option.stroke_dasharray !== ''
					)
					{
						MC.paper.line(start0.x, start0.y, end0.x, end0.y).attr({
							'stroke': connection_option.color_dash,
							'stroke-width': MC.canvas.LINE_STROKE_WIDTH,
							'fill': 'none',
							'stroke-dasharray': connection_option.stroke_dasharray
						});
					}
				}
				else
				{
					//draw fold line

					///// route 1 (xjimmy's algorithm)/////
					MC.canvas._route2(controlPoints, start0, end0, from_type, to_type ,from_target_port, to_target_port);

					///// route 2 (ManhattanConnectionRouter, draw2d's algorithm) /////
					//MC.canvas._route( controlPoints, start0, from_port.data('angle'), end0, to_port.data('angle') );

					///// draw fold line /////
					if (controlPoints.length>0)
					{
						////// draw polyline /////
						//MC.paper.polyline(controlPoints);

						/////draw round corner line /////
						var d = MC.canvas._round_corner( controlPoints );    //method 1
						//var d = MC.canvas._bezier_corner( controlPoints ); //method 2
						if (d !== "")
						{
							MC.paper.path(d);

							//draw dash fold line
							if (
								connection_option.stroke_dasharray  &&
								connection_option.color_dash &&
								connection_option.stroke_dasharray !== ''
							)
							{
								MC.paper.path(d, {
									'stroke': connection_option.color_dash,
									'stroke-width': MC.canvas.LINE_STROKE_WIDTH,
									'fill': 'none',
									'stroke-dasharray': connection_option.stroke_dasharray
								});
							}
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

					MC.canvas.data.set('layout.component.' + from_node_type + '.' + from_uid + '.connection', from_node_connection_data);
					MC.canvas.data.set('layout.component.' + to_node_type + '.' + to_uid + '.connection', to_node_connection_data);
				}

				layout_connection_data = MC.canvas.data.get('layout.connection.' + svg_line.id) || {};

				if (!line_option)
				{
					connection_target_data[ from_uid ] = from_target_port;
					connection_target_data[ to_uid ] = to_target_port;

					layout_connection_data = {
						'target': connection_target_data,
						'auto': true,
						'point': [],
						'type': connection_option.type
					};
				}
				MC.canvas.data.set('layout.connection.' + svg_line.id, layout_connection_data);

				return svg_line.id;
			}
		}
	},

	reConnect: function (node_id)
	{
		var node = $('#' + node_id),
			node_connections = MC.canvas.data.get('layout.component.' + node.data('type') + '.' + node_id + '.connection') || {},
			layout_connection_data = MC.canvas.data.get('layout.connection'),
			line_layer = document.getElementById('line_layer');

		$.each(node_connections, function (index, value)
		{
			line_target = layout_connection_data[ value.line ][ 'target' ];

			line_layer.removeChild( document.getElementById( value.line ) );

			MC.canvas.connect(
				node_id, line_target[ node_id ],
				value.target, line_target[ value.target ],
				{'line_uid': value['line']}
			);
		});

		return true;
	},

	select: function (id)
	{
		var target = $('#' + id),
			target_type = target.data('type'),
			svg_canvas = $("#svg_canvas"),
			clone_node;

		Canvon(target[0]).addClass('selected');

		if (target_type === 'line')
		{
			clone = target.clone();

			target.remove();
			$('#line_layer').append(clone);

			svg_canvas.trigger("CANVAS_LINE_SELECTED", id);
		}

		if (target_type === 'node')
		{
			clone = target.clone();

			target.remove();
			$('#node_layer').append(clone);

			svg_canvas.trigger("CANVAS_NODE_SELECTED", id);
		}

		if (target_type === 'group')
		{
			svg_canvas.trigger("CANVAS_NODE_SELECTED", id);
		}

		MC.canvas_property.selected_node.push(id);

		return true;
	},

	position: function (node, x, y)
	{
		x = x > 0 ? x : 0;
		y = y > 0 ? y : 0;

		MC.canvas.data.set('layout.component.' + node.getAttribute('data-type') + '.' + node.id + '.coordinate', [x, y]);
		node.setAttribute('transform', 'translate(' + (x * MC.canvas.GRID_WIDTH) + ',' + (y * MC.canvas.GRID_HEIGHT) + ')');

		return true;
	},

	remove: function (node)
	{
		var node_id = node.id,
			target = $(node),
			target_type = target.data('type'),
			node_type = target.data('class');

		if (target_type === 'line')
		{
			var line_data = MC.canvas.data.get('layout.connection.' + node_id),
				layout_component_data = MC.canvas.data.get('layout.component'),
				target_connection,
				target_node,
				new_connection_data;

			$.each(line_data.target, function (target_id, target_port)
			{
				target_node = $('#' + target_id);
				target_node_type = target_node.data('type');
				target_connection = layout_component_data[ target_node_type ][ target_id ].connection;
				new_connection_data = [];

				$.each(target_connection, function (i, option)
				{
					if (option.line !== node_id)
					{
						new_connection_data.push(option);
					}
				});

				MC.canvas.data.set('layout.component.' + target_node_type + '.' + target_id + '.connection', new_connection_data);
			});

			MC.canvas.data.delete('layout.connection.' + node_id);
		}

		if (target_type === 'node')
		{
			var	layout_node_data = MC.canvas.data.get('layout.component.node'),
				layout_connection_data = MC.canvas.data.get('layout.connection'),
				line_layer = document.getElementById('line_layer'),
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

			MC.canvas.data.delete('layout.component.' + target_type + '.' + node_id);
			MC.canvas.data.delete('component.' + node_id);
		}

		if (target_type === 'group')
		{
			var group_child = MC.canvas.groupChild(node),
				group_data = MC.canvas.data.get('layout.component.group.' + node_id);

			if (node_type === 'AWS.VPC.Subnet' && group_data.connection.length > 0)
			{
				$.each(group_data.connection, function (index, data)
				{
					MC.canvas.remove(document.getElementById(data.line));
				});
			}

			$.each(group_child, function (index, item)
			{
				MC.canvas.remove(item);
			});

			MC.canvas.data.delete('layout.component.group.' + node_id);
		}

		target.remove();

		return true;
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
			component_size,
			matched,
			node_coordinate;

		$.each(children, function (key, item)
		{
			node_coordinate = item.coordinate;
			component_size = MC.canvas.COMPONENT_SIZE[ item.type ];

			if (
				node_coordinate &&
				node_coordinate[0] < coordinate.x &&
				node_coordinate[0] + component_size[0] > coordinate.x &&
				node_coordinate[1] < coordinate.y &&
				node_coordinate[1] + component_size[1] > coordinate.y
			)
			{
				matched = document.getElementById( key );

				return false;
			}
		});

		return matched;
	},

	isMatchPlace: function (target_id, target_type, node_type, x, y, width, height)
	{
		var layout_group_data = MC.canvas.data.get('layout.component.group'),
			platform = MC.canvas.data.get('platform'),
			group_stack = [
				$('#subnet_layer').children(),
				$('#az_layer').children(),
				$('#vpc_layer').children()
			],
			point = [
				{
					'x': x,
					'y': y
				},
				{
					'x': x + width,
					'y': y
				},
				{
					'x': x,
					'y': y + height
				},
				{
					'x': x + width,
					'y': y + height
				}
			],
			match_option = MC.canvas.MATCH_PLACEMENT[ platform ][ node_type ],
			is_option_canvas = match_option[ 0 ] === 'Canvas',
			ignore_stack = [],
			match = [],
			result = {},
			match_status,
			is_matched,
			match_target,
			group_data,
			group_child,
			coordinate,
			size;

		if (target_id !== null)
		{
			ignore_stack.push(target_id);

			if (target_type === 'group')
			{
				group_child = MC.canvas.groupChild(document.getElementById(target_id));

				$.each(group_child, function (index, item)
				{
					if (item.getAttribute('data-type') === 'group')
					{
						ignore_stack.push(item.id);
					}
				});
			}
		}

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
							$.inArray(item.id, ignore_stack) === -1 &&
							//target_id !== item.id &&
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

			return {
				'is_matched': $.isEmptyObject(result),
				'target': result.id === undefined && is_matched ? 'Canvas' : result.id
			};
		}
		else
		{
			$.each(point, function (index, data)
			{
				$.each(group_stack, function (i, layer_data)
				{
					if (layer_data)
					{
						match_status = {};
						$.each(layer_data, function (i, item)
						{
							group_data = layout_group_data[ item.id ];
							coordinate = group_data.coordinate;
							size = group_data.size;

							if (
								//target_id !== item.id &&
								$.inArray(item.id, ignore_stack) === -1 &&
								data.x > coordinate[0] &&
								data.x < coordinate[0] + size[0] &&
								data.y > coordinate[1] &&
								data.y < coordinate[1] + size[1]
							)
							{
								match_status['is_matched'] = $.inArray(group_data.type, match_option) > -1;
								match_target = item.id;
								return false;
							}
						});

						if (!$.isEmptyObject(match_status))
						{
							match[ index ] = match_status;
							return false;
						}
					}
				});
			});

			is_matched =
				match[0] &&
				match[0].is_matched &&
				match[1] &&
				match[1].is_matched &&
				match[2] &&
				match[2].is_matched &&
				match[3] &&
				match[3].is_matched;

			if (
				!is_matched &&
				$.inArray('Canvas', match_option) > -1 &&
				!match[0] &&
				!match[1] &&
				!match[2] &&
				!match[3]
			)
			{
				is_matched = true;
				match_target = 'Canvas';
			}

			return {
				'is_matched': is_matched,
				'target': is_matched ? match_target : null
			};
		}
	},

	isBlank: function (type, target_id, x, y, width, height)
	{
		var children = MC.canvas.data.get('layout.component.' + type),
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			isBlank = true,
			start_x,
			start_y,
			end_x,
			end_y
			coordinate,
			size;

		if (type === 'group')
		{
			start_x = x * scale_ratio;
			start_y = y * scale_ratio;
			end_x = (x + width) * scale_ratio;
			end_y = (y + height) * scale_ratio;
			target_type = children[ target_id ].type;

			$.each(children, function (key, item)
			{
				coordinate = item.coordinate;
				size = item.size;

				if (
					key !== target_id &&
					item.type === target_type &&
					coordinate[0] <= end_x &&
					coordinate[0] + size[0] >= start_x &&
					coordinate[1] <= end_y &&
					coordinate[1] + size[1] >= start_y
				)
				{
					isBlank = false;
				}
			});
		}

		return isBlank;
	},

	parentGroup: function (node_id, node_type, start_x, start_y, end_x, end_y)
	{
		var groups = MC.canvas.data.get('layout.component.group'),
			group_parent_type = MC.canvas.MATCH_PLACEMENT[ MC.canvas.data.get('platform') ][ node_type ],
			matched;

		$.each(groups, function (key, item)
		{
			coordinate = item.coordinate;
			size = item.size;

			if (
				node_id !== key &&
				$.inArray(item.type, group_parent_type) > -1 &&
				(
					coordinate[0] < start_x &&
					coordinate[0] + size[0] > start_x
				)
				&&
				(
					coordinate[1] < start_y &&
					coordinate[1] + size[1] > start_y
				)
			)
			{
				matched = document.getElementById( key );

				return false;
			}
		});

		return matched;
	},

	areaChild: function (node_id, start_x, start_y, end_x, end_y)
	{
		var children = MC.canvas.data.get('layout.component.node'),
			groups = MC.canvas.data.get('layout.component.group'),
			group_data = groups[ node_id ],
			group_weight = MC.canvas.GROUP_WEIGHT[ group_data.type ],
			matched = [],
			coordinate,
			size;

		$.each(children, function (key, item)
		{
			coordinate = item.coordinate;
			size = MC.canvas.COMPONENT_SIZE[ item.type ];

			if (
				node_id !== key &&
				item.type !== 'AWS.VPC.InternetGateway' &&
				item.type !== 'AWS.VPC.VPNGateway' &&
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

		$.each(groups, function (key, item)
		{
			coordinate = item.coordinate;
			size = item.size;

			if (
				node_id !== key &&
				($.inArray(item.type, group_weight) > -1 || item.type === group_data.type) &&
				start_x <= coordinate[0] + size[0] &&
				end_x >= coordinate[0] &&
				start_y <= coordinate[1] + size[1] &&
				end_y >= coordinate[1]
			)
			{
				matched.push(document.getElementById( key ));
			}
		});

		return matched;
	},

	groupChild: function (group_node)
	{
		var group_data = MC.canvas.data.get('layout.component.group.' + group_node.id),
			coordinate = group_data.coordinate;

		return MC.canvas.areaChild(
			group_node.id,
			coordinate[0],
			coordinate[1],
			coordinate[0] + group_data.size[0],
			coordinate[1] + group_data.size[1]
		);
	},

	lineTarget: function (line_id)
	{
		var data = MC.canvas.data.get('layout.connection.' + line_id + '.target'),
			result = [];

		$.each(data, function (key, value)
		{
			result.push({
				'uid': key,
				'port': value
			});
		});

		return result;
	}
};

MC.canvas.layout = {
	init: function ()
	{
		var layout_data = MC.canvas.data.get("layout"),
			connection_target_id,
			tmp,
			sg_uids;

		MC.paper = Canvon('svg_canvas');

		MC.canvas_property = $.extend(true, {}, MC.canvas.STACK_PROPERTY);

		components = MC.canvas.data.get("component");

		$.each(components, function (key, value)
		{
			if (value.type === 'AWS.EC2.KeyPair')
			{
				tmp = {};
				tmp[value.name] = value.uid;
				MC.canvas_property.kp_list.push(tmp);
			}
			if (value.type === "AWS.EC2.SecurityGroup")
			{
				tmp = {};
				tmp.name = value.name;
				tmp.uid = value.uid;
				tmp.member = [];
				$.each(components, function (k, v)
				{
					if (v.type === "AWS.EC2.Instance")
					{
						sg_uids = v.resource.SecurityGroupId;
						$.each(sg_uids, function (id, sg_ref)
						{
							if (sg_ref.split('.')[0].slice(1) === tmp.uid)
							{
								tmp.member.push(v.uid);
							}
						})
					}
				});
				MC.canvas_property.sg_list.push(tmp);
			}
			if (
				value.type === "AWS.VPC.RouteTable" &&
				value.resource.AssociationSet.length > 0 &&
				value.resource.AssociationSet[0].Main === true
			)
			{
				MC.canvas_property.main_route = value.uid;
			}
			if (
				value.type === "AWS.VPC.NetworkAcl" &&
				value.resource.Default === true
			)
			{
				MC.canvas_property.default_acl = value.uid;
			}
		});

		$.each(MC.canvas_property.sg_list, function (key, value)
		{
			if (value.name === "DefaultSG" && key !== 0)
			{
				tmp = value;
				MC.canvas_property.sg_list.splice(key, 1);
				MC.canvas_property.sg_list.unshift(value);
				return false;
			}
		});

		$.each(MC.canvas_property.kp_list, function (key, value)
		{
			if (value.DefaultKP !== undefined && key !== 0)
			{
				tmp = value;
				MC.canvas_property.kp_list.splice(key, 1);
				MC.canvas_property.kp_list.unshift(value);

				return false;
			}
		});

		$('#svg_canvas').attr({
			'width': layout_data.size[0] * MC.canvas.GRID_WIDTH,
			'height': layout_data.size[1] * MC.canvas.GRID_HEIGHT
		});

		$('#canvas_container').css({
			'width': layout_data.size[0] * MC.canvas.GRID_WIDTH,
			'height': layout_data.size[1] * MC.canvas.GRID_HEIGHT
		});

		if (layout_data.component.node)
		{
			$.each(layout_data.component.node, function (id, data)
			{
				MC.canvas.add(id);
			});
		}
		else
		{
			layout_data.component.node = {};
		}

		if (layout_data.component.group)
		{
			$.each(layout_data.component.group, function (id, data)
			{
				MC.canvas.add(id);
			});
		}
		else
		{
			layout_data.component.group = {};
		}

		if (layout_data.connection)
		{
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
		}
		else
		{
			layout_data.connection = {};
		}

		//store json to original_json
		MC.canvas_property.original_json = JSON.stringify(MC.canvas_data);

		return true;
	},

	create: function (option)
	{
		MC.paper = Canvon('svg_canvas');

		//clone MC.canvas.STACK_JSON to MC.canvas_data
		MC.canvas_data = $.extend(true, {}, MC.canvas.STACK_JSON);

		//clone MC.canvas.STACK_PROPERTY to MC.canvas_property
		MC.canvas_property = $.extend(true, {}, MC.canvas.STACK_PROPERTY);

		//set region and platform
		if (option.id)
		{
			MC.canvas_data.id = option.id; //tab_id (temp for new stack)
		}
		MC.canvas_data.name = option.name;
		MC.canvas_data.region = option.region;
		MC.canvas_data.platform = option.platform;

		var canvas_size = MC.canvas.data.get('layout.size');

		uid = MC.guid();
		kp = $.extend(true, {}, MC.canvas.KP_JSON.data);
		kp.uid = uid;
		tmp = {};
		tmp[kp.name] = kp.uid;
		MC.canvas_property.kp_list.push(tmp);
		sg_uid = MC.guid();
		sg = $.extend(true, {}, MC.canvas.SG_JSON.data);
		sg.uid = sg_uid;
		tmp = {};
		tmp.uid = sg.uid;
		tmp.name = sg.name;
		tmp.member = [];
		MC.canvas_property.sg_list.push(tmp);
		data = MC.canvas.data.get('component');
		data[kp.uid] = kp;
		data[sg.uid] = sg;
		MC.canvas.data.set('component', data);

		if (option.platform === MC.canvas.PLATFORM_TYPE.CUSTOM_VPC || option.platform === MC.canvas.PLATFORM_TYPE.EC2_VPC)
		{
			//has vpc (create vpc, az, and subnet by default)
			vpc_group = MC.canvas.add('AWS.VPC.VPC', {
				'name': 'vpc1'
			}, {
				'x': 5,
				'y': 3
			});

			var node_rt = MC.canvas.add('AWS.VPC.RouteTable', {
				'name': 'RT-0',
				'group' : {
					'vpcUId' : vpc_group.id
				},
				'main' : true
			},{
				'x': 50,
				'y': 5
			});

			//default sg
			main_asso = {
				"Main": "true",
				"RouteTableId": "",
				"SubnetId": "",
				"RouteTableAssociationId": ""
			};
			MC.canvas_data.component[node_rt.id].resource.AssociationSet.push(main_asso);
			MC.canvas_property.main_route = node_rt.id;

			acl = $.extend(true, {}, MC.canvas.ACL_JSON.data);
			acl.uid = MC.guid();
			acl.resource.Default = 'true';
			acl.resource.VpcId = "@" + vpc_group.id + '.resource.VpcId';
			data[acl.uid] = acl;
			MC.canvas.data.set('component', data);

			MC.canvas_property.default_acl = acl.uid;

			sg.resource.VpcId = "@" + vpc_group.id + '.resource.VpcId';
		}

		$('#svg_canvas').attr({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT
		});

		$('#canvas_container').css({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT
		});

		//store json to original_json
		MC.canvas_property.original_json = JSON.stringify(MC.canvas_data);

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

MC.canvas.volume = {
	bubble: function (node)
	{
		if (!$('#volume-bubble-box')[0])
		{
			var target = $(node),
				canvas_container = $('#canvas_container'),
				canvas_offset = canvas_container.offset(),
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

			canvas_container.append('<div id="volume-bubble-box"><div class="arrow"></div><div id="volume-bubble-content"></div></div>');
			bubble_box = $('#volume-bubble-box');

			$.each(node_volume_data, function (index, item)
			{
				volume_id = item.replace('#', '');
				volume_data = component_data[ volume_id ];

				data.list.push({
					'volume_id': volume_id,
					'name': volume_data.name,
					'size': volume_data.resource.Size,
					'snapshotId': volume_data.resource.SnapshotId,
					'json': JSON.stringify({
						'instance_id': node.id,
						'id': volume_id,
						'name': volume_data.name,
						'snapshotId': volume_data.resource.SnapshotId,
						'volumeSize': volume_data.resource.Size
					})
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

			//if (target_offset.left + target_width + width - document.body.scrollLeft > window.innerWidth)
			//{
				// coordinate.left = target_offset.left - width - 15 - canvas_offset.left;
				// bubble_box.addClass('bubble-right');
			// }
			// else
			// {
			coordinate.left = target_offset.left + target_width + 15 - canvas_offset.left;
			bubble_box.addClass('bubble-left');
			// }

			coordinate.top = target_offset.top - canvas_offset.top - ((height - target_height) / 2);

			bubble_box
				.data('target-id', node.id)
				.css(coordinate)
				.show();

			MC.canvas.update(node.id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_ATTACHED_ACTIVE);
		}
	},

	show: function ()
	{
		var bubble_box = $('#volume-bubble-box'),
			target_id = $(this).data('target-id'),
			bubble_target_id;

		if (!bubble_box[0])
		{
			if (MC.canvas.data.get('component.' + target_id  + '.resource.BlockDeviceMapping').length > 0)
			{
				MC.canvas.volume.bubble(
					document.getElementById( target_id )
				);
			}
			else
			{
				MC.canvas.update(target_id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_NOT_ATTACHED);
			}
		}
		else
		{
			bubble_target_id = bubble_box.data('target-id');

			MC.canvas.volume.close();

			if (target_id !== bubble_target_id)
			{
				MC.canvas.volume.bubble(
					document.getElementById( target_id )
				);
			}
		}

		return false;
	},

	select: function ()
	{
		MC.canvas.event.clearSelected();

		$('#instance_volume_list').find('.selected').removeClass('selected');

		$(this).addClass('selected');

		$(document).on('keyup', MC.canvas.volume.remove);

		//dispatch event when select volume node
		$("#svg_canvas").trigger("CANVAS_NODE_SELECTED", this.id);

		return false;
	},

	close: function (event)
	{
		var bubble_box = $('#volume-bubble-box'),
			target;

		if (event)
		{
			target = $(event.target);

			if (
				target.attr('class') === 'instance-volume' ||
				target.is('.snapshot_item') ||
				target.parent().is('.snapshot_item') ||
				target.is('.volume_item') ||
				target.parent().is('.volume_item')
			)
			{
				return false;
			}
		}

		if (bubble_box[0])
		{
			target_id = bubble_box.data('target-id');
			bubble_box.remove();

			MC.canvas.update(target_id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_NOT_ATTACHED);

			$(document)
				.off('keyup', MC.canvas.volume.remove)
				.off('click', ':not(.instance-volume, #volume-bubble-box)', MC.canvas.volume.close);
		}
	},

	remove: function (event)
	{
		if (
			(
				event.which === 46 ||
				// For Mac
				event.which === 8
			)
			&&
			event.target === document.body
		)
		{
			var bubble_box = $('#volume-bubble-box'),
				target_id = bubble_box.data('target-id'),
				target_volume_data = MC.canvas.data.get('component.' + target_id + '.resource.BlockDeviceMapping'),
				target_node = $('#' + target_id),
				target_offset = target_node[0].getBoundingClientRect(),
				volume_id = $('#instance_volume_list').find('.selected').attr('id');

			target_volume_data.splice(
				target_volume_data.indexOf(
					volume_id
				), 1
			);

			$('#instance_volume_number, #' + target_id + '_volume_number').text(target_volume_data.length);

			MC.canvas.data.set('component.' + target_id + '.resource.BlockDeviceMapping', target_volume_data);

			MC.canvas.data.delete('component.' + volume_id);

			$('#' + volume_id).parent().remove();

			bubble_box.css('top',  target_offset.top - ((bubble_box.height() - target_offset.height) / 2));

			$(document).off('keyup', MC.canvas.volume.remove);
		}
	},

	mousedown: function (event)
	{
		if (event.which === 1)
		{
			event.preventDefault();
			event.stopPropagation();

			var target = $(this),
				target_offset = target.offset(),
				canvas_offset = $('#svg_canvas').offset(),
				node_type = target.data('type'),
				target_component_type = target.data('component-type'),
				shadow,
				clone_node;

			if (MC.canvas.getState() === 'app')
			{
				MC.canvas.volume.select.call( $('#' + this.id )[0] );

				return false;
			}

			$(document.body)
				.addClass('disable-event')
				.append('<div id="drag_shadow"><div class="resource-icon resource-icon-volume"></div></div>');

			shadow = $('#drag_shadow');

			shadow
				.addClass('AWS-EC2-EBS-Volume')
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50
				});

			$('.AWS-EC2-Instance').attr('class', function (index, key)
			{
				return 'attachable ' + key;
			});

			$(document).on({
				'mousemove': MC.canvas.volume.mousemove,
				'mouseup': MC.canvas.volume.mouseup
			}, {
				'target': target,
				'canvas_offset': $('#svg_canvas').offset(),
				'shadow': shadow,
				'originalPageX': event.pageX,
				'originalPageY': event.pageY,
				'action': 'move'
			});

			MC.canvas.volume.select.call( $('#' + this.id )[0] );

			return false;
		}
	},

	mousemove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		if (
			event.data.originalX !== event.pageX ||
			event.data.originalY !== event.pageY
		)
		{
			event.data.shadow
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50
				})
				.show();
		}

		match_node = MC.canvas.matchPoint(
			event.pageX - event.data.canvas_offset.left,
			event.pageY - event.data.canvas_offset.top
		);

		if (match_node && match_node.getAttribute('data-class') === 'AWS.EC2.Instance')
		{
			MC.canvas.volume.bubble(match_node);
		}
		else
		{
			MC.canvas.volume.close();
		}

		return false;
	},

	mouseup: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = $(event.data.target),
			target_component_type = target.data('component-type'),
			node_option = target.data('option'),
			bubble_box = $('#volume-bubble-box'),
			volume_type,
			target_id,
			volume_id,
			target_az,
			target_volume_data,
			new_volume,
			data_option,
			original_node_id,
			original_node_volume_data;

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

			if (event.data.action === 'move')
			{
				volume_id = target.attr('id');
				data_option = target.data('json');
			}
			else
			{
				data_option = target.data('option');
				data_option['instance_id'] = target_id;
				new_volume = MC.canvas.add('AWS.EC2.EBS.Volume', data_option, {});
				if (new_volume === null)
				{
					event.data.action = 'cancel';
				}
				else
				{
					volume_id = new_volume.id;
					data_option.name = MC.canvas.data.get('component.' + volume_id + '.name');
				}
			}

			if (event.data.action === 'move')
			{
				if (data_option.instance_id !== target_id)
				{
					data_json = JSON.stringify({
						'instance_id': target_id,
						'id': volume_id,
						'name': data_option.name,
						'snapshotId': data_option.snapshotId,
						'volumeSize': data_option.volumeSize
					});

					volume_type = data_option.snapshotId ? 'snapshot_item' : 'volume_item';

					$('#instance_volume_list').append('<li><a href="javascript:void(0)" id="' + volume_id +'" class="' + volume_type + '" data-json=\'' + data_json + '\'><span class="volume_name">' + data_option.name + '</span><span class="volume_size">' + data_option.volumeSize + 'GB</span></a></li>');

					target_volume_data.push('#' + volume_id);

					$('#instance_volume_number').text(target_volume_data.length);

					MC.canvas.update(target_id, 'text', 'volume_number', target_volume_data.length);

					MC.canvas.data.set('component.' + target_id + '.resource.BlockDeviceMapping', target_volume_data);

					MC.canvas.volume.select.call( document.getElementById( volume_id ) );

					target_az = MC.canvas.data.get('component.' + target_id + '.resource.Placement.AvailabilityZone');

					MC.canvas.data.set('component.' + volume_id + '.resource.AvailabilityZone', target_az);

					MC.canvas.data.set('component.' + volume_id + '.resource.AttachmentSet.InstanceId', '@' + target_id + '.resource.InstanceId');

					// Update original data
					original_node_id = data_option.instance_id;
					original_node_volume_data = MC.canvas.data.get('component.' + original_node_id + '.resource.BlockDeviceMapping');

					original_node_volume_data.splice(
						original_node_volume_data.indexOf('#' + volume_id), 1
					);

					MC.canvas.data.set('component.' + original_node_id + '.resource.BlockDeviceMapping', original_node_volume_data);

					MC.canvas.update(original_node_id, 'text', 'volume_number', original_node_volume_data.length);
				}
			}
			else if (!event.data.action)
			{
				data_json = JSON.stringify({
					'instance_id': target_id,
					'id': volume_id,
					'name': data_option.name,
					'snapshotId': data_option.snapshotId,
					'volumeSize': data_option.volumeSize
				});

				volume_type = data_option.snapshotId ? 'snapshot_item' : 'volume_item';

				$('#instance_volume_list').append('<li><a href="javascript:void(0)" id="' + volume_id +'" class="' + volume_type + '" data-json=\'' + data_json + '\'><span class="volume_name">' + data_option.name + '</span><span class="volume_size">' + data_option.volumeSize + 'GB</span></a></li>');

				target_volume_data.push('#' + volume_id);

				$('#instance_volume_number').text(target_volume_data.length);

				MC.canvas.update(target_id, 'text', 'volume_number', target_volume_data.length);

				MC.canvas.data.set('component.' + target_id + '.resource.BlockDeviceMapping', target_volume_data);

				MC.canvas.volume.select.call( document.getElementById( volume_id ) );
			}

			bubble_box.css('top',  target_offset.top - $('#canvas_container').offset().top - ((bubble_box.height() - target_offset.height) / 2));
		}

		event.data.shadow.remove();

		$(document.body).removeClass('disable-event');

		$(document).off({
			'mousemove': MC.canvas.volume.mousemove,
			'mouseup': MC.canvas.volume.mouseup
		});

		return false;
	}
};

MC.canvas.event = {};
MC.canvas.event.dragable = {
	mousedown: function (event)
	{
		if (event.which === 1)
		{
			event.preventDefault();
			event.stopPropagation();

			var target = $(this),
				target_offset = Canvon(this).offset(),
				target_type = target.data('type'),
				node_type = target.data('class'),
				svg_canvas = $('#svg_canvas'),
				canvas_offset = svg_canvas.offset(),
				shadow,
				platform,
				target_group_type;

			if (node_type === 'AWS.VPC.Subnet')
			{
				target.find('.port').hide();
			}

			shadow = target.clone();

			shadow.attr('class', shadow.attr('class') + ' shadow');
			svg_canvas.append(shadow);

			if (target_type === 'node')
			{
				platform = MC.canvas.data.get('platform');
				target_group_type = MC.canvas.MATCH_PLACEMENT[ platform ][ node_type ];

				$.each(target_group_type, function (index, item)
				{
					$('.' + item.replace(/\./ig, '-')).attr('class', function (i, key)
					{
						return 'dropable-group ' + key;
					});
				});
			}

			$(document.body).addClass('disable-event');

			if (node_type === 'AWS.VPC.InternetGateway' || node_type === 'AWS.VPC.VPNGateway')
			{
				$(document).on({
					'mousemove': MC.canvas.event.dragable.gatewaymove,
					'mouseup': MC.canvas.event.dragable.gatewayup
				}, {
					'target': target,
					'canvas_body': $('#canvas_body'),
					'target_type': target_type,
					'node_type': node_type,
					'vpc_data': MC.canvas.data.get('layout.component.group.' + $('.AWS-VPC-VPC').attr('id')),
					'shadow': shadow,
					'offsetX': event.pageX - target_offset.left + canvas_offset.left,
					'offsetY': event.pageY - target_offset.top + canvas_offset.top,
					'originalPageX': event.pageX,
					'originalPageY': event.pageY
				});
			}
			else
			{
				$(document).on({
					'mousemove': MC.canvas.event.dragable.mousemove,
					'mouseup': MC.canvas.event.dragable.mouseup
				}, {
					'target': target,
					'canvas_body': $('#canvas_body'),
					'target_type': target_type,
					'shadow': shadow,
					'offsetX': event.pageX - target_offset.left + canvas_offset.left,
					'offsetY': event.pageY - target_offset.top + canvas_offset.top,
					'groupChild': target_type === 'group' ? MC.canvas.groupChild(this) : null,
					'originalPageX': event.pageX,
					'originalPageY': event.pageY
				});
			}

			MC.canvas.event.clearSelected();
		}

		return false;
	},
	mousemove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var grid_width = MC.canvas.GRID_WIDTH,
			grid_height = MC.canvas.GRID_HEIGHT,
			scale_ratio = MC.canvas_property.SCALE_RATIO;

		event.data.canvas_body.addClass('node-dragging');

		event.data.shadow.attr('transform',
			'translate(' +
				Math.round((event.pageX - event.data.offsetX) / (grid_width / scale_ratio)) * grid_width + ',' +
				Math.round((event.pageY - event.data.offsetY) / (grid_height / scale_ratio)) * grid_height +
			')'
		);

		return false;
	},
	mouseup: function (event)
	{
		if (event.data.target.data('class') === 'AWS.VPC.Subnet')
		{
			event.data.target.find('.port').show();
		}

		// Selected
		if (
			event.pageX === event.data.originalPageX &&
			event.pageY === event.data.originalPageY
		)
		{
			MC.canvas.select( event.data.target.attr('id') );
		}
		else
		{
			var target = event.data.target,
				target_id = target.attr('id'),
				target_type = event.data.target_type,
				svg_canvas = $("#svg_canvas"),
				canvas_offset = svg_canvas.offset(),
				shadow_offset = Canvon(event.data.shadow[0]).offset(),
				layout_node_data = MC.canvas.data.get('layout.component.node'),
				layout_connection_data = MC.canvas.data.get('layout.connection'),
				node_type = target.data('class'),
				BEFORE_DROP_EVENT = $.Event("CANVAS_BEFORE_DROP"),
				scale_ratio = MC.canvas_property.SCALE_RATIO,
				component_size,
				match_place,
				coordinate,
				clone_node,
				parentGroup;

			if (target_type === 'node')
			{
				component_size = MC.canvas.COMPONENT_SIZE[ node_type ];

				coordinate = MC.canvas.pixelToGrid(
					shadow_offset.left - canvas_offset.left,
					shadow_offset.top - canvas_offset.top
				);

				match_place = MC.canvas.isMatchPlace(
					target_id,
					target_type,
					node_type,
					coordinate.x,
					coordinate.y,
					component_size[0],
					component_size[1]
				);

				parentGroup = MC.canvas.parentGroup(
					target_id,
					layout_node_data[target_id].type,
					coordinate.x,
					coordinate.y,
					coordinate.x + component_size[0],
					coordinate.y + component_size[1]
				);

				if (
					!BEFORE_DROP_EVENT.isDefaultPrevented() &&
					coordinate.x > 0 &&
					coordinate.y > 0 &&
					match_place.is_matched &&
					(
						svg_canvas.trigger(BEFORE_DROP_EVENT, {'src_node': target_id, 'tgt_parent': parentGroup ? parentGroup.id : null}) &&
						!BEFORE_DROP_EVENT.isDefaultPrevented()
					)
				)
				{
					MC.canvas.position(target[0], coordinate.x  * scale_ratio, coordinate.y * scale_ratio);

					MC.canvas.reConnect(target_id);

					MC.canvas.select(target_id);

					//after change node to another group, trigger event
					if (parentGroup)
					{
						svg_canvas.trigger("CANVAS_NODE_CHANGE_PARENT", {
							src_node: target_id,
							tgt_parent: parentGroup.id
						});
					}
				}
			}

			if (target_type === 'group')
			{
				var coordinate = MC.canvas.pixelToGrid(
						shadow_offset.left - canvas_offset.left,
						shadow_offset.top - canvas_offset.top
					),
					layout_group_data = MC.canvas.data.get('layout.component.group'),
					group_data = layout_group_data[ target_id ],
					group_coordinate = group_data.coordinate,
					group_size = group_data.size,
					group_padding = MC.canvas.GROUP_PADDING,
					child_stack = [],
					unique_stack = [],
					coordinate_fixed = false,
					match_place,
					areaChild,
					parentGroup,
					parent_data,
					parent_coordinate,
					parent_size,
					fixed_areaChild,
					group_offsetX,
					group_offsetY,
					matched_child,
					child_data,
					child_type;

				if (group_data.type === 'AWS.VPC.VPC')
				{
					if ( coordinate.y <= 3)
					{
						 coordinate.y = 3;
					}

					if (coordinate.x <= 5)
					{
						coordinate.x = 5;
					}
				}

				if (group_data.type !== 'AWS.VPC.VPC')
				{
					if (coordinate.y <= 2)
					{
						 coordinate.y = 2;
					}

					if (coordinate.x <= 2)
					{
						coordinate.x = 2;
					}
				}

				match_place = MC.canvas.isMatchPlace(
					target_id,
					target_type,
					node_type,
					coordinate.x,
					coordinate.y,
					group_size[0],
					group_size[1]
				);

				areaChild = MC.canvas.areaChild(
					target_id,
					coordinate.x,
					coordinate.y,
					coordinate.x + group_size[0],
					coordinate.y + group_size[1]
				);

				parentGroup = MC.canvas.parentGroup(
					target_id,
					group_data.type,
					coordinate.x,
					coordinate.y,
					coordinate.x + group_size[0],
					coordinate.y + group_size[1]
				);

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

				if (parentGroup)
				{
					parent_data = layout_group_data[ parentGroup.id ];
					parent_coordinate = parent_data.coordinate;
					parent_size = parent_data.size;

					if (parent_coordinate[0] + group_padding > coordinate.x)
					{
						coordinate.x = parent_coordinate[0] + group_padding;
						coordinate_fixed = true;
					}
					if (parent_coordinate[0] + parent_size[0] - group_padding < coordinate.x + group_size[0])
					{
						coordinate.x = parent_coordinate[0] + parent_size[0] - group_padding - group_size[0];
						coordinate_fixed = true;
					}
					if (parent_coordinate[1] + group_padding > coordinate.y)
					{
						coordinate.y = parent_coordinate[1] + group_padding;
						coordinate_fixed = true;
					}
					if (parent_coordinate[1] + parent_size[1] - group_padding < coordinate.y + group_size[1])
					{
						coordinate.y = parent_coordinate[1] + parent_size[1] - group_padding - group_size[1];
						coordinate_fixed = true;
					}

					if (coordinate_fixed)
					{
						fixed_areaChild = MC.canvas.areaChild(
							target_id,
							coordinate.x,
							coordinate.y,
							coordinate.x + group_size[0],
							coordinate.y + group_size[1]
						);
					}
				}

				group_offsetX = coordinate.x - group_coordinate[0];
				group_offsetY = coordinate.y - group_coordinate[1];

				if (
					(
						(
							coordinate_fixed &&
							event.data.groupChild.length === fixed_areaChild.length
						)
						||
						(
							!coordinate_fixed &&
							match_place.is_matched &&
							MC.canvas.isBlank('group', target_id, coordinate.x, coordinate.y, group_size[0], group_size[1]) &&
							event.data.groupChild.length === unique_stack.length
						)
					)
					&&
					(
						svg_canvas.trigger(BEFORE_DROP_EVENT, {'src_node': target_id, 'tgt_parent': parentGroup ? parentGroup.id : null}) &&
						!BEFORE_DROP_EVENT.isDefaultPrevented()
					)
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

							MC.canvas.reConnect(item.id);
						}

						if (child_type === 'group')
						{
							node_data = layout_group_data[ item.id ];

							MC.canvas.position(item, node_data.coordinate[0] + group_offsetX, node_data.coordinate[1] + group_offsetY);

							// Re-draw group connection
							if (node_data.type === 'AWS.VPC.Subnet')
							{
								MC.canvas.reConnect(item.id);
							}
						}
					});

					// Re-draw group connection
					if (group_data.type === 'AWS.VPC.Subnet')
					{
						MC.canvas.reConnect(target_id);
					}

					var group_left = coordinate.x,
						group_top = coordinate.y,
						group_width = group_size[0],
						group_height = group_size[1];

					if (group_data.type === 'AWS.VPC.VPC')
					{
						igw_gateway = $('.AWS-VPC-InternetGateway');
						vgw_gateway = $('.AWS-VPC-VPNGateway');

						if (igw_gateway[0])
						{
							igw_gateway_id = igw_gateway.attr('id');
							igw_gateway_data = layout_node_data[ igw_gateway_id ];
							igw_top = igw_gateway_data.coordinate[1] + group_offsetY;

							// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
							MC.canvas.position(igw_gateway[0],  (group_left - 4) * scale_ratio, igw_top * scale_ratio);

							MC.canvas.reConnect(igw_gateway_id);
						}

						if (vgw_gateway[0])
						{
							vgw_gateway_id = vgw_gateway.attr('id');
							vgw_gateway_data = layout_node_data[ vgw_gateway_id ];
							vgw_top = vgw_gateway_data.coordinate[1] + group_offsetY;

							// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
							MC.canvas.position(vgw_gateway[0],  (group_left + group_width - 4) * scale_ratio, vgw_top * scale_ratio);

							MC.canvas.reConnect(vgw_gateway_id);
						}
					}

					MC.canvas.select(target_id);

					//after change node to another group,trigger event
					if (parentGroup)
					{
						svg_canvas.trigger("CANVAS_GROUP_CHANGE_PARENT", {
							src_group: target_id,
							tgt_parent: parentGroup.id
						});
					}
				}
			}
		}

		$('.dropable-group').attr('class', function (index, key)
		{
			return key.replace('dropable-group ', '');
		});

		event.data.shadow.remove();

		event.data.canvas_body.removeClass('node-dragging');

		$(document.body).removeClass('disable-event');

		MC.canvas.volume.close();

		$(document).off({
			'mousemove': MC.canvas.event.mousemove,
			'mouseup': MC.canvas.event.mouseup
		});
	},
	gatewaymove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var gateway_top = Math.round((event.pageY - event.data.offsetY) / (MC.canvas.GRID_HEIGHT / MC.canvas_property.SCALE_RATIO)),
			vpc_coordinate = event.data.vpc_data.coordinate,
			vpc_size = event.data.vpc_data.size;

		// MC.canvas.COMPONENT_SIZE for AWS.VPC.InternetGateway and AWS.VPC.VPNGateway = 8
		if (gateway_top > vpc_coordinate[1] + vpc_size[1] - 8)
		{
			gateway_top = vpc_coordinate[1] + vpc_size[1] - 8;
		}

		if (gateway_top < vpc_coordinate[1])
		{
			gateway_top = vpc_coordinate[1];
		}

		if (event.data.node_type === 'AWS.VPC.InternetGateway')
		{
			event.data.shadow.attr('transform',
				'translate(' +
					// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
					(vpc_coordinate[0] - 4) * MC.canvas.GRID_WIDTH + ',' +
					gateway_top * MC.canvas.GRID_HEIGHT +
				')'
			);
		}

		if (event.data.node_type === 'AWS.VPC.VPNGateway')
		{
			event.data.shadow.attr('transform',
				'translate(' +
					// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
					(vpc_coordinate[0] + vpc_size[0] - 4) * MC.canvas.GRID_WIDTH + ',' +
					gateway_top * MC.canvas.GRID_HEIGHT +
				')'
			);
		}

		return false;
	},
	gatewayup: function (event)
	{
		var target = event.data.target,
			target_id = target.attr('id'),
			target_type = event.data.target_type,
			canvas_offset = $('#svg_canvas').offset(),
			shadow_offset = Canvon(event.data.shadow[0]).offset(),
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			layout_connection_data = MC.canvas.data.get('layout.connection'),
			node_type = target.data('class'),
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			coordinate;

		coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top);

		MC.canvas.position(target[0], coordinate.x  * scale_ratio, coordinate.y * scale_ratio);

		MC.canvas.reConnect(target_id);

		MC.canvas.select(target_id);

		$('.dropable-group').attr('class', function (index, key)
		{
			return key.replace('dropable-group ', '');
		});

		event.data.shadow.remove();

		$(document.body).removeClass('disable-event');

		$(document).off({
			'mousemove': MC.canvas.event.gatewaymove,
			'mouseup': MC.canvas.event.gatewayup
		});
	}
};

MC.canvas.event.drawConnection = {
	mousedown: function (event)
	{
		if (event.which === 1)
		{
			event.preventDefault();

			var svg_canvas = $('#svg_canvas'),
				canvas_offset = svg_canvas.offset(),
				target = $(this),
				target_offset = Canvon(this).offset(),
				parent = target.parent(),
				node_id = parent.attr('id'),
				node_type = parent.data('class'),
				layout_component_data = MC.canvas.data.get('layout.component'),
				layout_node_data = layout_component_data[ parent.data('type') ],
				node_connections = layout_node_data[ node_id ].connection,
				position = target.data('position'),
				port_type = target.data('type'),
				port_name = target.data('name'),
				connection_option = MC.canvas.CONNECTION_OPTION[ node_type ],
				CHECK_CONNECTABLE_EVENT = $.Event("CHECK_CONNECTABLE_EVENT"),
				offset = {},
				target_connection_option,
				target_data,
				is_connected;

			//calculate point of junction
			switch (position)
			{
				case 'left':
					offset.left = target_offset.left;
					offset.top  = target_offset.top  + 8;
					break;

				case 'right':
					offset.left = target_offset.left + 8;
					offset.top  = target_offset.top + 8;
					break;

				case 'top':
					offset.left = target_offset.left + 8;
					offset.top  = target_offset.top;
					break;

				case 'bottom':
					offset.left = target_offset.left + 8;
					offset.top  = target_offset.top + 8;
					break;
			}

			$(document.body).addClass('disable-event');

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

			// Highlight connectable port
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
												if (data.port === option.from)
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

								target_data = layout_component_data[ item.getAttribute('data-type') ][ item.id ];
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
												if (data.port === option.from)
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

							svg_canvas.trigger(CHECK_CONNECTABLE_EVENT, [node_id, value.from, item.id, value.to]);

							if (!CHECK_CONNECTABLE_EVENT.isDefaultPrevented())
							{
								$(this)
									.attr("class", function (index, key)
									{
										return "connectable " + key;
									})
									.find('.port-' + value.to).attr("class", function (index, key)
									{
										return "connectable-port " + key;
									});
							}
						});
					}
				});
			});
		}

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

	mouseup: function (event)
	{
		MC.paper.clear(MC.paper.drewLine);

		var match_node = MC.canvas.matchPoint(
				event.pageX - event.data.canvas_offset.left,
				event.pageY - event.data.canvas_offset.top
			),
			svg_canvas = $('#svg_canvas'),
			from_node = event.data.originalTarget,
			port_name = event.data.port_name,
			from_type = from_node.data('class'),
			CHECK_CONNECTABLE_EVENT = $.Event("CHECK_CONNECTABLE_EVENT"),
			layout_group_data,
			to_node,
			port_name,
			to_port_name,
			line_id,
			coordinate,
			group_coordinate,
			group_size;

		if (
			(
				from_type === 'AWS.VPC.RouteTable' || from_type === 'AWS.ELB'
			)
			&&
			!match_node
		)
		{
			layout_group_data = MC.canvas.data.get('layout.component.group');

			coordinate = MC.canvas.pixelToGrid(event.pageX - event.data.canvas_offset.left, event.pageY - event.data.canvas_offset.top);

			match_node = null;

			$.each(layout_group_data, function (key, item)
			{
				group_coordinate = item.coordinate;
				group_size = item.size;

				if (
					item.type === 'AWS.VPC.Subnet' &&
					group_coordinate &&

					// Specially extend subnet area
					group_coordinate[0] - 2 < coordinate.x &&
					group_coordinate[0] + group_size[0] + 2 > coordinate.x &&
					group_coordinate[1] < coordinate.y &&
					group_coordinate[1] + group_size[1] > coordinate.y
				)
				{
					match_node = document.getElementById( key );

					return false;
				}
			});
		}

		if (match_node)
		{
			to_node = $(match_node);
			to_port_name = to_node.find('.connectable-port').data('name');

			if (!from_node.is(to_node) && to_port_name !== undefined)
			{
				svg_canvas.trigger(CHECK_CONNECTABLE_EVENT, [from_node.attr('id'), port_name, to_node.attr('id'), to_port_name]);

				if (!CHECK_CONNECTABLE_EVENT.isDefaultPrevented())
				{
					line_id = MC.canvas.connect(from_node, port_name, to_node, to_port_name);

					//trigger event when connect two port
					svg_canvas.trigger("CANVAS_LINE_CREATE", line_id);
				}
			}
		}

		$('#svg_canvas .connectable').each(function (index, item)
		{
			Canvon(item).removeClass('connectable');
		});

		$('#svg_canvas .connectable-port').each(function (index, item)
		{
			Canvon(item).removeClass('connectable-port');
		});

		$(document.body).removeClass('disable-event');

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
		if (event.which === 1)
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
				default_height,
				platform,
				target_group_type;

			if (target.data('enable') === false)
			{
				return false;
			}

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
						'left': event.pageX - 50,
						'width': MC.canvas.COMPONENT_SIZE[ node_type ][0] * MC.canvas.GRID_WIDTH,
						'height': MC.canvas.COMPONENT_SIZE[ node_type ][1] * MC.canvas.GRID_HEIGHT
					})
					.show();

				if (target_component_type === 'node' && node_type !== 'AWS.EC2.EBS.Volume')
				{
					platform = MC.canvas.data.get('platform');
					target_group_type = MC.canvas.MATCH_PLACEMENT[ platform ][ node_type ];

					$.each(target_group_type, function (index, item)
					{
						$('.' + item.replace(/\./ig, '-')).attr('class', function (i, key)
						{
							return 'dropable-group ' + key;
						});
					});
				}
			}

			if (node_type === 'AWS.EC2.EBS.Volume')
			{
				$('.AWS-EC2-Instance').attr('class', function (index, key)
				{
					return 'attachable ' + key;
				});

				shadow.addClass('AWS-EC2-EBS-Volume');

				$(document).on({
					'mousemove': MC.canvas.volume.mousemove,
					'mouseup': MC.canvas.volume.mouseup
				}, {
					'target': target,
					'canvas_offset': $('#svg_canvas').offset(),
					'shadow': shadow
				});
			}
			else
			{

				$(document).on({
					'mousemove': MC.canvas.event.siderbarDrag.mousemove,
					'mouseup': MC.canvas.event.siderbarDrag.mouseup
				}, {
					'target': target,
					'shadow': shadow
				});
			}

			$(document.body).addClass('disable-event');

			$('#canvas_body').addClass('node-dragging');
		}

		MC.canvas.volume.close();
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
			target_type = target.data('component-type'),
			node_type = target.data('type'),
			canvas_offset = $('#svg_canvas').offset(),
			shadow_offset = event.data.shadow.position(),
			node_option = target.data('option'),
			coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top),
			component_size,
			match_place,
			default_group_size,
			new_node,
			vpc_id,
			vpc_data,
			vpc_coordinate;

		if (coordinate.x > 0 && coordinate.y > 0)
		{
			if (target_type === 'node')
			{
				component_size = MC.canvas.COMPONENT_SIZE[ node_type ];

				if (node_type === 'AWS.VPC.InternetGateway' || node_type === 'AWS.VPC.VPNGateway')
				{
					vpc_id = $('.AWS-VPC-VPC').attr('id');
					vpc_data = MC.canvas.data.get('layout.component.group.' + vpc_id);
					vpc_coordinate = vpc_data.coordinate;

					node_option.groupUId = vpc_id;

					if (coordinate.y > vpc_coordinate[1] + vpc_data.size[1] - component_size[1])
					{
						coordinate.y = vpc_coordinate[1] + vpc_data.size[1] - component_size[1];
					}
					if (coordinate.y < vpc_coordinate[1])
					{
						coordinate.y = vpc_coordinate[1];
					}

					if (node_type === 'AWS.VPC.InternetGateway')
					{
						coordinate.x = vpc_coordinate[0] - (component_size[1] / 2);
					}
					if (node_type === 'AWS.VPC.VPNGateway')
					{
						coordinate.x = vpc_coordinate[0] + vpc_data.size[0] - (component_size[1] / 2);
					}

					MC.canvas.add(node_type, node_option, coordinate);
				}
				else
				{
					match_place = MC.canvas.isMatchPlace(
						null,
						target_type,
						node_type,
						coordinate.x,
						coordinate.y,
						component_size[0],
						component_size[1]
					);

					if (match_place.is_matched)
					{
						node_option.groupUId = match_place.target;
						new_node = MC.canvas.add(node_type, node_option, coordinate);

						MC.canvas.select(new_node.id);
					}
				}
			}

			if (target_type === 'group')
			{
				default_group_size = MC.canvas.GROUP_DEFAULT_SIZE[ node_type ];
				match_place = MC.canvas.isMatchPlace(
					null,
					target_type,
					node_type,
					coordinate.x,
					coordinate.y,
					default_group_size[0],
					default_group_size[1]
				);

				if (match_place.is_matched)
				{
					node_option.groupUId = match_place.target;
					MC.canvas.add(node_type, node_option, coordinate);
				}
			}
		}

		$('.dropable-group').attr('class', function (index, key)
		{
			return key.replace('dropable-group ', '');
		});

		if (node_type === 'AWS.VPC.InternetGateway' || node_type === 'AWS.VPC.VPNGateway')
		{
			event.data.shadow.animate({
				'left': coordinate.x * MC.canvas.GRID_WIDTH + canvas_offset.left,
				'top': coordinate.y * MC.canvas.GRID_HEIGHT + canvas_offset.top,
				'opacity': 0
			}, function ()
			{
				event.data.shadow.remove();
			});
		}
		else
		{
			event.data.shadow.remove();
		}

		$(document.body).removeClass('disable-event');

		$('#canvas_body').removeClass('node-dragging');

		$(document).off({
			'mousemove': MC.canvas.event.mousemove,
			'mouseup': MC.canvas.event.mouseup
		});
	}
};

MC.canvas.event.groupResize = {
	mousedown: function (event)
	{
		if (event.which === 1)
		{
			event.preventDefault();
			event.stopPropagation();

			var target = event.target,
				parent = $(target.parentNode.parentNode),
				group = parent.find('.group'),
				group_offset = group[0].getBoundingClientRect(),
				canvas_offset = $('#svg_canvas').offset(),
				group_left = group_offset.left - canvas_offset.left,
				group_top = group_offset.top - canvas_offset.top,
				type = parent.data('class'),
				node_connections;

			if (type === 'AWS.VPC.Subnet')
			{
				parent.find('.port').hide();

				// Re-draw group connection
				node_connections = MC.canvas.data.get('layout.component.group.' + parent.attr('id') + '.connection') || {};

				$.each(node_connections, function (index, value)
				{
					line_layer.removeChild(document.getElementById( value.line ));
				});
			}

			$(document.body)
				.addClass('disable-event')
				.css('cursor', $(event.target).css('cursor'));

			$(document)
				.on({
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
					'group_border': parseInt(group.css('stroke-width'),10),
					'group_type': type,
					'parentGroup': MC.canvas.parentGroup(
						parent.attr('id'),
						parent.data('class'),
						Math.ceil(group_left / MC.canvas.GRID_WIDTH),
						Math.ceil(group_top / MC.canvas.GRID_HEIGHT),
						Math.ceil((group_offset.left + group_offset.width) / MC.canvas.GRID_WIDTH),
						Math.ceil((group_offset.top + group_offset.height) / MC.canvas.GRID_HEIGHT)
					),
					'group_port': type === 'AWS.VPC.Subnet' ? [parent.find('.port-subnet-assoc-in').first(), parent.find('.port-subnet-assoc-out').first()] : null
				});
		}
	},
	mousemove: function (event)
	{
		var direction = event.data.direction,
			type = event.data.group_type,
			group_border = event.data.group_border * 2,
			left = Math.round((event.pageX - event.data.originalLeft) / 10) * 10,
			group_min_padding = MC.canvas.GROUP_MIN_PADDING,
			max_left = event.data.originalWidth - group_min_padding,
			top = Math.round((event.pageY - event.data.originalTop) / 10) * 10,
			max_top = event.data.originalHeight - group_min_padding,
			label_offset = MC.canvas.GROUP_LABEL_COORDINATE[ type ],
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
		}

		if (prop.width && prop.width < group_min_padding)
		{
			prop.width = group_min_padding;
		}

		if (prop.height && prop.height < group_min_padding)
		{
			prop.height = group_min_padding;
		}

		event.data.target.attr(prop);

		if (prop.x)
		{
			event.data.group_title.attr('x', prop.x + label_offset[0]);
		}
		if (prop.y)
		{
			event.data.group_title.attr('y', prop.y + label_offset[1]);
		}

		return false;
	},
	mouseup: function (event)
	{
		var parent = event.data.parent,
			target = event.data.target,
			type = event.data.group_type,
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
			group_top = Math.ceil((parent_offset.top - canvas_offset.top + offsetY) / 10),
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			layout_group_data = MC.canvas.data.get('layout.component.group'),
			node_minX = [],
			node_minY = [],
			node_maxX = [],
			node_maxY = [],
			component_size = MC.canvas.COMPONENT_SIZE,
			group_padding = MC.canvas.GROUP_PADDING,
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			parentGroup = event.data.parentGroup,
			label_coordinate = MC.canvas.GROUP_LABEL_COORDINATE[ type ],
			layout_connection_data,
			parent_data,
			parent_size,
			parent_coordinate,
			item_data,
			item_coordinate,
			item_size,
			group_maxX,
			group_maxY,
			group_minX,
			group_minY,
			igw_gateway,
			igw_gateway_id,
			igw_gateway_data,
			igw_top,
			vgw_gateway,
			vgw_gateway_id,
			vgw_gateway_data,
			vgw_top,
			port_top,
			line_connection;

		//adjust group_left
		if (offsetX < 0)
		{
			//when resize by left,topleft, bottomleft
			group_left = Math.ceil((parent_offset.left - canvas_offset.left) / 10);
		}

		//adjust group_top
		if (direction === 'top' || direction === 'topleft' || direction === 'topright')
		{
			//when resize by left,topleft, bottomleft
			if (offsetY < 0)
			{
				//move up
				group_top = Math.ceil((parent_offset.top - canvas_offset.top) / 10);
			}
			else if (offsetY > 0)
			{
				//move down
				group_top = Math.ceil((parent_offset.top - canvas_offset.top + offsetY) / 10);
			}
		}

		$.each(event.data.group_child, function (index, item)
		{
			if (layout_node_data[ item.id ])
			{
				item_data = layout_node_data[ item.id ];
				item_size = component_size[ item_data.type ];
				item_coordinate = item_data.coordinate;

				node_minX.push(item_coordinate[0]);
				node_minY.push(item_coordinate[1]);
				node_maxX.push(item_coordinate[0] + item_size[0]);
				node_maxY.push(item_coordinate[1] + item_size[1]);
			}

			if (layout_group_data[ item.id ])
			{
				item_data = layout_group_data[ item.id ];
				item_size = item_data.size;
				item_coordinate = item_data.coordinate;

				node_minX.push(item_coordinate[0]);
				node_minY.push(item_coordinate[1]);
				node_maxX.push(item_coordinate[0] + item_size[0]);
				node_maxY.push(item_coordinate[1] + item_size[1]);
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

		if (parentGroup)
		{
			parent_data = layout_group_data[ parentGroup.id ];
			parent_size = parent_data.size;
			parent_coordinate = parent_data.coordinate;

			if (group_left < parent_coordinate[0])
			{
				group_width = group_left + group_width - parent_coordinate[0] - group_padding;
				group_left = parent_coordinate[0] + group_padding;
			}

			if (group_top < parent_coordinate[1])
			{
				group_height = group_top + group_height - parent_coordinate[1] - group_padding;
				group_top = parent_coordinate[1] + group_padding;
			}

			if (group_width + group_left > parent_coordinate[0] + parent_size[0] - group_padding)
			{
				group_width = parent_coordinate[0] + parent_size[0] - group_padding - group_left;
			}

			if (group_height + group_top > parent_coordinate[1] + parent_size[1] - group_padding)
			{
				group_height = parent_coordinate[1] + parent_size[1] - group_padding - group_top;
			}
		}

		// Top coordinate fix
		if (type === 'AWS.VPC.VPC')
		{
			if (group_top <= 3)
			{
				group_height = group_height + group_top - 3;
				group_top = 3;
			}

			if (group_left <= 5)
			{
				group_width = group_width + group_left - 5;
				group_left = 5;
			}
		}

		if (type !== 'AWS.VPC.VPC')
		{
			if (group_top <= 2)
			{
				group_height = group_height + group_top - 2;
				group_top = 2;
			}

			if (group_left <= 2)
			{
				group_width = group_width + group_left - 2;
				group_left = 2;
			}
		}

		if (
			group_width > group_padding &&
			group_height > group_padding &&

			event.data.group_child.length === MC.canvas.areaChild(
					group_id,
					group_left,
					group_top,
					group_left + group_width,
					group_top + group_height
				).length
		)
		{
			if (type === 'AWS.VPC.VPC')
			{
				layout_connection_data = MC.canvas.data.get('layout.connection');

				igw_gateway = $('.AWS-VPC-InternetGateway');
				vgw_gateway = $('.AWS-VPC-VPNGateway');

				if (igw_gateway[0])
				{
					igw_gateway_id = igw_gateway.attr('id');
					igw_gateway_data = layout_node_data[ igw_gateway_id ];
					igw_top = igw_gateway_data.coordinate[1];

					if (igw_top > group_top + group_height - 8)
					{
						igw_top = group_top + group_height - 8;
					}

					if (igw_top < group_top)
					{
						igw_top = group_top;
					}

					// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
					MC.canvas.position(igw_gateway[0],  (group_left - 4) * scale_ratio, igw_top * scale_ratio);

					MC.canvas.reConnect(igw_gateway_id);
				}

				if (vgw_gateway[0])
				{
					vgw_gateway_id = vgw_gateway.attr('id');
					vgw_gateway_data = layout_node_data[ vgw_gateway_id ];
					vgw_top = vgw_gateway_data.coordinate[1];

					if (vgw_top > group_top + group_height - 8)
					{
						vgw_top = group_top + group_height - 8;
					}

					if (vgw_top < group_top)
					{
						vgw_top = group_top;
					}

					// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
					MC.canvas.position(
						vgw_gateway[0],
						(group_left + group_width - 4) * scale_ratio,
						vgw_top * scale_ratio
					);

					MC.canvas.reConnect(vgw_gateway_id);
				}
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
				'x': label_coordinate[0],
				'y': label_coordinate[1]
			});

			MC.canvas.data.set('layout.component.group.' + group_id + '.coordinate', [group_left, group_top]);
			MC.canvas.data.set('layout.component.group.' + group_id + '.size', [group_width, group_height]);

			//update group-resizer
			MC.canvas.updateResizer(parent, group_width, group_height);
		}
		else
		{
			group_width = Math.ceil(event.data.originalWidth / 10);
			group_height = Math.ceil(event.data.originalHeight / 10);

			parent.attr('transform', event.data.originalTranslate);

			target.attr({
				'x': 0,
				'y': 0,
				'width': event.data.originalWidth,
				'height': event.data.originalHeight
			});

			group_title.attr({
				'x': label_coordinate[0],
				'y': label_coordinate[1]
			});
		}

		if (type === 'AWS.VPC.Subnet')
		{
			port_top = (group_height * MC.canvas.GRID_HEIGHT / 2) - 13;

			event.data.group_port[0].attr('transform', 'translate(-12, ' + port_top + ')').show();

			event.data.group_port[1].attr('transform', 'translate(' + (group_width * MC.canvas.GRID_WIDTH + 4) + ', ' + port_top + ')').show();

			// Re-draw group connection
			layout_connection_data = MC.canvas.data.get('layout.connection');
			node_connections = layout_group_data[ group_id ].connection || {};

			$.each(node_connections, function (index, value)
			{
				line_connection = layout_connection_data[ value.line ];

				MC.canvas.connect(
					$('#' + group_id), line_connection['target'][ group_id ],
					$('#' + value.target), line_connection['target'][ value.target ],
					{'line_uid': value['line']}
				);
			});
		}

		$(document.body)
			.removeClass('disable-event')
			.css('cursor', 'default');

		$(document)
			.off({
				'mousemove': MC.canvas.event.groupResize.mousemove,
				'mouseup': MC.canvas.event.groupResize.mouseup
			});
	}
};

MC.canvas.event.EIPstatus = function ()
{
	$("#svg_canvas").trigger("CANVAS_EIP_STATE_CHANGE", {
		id: this.parentNode.id,
		eip_state: this.getAttribute('data-eip-state')
	});

	return false;
};

MC.canvas.event.selectLine = function (event)
{
	if (event.which === 1)
	{
		event.preventDefault();
		event.stopPropagation();

		MC.canvas.event.clearSelected();

		MC.canvas.select(this.id);
	}
};

MC.canvas.event.selectNode = function (event)
{
	if (event.which === 1)
	{
		event.preventDefault();
		event.stopPropagation();

		MC.canvas.event.clearSelected();

		MC.canvas.select(this.id);
	}
};

MC.canvas.event.clearSelected = function ()
{
	$('#svg_canvas .selected').each(function (index, item)
	{
		Canvon(item).removeClass('selected');
	});

	MC.canvas_property.selected_node = [];
};

MC.canvas.event.keyEvent = function (event)
{
	var keyCode = event.which,
		nodeName = event.target.nodeName.toLowerCase(),
		canvas_status = MC.canvas.getState(),
		is_zoomed = $('#canvas_body').hasClass('canvas_zoomed'),
		selected_node;

	// Delete resource - [delete/backspace]
	if (
		(
			keyCode === 46 ||
			// For Mac
			keyCode === 8
		) &&
		canvas_status === 'stack' &&
		!is_zoomed &&
		MC.canvas_property.selected_node.length > 0 &&
		event.target === document.body
	)
	{
		$.each(MC.canvas_property.selected_node, function (index, id)
		{
			selected_node = $('#' + id);

			if (selected_node.data('class') !== 'AWS.VPC.VPC')
			{
				//trigger event when delete component
				$("#svg_canvas").trigger("CANVAS_OBJECT_DELETE", {
					'id': id,
					'type': selected_node.data('type')
				});
			}
		});
		MC.canvas_property.selected_node = [];

		return false;
	}

	// Disable backspace
	if (
		keyCode === 8 &&
		nodeName !== 'input' &&
		nodeName !== 'textarea'
	)
	{
		return false;
	}

	// Switch node - [tab]
	if (
		keyCode === 9 &&
		MC.canvas_property.selected_node.length === 1
	)
	{
		var selected_node = $('#' + MC.canvas_property.selected_node[ 0 ]),
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			current_node_id = MC.canvas_property.selected_node[ 0 ],
			node_stack = [],
			index = 0,
			current_index,
			next_node,
			clone_node;

		if (selected_node.data('type') !== 'node')
		{
			return false;
		}

		$.each(layout_node_data, function (key, value)
		{
			if (key === current_node_id)
			{
				current_index = index;
			}

			node_stack.push(key);

			index++;
		});

		if (current_index === node_stack.length - 1)
		{
			current_index = 0;
		}
		else
		{
			current_index++;
		}

		next_node = $('#' + node_stack[ current_index ]);

		MC.canvas.event.clearSelected();

		MC.canvas.select(next_node.attr('id'));

		return false;
	}

	// Move node - [up, down, left, right]
	if (
		$.inArray(keyCode, [37, 38, 39, 40]) > -1 &&
		canvas_status === 'stack' &&
		!is_zoomed &&
		MC.canvas_property.selected_node.length === 1
	)
	{
		var target = $('#' + MC.canvas_property.selected_node[ 0 ]),
			target_id = MC.canvas_property.selected_node[ 0 ],
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			layout_connection_data = MC.canvas.data.get('layout.connection'),
			node_data = layout_node_data[ target_id ],
			node_type = target.data('class'),
			target_type = target.data('type'),
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			component_size = MC.canvas.COMPONENT_SIZE[ node_type ],
			coordinate = {'x': node_data.coordinate[0], 'y': node_data.coordinate[1]},
			match_place;

		if (target.data('type') !== 'node')
		{
			return false;
		}

		if (keyCode === 38)
		{
			coordinate.y--;
		}

		if (keyCode === 40)
		{
			coordinate.y++;
		}

		if (node_type === 'AWS.VPC.InternetGateway' || node_type === 'AWS.VPC.VPNGateway')
		{
			match_place = {};

			vpc_id = $('.AWS-VPC-VPC').attr('id');
			vpc_data = MC.canvas.data.get('layout.component.group.' + vpc_id);
			vpc_coordinate = vpc_data.coordinate;

			match_place.is_matched =
				coordinate.y <= vpc_coordinate[1] + vpc_data.size[1] - component_size[1] &&
				coordinate.y >= vpc_coordinate[1];
		}
		else
		{
			if (keyCode === 37)
			{
				coordinate.x--;
			}

			if (keyCode === 39)
			{
				coordinate.x++;
			}

			match_place = MC.canvas.isMatchPlace(
				target_id,
				target_type,
				node_type,
				coordinate.x,
				coordinate.y,
				component_size[0],
				component_size[1]
			);
		}

		if (
			coordinate.x > 0 &&
			coordinate.y > 0 &&
			match_place.is_matched
		)
		{
			MC.canvas.position(target[0], coordinate.x  * scale_ratio, coordinate.y * scale_ratio);

			MC.canvas.reConnect(target_id);
		}

		return false;
	}

	// Save stack - [Ctrl + S]
	if (
		event.ctrlKey && keyCode === 83 &&
		canvas_status === 'stack' &&
		!is_zoomed
	)
	{
		$("#svg_canvas").trigger("CANVAS_SAVE");

		return false;
	}

	// ZoomIn - [Ctrl + +]
	if (
		event.ctrlKey && keyCode === 187
	)
	{
		MC.canvas.zoomIn();

		return false;
	}

	// ZoomIn - [Ctrl + -]
	if (
		event.ctrlKey && keyCode === 189
	)
	{
		MC.canvas.zoomOut();

		return false;
	}
};

MC.canvas.event.clickBlank = function (event)
{
	if (event.target.id === 'svg_canvas')
	{
		//dispatch event when click blank area in canvas
		$("#svg_canvas").trigger("CANVAS_NODE_SELECTED", "");
	}

	return true;
};