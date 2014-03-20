/*
#**********************************************************
#* MC.canvas
#* Description: Canvas logic core
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

// JSON data for current tab
MC.canvas_data = {};

// Variable for current tab
MC.canvas_property = {};

MC.canvas = {
	getState: function ()
	{
		//return Tabbar.current;
		//return MC.canvas_data.stack_id !== undefined ? 'app' : 'stack';
		var state = '';
		if ( Tabbar.current === 'new' || Tabbar.current === 'stack' ) {
			state = 'stack';
		}
		else if ( Tabbar.current === 'app' || Tabbar.current === 'appedit' || Tabbar.current === 'appview' ) {
			state = Tabbar.current;
		}
		return state;
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
			target.attr('style', '');
			Canvon(target).addClass('tooltip')
		}
		else
		{
			target.attr('display', 'none');
			target.attr('style', 'opacity:0');
			Canvon(target).removeClass('tooltip')
		}
	},

	update: function (id, type, key, value)
	{
		var target = $('#' + id + '_' + key);

		switch (type)
		{
			case 'text':
				if ( key.indexOf("name") !== -1 ) {
					value = MC.canvasName( value );
				}

				if (target.length === 0)
				{
					target = $('#' + id).find("." + key);
				}

				target.text(value);
				break;

			case 'image':
				//target.attr('href', value);
				target[ 0 ].setAttributeNS("http://www.w3.org/1999/xlink", "href", value);
				break;

			case 'eip':
				target.attr('data-eip-state', value);
				break;

			case 'id':
				target.attr('id', value);
				break;

			case 'color':
				target.attr('style', 'fill:' + value);
				break;

			case 'tooltip': //add tooltip
				Canvon( '#' + id + '_' + key )
					.addClass('tooltip')
					.data( 'tooltip', value )
					.attr( 'data-tooltip', value );
		}

		return true;
	},

	updateSG: function (uid)
	{
		var comp_data = MC.canvas.data.get('component.' + uid),
			comp_sg_list = [],
			SG_list = MC.canvas_property.sg_list,
			colors_label = [],
			i = 0;

		if (!comp_data) {
			console.error('[updateSGColorLabel] not found component: ' + uid);
		}

		switch (comp_data.type) {
			case 'AWS.EC2.Instance':
				eni_comp_data = MC.aws.eni.getInstanceDefaultENI(comp_data.uid)
				if (eni_comp_data) {
					$.each(eni_comp_data.resource.GroupSet, function(i, value)
					{
						comp_sg_list.push(value.GroupId);
					});
				} else {
					comp_sg_list = comp_data.resource.SecurityGroupId;
				}
				break;
			case 'AWS.ELB':
			case 'AWS.AutoScaling.LaunchConfiguration':
				comp_sg_list = comp_data.resource.SecurityGroups;
				break;
			case 'AWS.VPC.NetworkInterface':
				$.each(comp_data.resource.GroupSet, function(i, value)
				{
					comp_sg_list.push(value.GroupId);
				});
				break;
		}

		$.each(comp_sg_list, function(index, SG_uid)
		{
			SG_uid = SG_uid.substr(1, 36);
			$.each(SG_list, function(i, SG_data)
			{
				if (SG_data.uid === SG_uid) {
					colors_label.push({
						color: "#" + SG_data.color,
						name: SG_data.name
					});
					return false;
				}
			});
		});

		while (i < MC.canvas.SG_MAX_NUM) {
			if (i < colors_label.length && colors_label[i]) {
				MC.canvas.update(uid, "color", "sg-color-label" + (i + 1), colors_label[i].color);
				Canvon( "#" + uid + "_" + "sg-color-label" + (i + 1) ).addClass('tooltip').data( 'tooltip', colors_label[i].name ).attr( 'data-tooltip', colors_label[i].name );
			} else {
				MC.canvas.update(uid, "color", "sg-color-label" + (i + 1), "none");
				Canvon( "#" + uid + "_" + "sg-color-label" + (i + 1) ).addClass('tooltip').data( 'tooltip', "" ).attr( 'data-tooltip', "" );
				//show
				//hide
			}
			i++;
		}

	},

	updateInstanceState: function ()
	{
		var comp_data = MC.canvas.data.get('component'),
			instance_id,
			instance_data;

		$.each( comp_data, function(uid, comp)
		{
			if (comp.type === "AWS.EC2.Instance")
			{

				if (comp.number>1 && comp.index===0 && MC.aws && MC.aws.instance && MC.aws.instance.updateServerGroupState )
				{//update state of ServerGroup
					MC.aws.instance.updateServerGroupState(MC.canvas_data.id);
				}

				instance_id = comp.resource.InstanceId;

				if (instance_id){
				//instance in app
					instance_data = MC.data.resource_list[MC.canvas.data.get('region')][instance_id];
					if ( $('#' + uid + '_instance-state').length  === 1)
					{
						//remove deleted first
						Canvon( $('#' + uid ) ).removeClass('deleted');

						if ( instance_data )
						{//instance data exist
							$('#' + uid + '_instance-state').attr({
								'class': 'instance-state tooltip instance-state-' + instance_data.instanceState.name + ' instance-state-' + MC.canvas.getState(),
								'data-tooltip' : instance_data.instanceState.name
							});

							//add delete class to terminated instance
							if (instance_data.instanceState.name === 'terminated' ){
								Canvon( $('#' + uid ) ).addClass('deleted');
							}

						}
						else
						{//instance data not found, or instance terminated
							$('#' + uid + '_instance-state').attr({
								'class': 'instance-state tooltip instance-state-unknown instance-state-' + MC.canvas.getState(),
								'data-tooltip': 'unknown'
							});
							Canvon( $('#' + uid ) ).addClass('deleted');
						}
					}
					else
					{
						//no instance svg node found
					}
				}
				else
				{//instance in stack

				}
			}

		});
	},


	resize: function (target, type)
	{
		var canvas_size = MC.canvas.data.get("layout.size"),
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			key = target === 'width' ? 0 : 1,
			value,
			target_value;

		if (type === 'expand')
		{
			canvas_size[ key ] += 60;

			$('#svg_resizer_' + target + '_shrink').show();
		}

		if (type === 'shrink')
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

			screen_maxX = Math.max.apply(Math, node_maxX);
			screen_maxY = Math.max.apply(Math, node_maxY);

			target_value = target === 'width' ? screen_maxX : screen_maxY;

			if ((canvas_size[ key ] - 60) <= target_value)
			{
				canvas_size[ key ] = 20 + target_value;

				$('#svg_resizer_' + target + '_shrink').hide();
			}
			else
			{
				canvas_size[ key ] -= 60;

				if (canvas_size[ key ] === 20 + target_value)
				{
					$('#svg_resizer_' + target + '_shrink').hide();
				}
			}
		}

		$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1]);

		$('#svg_canvas').attr({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
		});

		$('#canvas_container, #canvas_body').css({
			'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
			'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
		});

		MC.canvas.data.set("layout.size", canvas_size);

		return true;
	},

	zoomIn: function ()
	{
		var canvas_size = MC.canvas.data.get('layout.size'),
			scale_ratio;

		if (MC.canvas_property.SCALE_RATIO > 1)
		{
			MC.canvas_property.SCALE_RATIO = (MC.canvas_property.SCALE_RATIO * 10 - 2) / 10;

			scale_ratio = MC.canvas_property.SCALE_RATIO;

			$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1]);

			$('#canvas_body').css('background-image', 'url("./assets/images/ide/grid_x' + scale_ratio + '.png")');

			$('#canvas_container, #canvas_body').css({
				'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
			});

			$('#svg_canvas').attr({
				'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
			});
		}

		if (scale_ratio === 1 && $('#canvas_body').hasClass('canvas_zoomed'))
		{
			$('#canvas_body')
				.removeClass('canvas_zoomed');
		}

		return true;
	},

	zoomOut: function ()
	{
		var canvas_size = MC.canvas.data.get('layout.size'),
			scale_ratio;

		if (MC.canvas_property.SCALE_RATIO < 1.6)
		{
			MC.canvas_property.SCALE_RATIO = (MC.canvas_property.SCALE_RATIO * 10 + 2) / 10;

			scale_ratio = MC.canvas_property.SCALE_RATIO;

			$('#svg_canvas')[0].setAttribute('viewBox', '0 0 ' + MC.canvas.GRID_WIDTH * canvas_size[0] + ' ' + MC.canvas.GRID_HEIGHT * canvas_size[1]);

			$('#canvas_body').css('background-image', 'url("./assets/images/ide/grid_x' + scale_ratio + '.png")');

			$('#canvas_container, #canvas_body').css({
				'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
			});

			$('#svg_canvas').attr({
				'width': canvas_size[0] * MC.canvas.GRID_WIDTH / scale_ratio,
				'height': canvas_size[1] * MC.canvas.GRID_HEIGHT / scale_ratio
			});
		}

		$('#canvas_body')
			.addClass('canvas_zoomed');

		return true;
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

	_bezier_q_corner: function(controlPoints)
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

				d = 'M ' + start0.x + ' ' + start0.y
					+ ' Q ' + c3.x + ' ' + c3.y
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
					d += ' ' + value.x + ' ' + value.y;
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
						var c3   = controlPoints[controlPoints.length - 3],
							end  = controlPoints[controlPoints.length - 2],
							end0 = controlPoints[controlPoints.length - 1];

						d += ' Q ' + c3.x + ' ' + c3.y + ' ' + end.x + ' ' + end.y + ' L ' + end0.x + ' ' + end0.y;
						return false;
					}
				}
				last_p = value;
			});
		}

		return d;
	},

	_bezier_qt_corner: function(controlPoints)
	{
		var d = '';

		if (controlPoints.length>=4)
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

	_adjustMidY: function (port_id, mid_y, point, sign)
	{
		switch (port_id)
		{
			case 'rtb-src':
				mid_y = point.y;
				break;

			case 'rtb-tgt':
			case 'elb-assoc':
			case 'elb-sg-in':
			case 'elb-sg-out':
				mid_y = point.y + 40 * sign;
				break;
		}
		return mid_y;
	},

	_adjustMidX: function (port_id, mid_x, point, sign)
	{
		switch (port_id)
		{
			case 'rtb-tgt': //for start
			case 'elb-assoc':
			case 'elb-sg-in':
			case 'elb-sg-out':
				if (point.connectionAngle === 0)
				{//left port
					mid_x = point.x + 4;
				}
				else if (point.connectionAngle === 180)
				{//right port
					mid_x = point.x - 4;
				}
				break;

			case 'rtb-src': //both top and bottom
				mid_x = point.x + 40 * sign;
				break;
		}
		return mid_x;
	},

	route: function (controlPoints, start0, end0, from_type, to_type, from_port_name, to_port_name)
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
			if ( (to_type === "AWS.VPC.RouteTable" || to_type === "AWS.ELB" ) && to_type !== from_type)
			{
				if (Math.abs(mid_y - end.y) > 5)
				{
					mid_y = MC.canvas._adjustMidY(to_port_name, mid_y, end, 1);
				}
			}
			else if ( (from_type === "AWS.VPC.RouteTable" || to_type === "AWS.ELB" ) && to_type !== from_type)
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
			if ( (to_type === 'AWS.VPC.RouteTable' || to_type === 'AWS.ELB' ) && to_type !== from_type)
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
			else if (from_type === 'AWS.ELB' && to_type !== from_type)
			{
				if (Math.abs(mid_x - end.x) > 5)
				{
					if (to_type === 'AWS.EC2.Instance' || to_type === 'AWS.VPC.Subnet' || to_type === 'AWS.AutoScaling.Group' || to_type === 'AWS.AutoScaling.LaunchConfiguration' )
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
			from_uid = from_node[0].id,
			to_uid = to_node[0].id,
			layout_component_data = MC.canvas_data.layout.component,
			layout_node_data = layout_component_data.node,
			from_node_type = from_node.data('type'),
			to_node_type = to_node.data('type'),
			from_data = layout_component_data[ from_node_type ][ from_uid ],
			to_data = layout_component_data[ to_node_type ][ to_uid ],
			from_type = from_data.type,
			to_type = to_data.type,
			layout_connection_data = MC.canvas_data.layout.connection,
			connection_option = MC.canvas.CONNECTION_OPTION[ from_type ][ to_type ],
			connection_target_data = {},
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			controlPoints = [],
			direction,
			layout_connection_data,
			line_data_target,
			from_port,
			to_port,
			from_port_offset,
			to_port_offset,
			from_node_connection_data,
			to_node_connection_data,
			is_connected,
			port_direction,
			startX,
			startY,
			endX,
			endY,
			start0,
			end0,
			dash_style,
			path,
			svg_line;

		if (connection_option)
		{
			if ($.type(connection_option) === 'array')
			{
				$.each(connection_option, function (index, item)
				{
					if (
						item.from === from_target_port &&
						item.to === to_target_port
					)
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
				var line_data = layout_connection_data[ value[ 'line' ] ];
				if (line_data)
				{
					line_data_target = line_data.target;
					if (
						line_data_target[ from_uid ] === from_target_port &&
						line_data_target[ to_uid ] === to_target_port
					)
					{
						is_connected = true;

						return false;
					}
				}
			});

			if (
				line_option ||
				is_connected === false
			)
			{
				// Special connection
				if (
					connection_option.direction
				)
				{
					direction = connection_option.direction;

					if (direction.from && direction.to)
					{
						if (from_node[0].getBoundingClientRect().left > to_node[0].getBoundingClientRect().left)
						{
							from_port = document.getElementById(from_uid + '_port-' + from_target_port + '-left');
							to_port = document.getElementById(to_uid + '_port-' + to_target_port + '-right');
						}
						else
						{
							from_port = document.getElementById(from_uid + '_port-' + from_target_port + '-right');
							to_port = document.getElementById(to_uid + '_port-' + to_target_port + '-left');
						}

						from_port_offset = from_port.getBoundingClientRect();
						to_port_offset = to_port.getBoundingClientRect();
					}
					else
					{
						if (direction.from)
						{
							to_port = document.getElementById(to_uid + '_port-' + to_target_port);
							to_port_offset = to_port.getBoundingClientRect();

							if (direction.from === 'vertical')
							{
								port_direction = to_port_offset.top > from_node[0].getBoundingClientRect().top ? 'bottom' : 'top';
							}

							if (direction.from === 'horizontal')
							{
								port_direction = to_port_offset.left > from_node[0].getBoundingClientRect().left ? 'right' : 'left';
							}

							from_port = document.getElementById(from_uid + '_port-' + from_target_port + '-' + port_direction);
							from_port_offset = from_port.getBoundingClientRect();
						}

						if (direction.to)
						{
							from_port = document.getElementById(from_uid + '_port-' + from_target_port);
							from_port_offset = from_port.getBoundingClientRect();

							if (direction.to === 'vertical')
							{
								port_direction = from_port_offset.top > to_node[0].getBoundingClientRect().top ? 'bottom' : 'top';
							}

							if (direction.to === 'horizontal')
							{
								port_direction = from_port_offset.left > to_node[0].getBoundingClientRect().left ? 'right' : 'left';
							}

							to_port = document.getElementById(to_uid + '_port-' + to_target_port + '-' + port_direction);
							to_port_offset = to_port.getBoundingClientRect();
						}
					}
				}
				else
				{
					from_port = document.getElementById(from_uid + '_port-' + from_target_port);
					from_port_offset = from_port.getBoundingClientRect();
					to_port = document.getElementById(to_uid + '_port-' + to_target_port);
					to_port_offset = to_port.getBoundingClientRect();
				}

				//patch startX for rtb-src port
				var offset_startX=0,
					offset_endX=0;
				if (from_type == 'AWS.VPC.RouteTable' && from_target_port == "rtb-src"){
					offset_startX+=1;
				}
				if (to_type == 'AWS.VPC.RouteTable' && to_target_port == "rtb-src"){
					offset_endX+=1;
				}

				startX = (offset_startX + from_port_offset.left - canvas_offset.left + (from_port_offset.width / 2)) * scale_ratio;
				startY = (1 + from_port_offset.top - canvas_offset.top + (from_port_offset.height / 2)) * scale_ratio;
				endX = (offset_endX + to_port_offset.left - canvas_offset.left + (to_port_offset.width / 2)) * scale_ratio;
				endY = (1 + to_port_offset.top - canvas_offset.top + (to_port_offset.height / 2)) * scale_ratio;

				//add by xjimmy
				start0 = {
					x : startX,
					y : startY,
					connectionAngle: from_port.getAttribute('data-angle') * 1
				};

				end0 = {
					x: endX,
					y: endY,
					connectionAngle: to_port.getAttribute('data-angle') * 1
				};

				//add pad to start0 and end0
				MC.canvas._addPad(start0, 1);
				MC.canvas._addPad(end0, 1);

				// straight line
				if (start0.x === end0.x || start0.y === end0.y)
				{
					path = 'M ' + start0.x + ' ' + start0.y + ' L ' + end0.x + ' ' + end0.y;
				}
				else
				{
					// fold line
					MC.canvas.route(controlPoints, start0, end0, from_type, to_type ,from_target_port, to_target_port);

					if (controlPoints.length > 0)
					{
						if (connection_option.type === 'sg')
						{
							switch (MC.canvas_property.LINE_STYLE)
							{
								case 0: //straight
									path = 'M ' + controlPoints[0].x + ' ' + controlPoints[0].y +
										' L ' + controlPoints[1].x + ' ' + controlPoints[1].y +
										' L ' + controlPoints[controlPoints.length-2].x + ' ' + controlPoints[controlPoints.length-2].y +
										' L ' + controlPoints[controlPoints.length-1].x + ' ' + controlPoints[controlPoints.length-1].y;
									break;

								case 1: //elbow
									path = MC.canvas._round_corner(controlPoints);
									break;

								case 2: //bezier-q
									path = MC.canvas._bezier_q_corner(controlPoints);
									break;

								case 3: //bezier-qt
									path = MC.canvas._bezier_qt_corner(controlPoints);
									break;
							}

						}
						else
						{
							path = MC.canvas._round_corner(controlPoints); //elbow
						}
					}
				}

				if (line_option && line_option.line_uid)
				{
					svg_line = document.getElementById( line_option.line_uid );
				}

				if (line_option && svg_line !== null)
				{
					$(svg_line).children().attr('d', path);
				}
				else
				{
					//line style
					MC.paper.start();

					MC.paper.path(path);
					MC.paper.path(path).attr('class','fill-line');

					if (connection_option.dash_line === true)
					{
						MC.paper.path(path).attr('class', 'dash-line');
					}

					svg_line = MC.paper.save();

					$('#line_layer').append(svg_line);

					$(svg_line).attr({
						'class': 'line line-' + connection_option.type,
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

						MC.canvas_data.layout.component[ from_node_type ][ from_uid ].connection = from_node_connection_data;
						MC.canvas_data.layout.component[ to_node_type ][ to_uid ].connection = to_node_connection_data;
					}

					layout_connection_data = MC.canvas_data.layout.connection[ svg_line.id ] || {};

					connection_target_data[ from_uid ] = from_target_port;
					connection_target_data[ to_uid ] = to_target_port;

					// layout_connection_data = {
					// 	'target': connection_target_data,
					// 	'auto': true,
					// 	'point': [],
					// 	'type': connection_option.type
					// };

					MC.canvas_data.layout.connection[ svg_line.id ] = {
						'target': connection_target_data,
						'auto': true,
						'point': [],
						'type': connection_option.type
					};
				}

				return svg_line.id;
			}
		}
	},

	createConnect: function (from_uid, from_target_port, to_uid, to_target_port)
	{
		var line_id = MC.guid(),

			COMPONENT_TYPE = MC.canvas.COMPONENT_TYPE,

			connection_target_data = {},

			layout_component_data = MC.canvas_data.layout.component,
			layout_node_data = layout_component_data.node,
			layout_connection_data = MC.canvas_data.layout.connection,

			from_node_class = layout_component_data.node[ from_uid ] ? 'node' : 'group',
			to_node_class = layout_component_data.node[ to_uid ] ? 'node' : 'group',

			from_data = layout_component_data[ from_node_class ][ from_uid ],
			to_data = layout_component_data[ to_node_class ][ to_uid ],

			from_type = from_data.type,
			to_type = to_data.type,

			connection_option = MC.canvas.CONNECTION_OPTION[ from_type ][ to_type ],

			from_node_connection_data = from_data.connection || [],
			to_node_connection_data = to_data.connection || [];

		if (connection_option)
		{
			if ($.type(connection_option) === 'array')
			{
				$.each(connection_option, function (index, item)
				{
					if (
						item.from === from_target_port &&
						item.to === to_target_port
					)
					{
						connection_option = item;
					}
				});
			}
		}

		$.each(from_node_connection_data, function (key, value)
		{
			var line_data = layout_connection_data[ value[ 'line' ] ];

			if (line_data)
			{
				line_data_target = line_data.target;
				if (
					line_data_target[ from_uid ] === from_target_port &&
					line_data_target[ to_uid ] === to_target_port
				)
				{
					is_connected = true;

					return false;
				}
			}
		});

		from_node_connection_data.push({
			'target': to_uid,
			'port': from_target_port,
			'line': line_id
		});

		to_node_connection_data.push({
			'target': from_uid,
			'port': to_target_port,
			'line': line_id
		});

		MC.canvas_data.layout.component[ from_node_class ][ from_uid ].connection = from_node_connection_data;
		MC.canvas_data.layout.component[ to_node_class ][ to_uid ].connection = to_node_connection_data;

		connection_target_data[ from_uid ] = from_target_port;
		connection_target_data[ to_uid ] = to_target_port;

		MC.canvas_data.layout.connection[ line_id ] = {
			'target': connection_target_data,
			'auto': true,
			'point': [],
			'type': connection_option.type
		};

		return true;
	},

	reConnect: function (node_id)
	{
		var node = $('#' + node_id),
			node_connections = MC.canvas_data.layout.component[ node.data('type') ][ node_id ].connection || {},
			layout_connection_data = MC.canvas_data.layout.connection,
			line_target;

		$.each(node_connections, function (index, value)
		{
			try
			{
				line_target = layout_connection_data[ value.line ][ 'target' ];

				MC.canvas.connect(
					// From
					node_id, line_target[ node_id ],
					// To
					value.target, line_target[ value.target ],
					// Line
					{'line_uid': value['line']}
				);
			}
			catch(error)
			{
				console.error('[MC.canvas.reConnect] create connection error');
			}
		});

		return true;
	},

	select: function (id)
	{
		var target = $('#' + id),
			target_type = target.data('type'),
			svg_canvas = $("#svg_canvas"),
			clone_node,
			node_connections,
			layout_connection_data;

		Canvon(target).addClass('selected');

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

			node_connections = MC.canvas_data.layout.component.node[ id ].connection;
			layout_connection_data = MC.canvas_data.layout.connection;

			$.each(node_connections, function (index, item)
			{
				Canvon('#' + item.line + ', #' + item.target + '_port-' + item.port).addClass('view-show');
			});

			Canvon(clone.find('.port')).addClass('view-show');
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

		var transformVal = node.transform.baseVal,
			translateVal;

		MC.canvas_data.layout.component[ node.getAttribute('data-type') ][ node.id ].coordinate = [x, y];

		if (transformVal.numberOfItems === 1)
		{
			/* MC.canvas.GRID_WIDTH = 10 */
			/* MC.canvas.GRID_HEIGHT = 10 */
			transformVal.getItem(0).setTranslate(x * 10, y * 10);
		}
		else
		{
			/* MC.canvas.GRID_WIDTH = 10 */
			/* MC.canvas.GRID_HEIGHT = 10 */
			translateVal = node.ownerSVGElement.createSVGTransform();

			translateVal.setTranslate(x * 10, y * 10);

			transformVal.appendItem(translateVal);
		}

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
			var	layout_component_data = MC.canvas.data.get('layout.component'),
				layout_connection_data = MC.canvas.data.get('layout.connection'),
				line_layer = document.getElementById('line_layer'),
				connections = layout_component_data.node[ node_id ].connection,
				target_node_type,
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

				target_node_type = $('#' + connected_node).data('type');
				connected_data = layout_component_data[ target_node_type ][ connected_node ].connection;

				$.each(connected_data, function (i, option)
				{
					if (option.line !== value.line && option.target !== node_id)
					{
						new_connection_data.push(option);
					}
				});

				MC.canvas.data.set('layout.component.' + target_node_type + '.' + connected_node + '.connection', new_connection_data);
				MC.canvas.data.delete('layout.connection.' + value.line);
			});

			MC.canvas.data.delete('layout.component.' + target_type + '.' + node_id);
			//MC.canvas.data.delete('component.' + node_id);
		}

		if (target_type === 'group')
		{
			var group_child = MC.canvas.groupChild(node),
				group_data = MC.canvas.data.get('layout.component.group.' + node_id);

			if (
				(
					node_type === 'AWS.VPC.Subnet' ||
					(
						node_type === 'AWS.AutoScaling.Group' &&
						group_data.originalId !== ""
					)
				)
				&& group_data.connection.length > 0
			)
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
		var scale_ratio = MC.canvas_property.SCALE_RATIO;

		return {
			'x': Math.ceil(x * scale_ratio / MC.canvas.GRID_WIDTH),
			'y': Math.ceil(y * scale_ratio / MC.canvas.GRID_HEIGHT)
		};
	},

	matchPoint: function (x, y)
	{
		var children = MC.canvas_data.layout.component.node,
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
				node_coordinate[0] <= coordinate.x &&
				node_coordinate[0] + component_size[0] >= coordinate.x &&
				node_coordinate[1] <= coordinate.y &&
				node_coordinate[1] + component_size[1] >= coordinate.y
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
		var layout_group_data = MC.canvas_data.layout.component.group,
			group_stack = [
				document.getElementById('asg_layer').childNodes,
				document.getElementById('subnet_layer').childNodes,
				document.getElementById('az_layer').childNodes,
				document.getElementById('vpc_layer').childNodes
			],
			points = [
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
			canvas_size = MC.canvas_data.layout.size,
			match_option = MC.canvas.MATCH_PLACEMENT[ MC.canvas_data.platform ][ node_type ],
			ignore_stack = [],
			match = [],
			result = {},
			is_matched = false,
			match_status,
			match_target,
			group_data,
			group_child,
			coordinate,
			size,

			// For specially fast iteration algorithm
			point = points.length,
			layer,
			i;

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

		while ( point-- )
		{
			layer = group_stack.length;

			while ( layer-- )
			{
				if ( group_stack[ layer ] )
				{
					match_status = {};
					i = group_stack[ layer ].length;

					while ( i-- )
					{
						id = group_stack[ layer ][ i ].id;
						group_data = layout_group_data[ id ];
						coordinate = group_data.coordinate;
						size = group_data.size;

						if (
							$.inArray(id, ignore_stack) === -1 &&
							points[ point ].x > coordinate[0] &&
							points[ point ].x < coordinate[0] + size[0] &&
							points[ point ].y > coordinate[1] &&
							points[ point ].y < coordinate[1] + size[1]
						)
						{
							match_status['is_matched'] = $.inArray(group_data.type, match_option) > -1;
							match_status['target'] = id;
							match_target = id;
						}
					}

					if (!$.isEmptyObject(match_status))
					{
						match[ point ] = match_status;
					}
				}
			}
		}

		is_matched =
			match[0] &&
			match[1] &&
			match[2] &&
			match[3] &&

			match[0].is_matched &&
			match[1].is_matched &&
			match[2].is_matched &&
			match[3].is_matched &&

			match[0].target === match[1].target &&
			match[0].target === match[2].target &&
			match[0].target === match[3].target &&

			// canvas right offset = 3
			x + width < canvas_size[0] - 3 &&
			y + height < canvas_size[1] - 3;

		if (
			!is_matched &&
			$.inArray('Canvas', match_option) > -1 &&
			!match[0] &&
			!match[1] &&
			!match[2] &&
			!match[3] &&

			// canvas right offset = 3
			x + width < canvas_size[0] - 3 &&
			y + height < canvas_size[1] - 3
		)
		{
			is_matched = true;
			match_target = 'Canvas';
		}

		return {
			'is_matched': is_matched,
			'target': is_matched ? match_target : null
		};
	},

	isBlank: function (type, target_id, target_type, start_x, start_y, width, height)
	{
		var children = MC.canvas_data.layout.component[ type ],
			group_weight = MC.canvas.GROUP_WEIGHT[ target_type ],
			isBlank = true,
			end_x,
			end_y,
			coordinate,
			size;

		if (type === 'group')
		{
			end_x = start_x + width;
			end_y = start_y + height;

			$.each(children, function (key, item)
			{
				coordinate = item.coordinate;
				size = item.size;

				if (
					key !== target_id &&
					item.type === target_type &&
					coordinate[0] < end_x &&
					coordinate[0] + size[0] > start_x &&
					coordinate[1] < end_y &&
					coordinate[1] + size[1] > start_y
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
		var groups = MC.canvas_data.layout.component.group,
			group_parent_type = MC.canvas.MATCH_PLACEMENT[ MC.canvas_data.platform ][ node_type ],
			matched;

		$.each(groups, function (key, item)
		{
			coordinate = item.coordinate;
			size = item.size;

			if (
				node_id !== key &&
				$.inArray(item.type, group_parent_type) > -1 &&
				(
					coordinate[0] <= start_x &&
					coordinate[0] + size[0] >= start_x
				)
				&&
				(
					coordinate[1] <= start_y &&
					coordinate[1] + size[1] >= start_y
				)
			)
			{
				matched = document.getElementById( key );

				//return false;
			}
		});

		return matched;
	},

	areaChild: function (node_id, node_type, start_x, start_y, end_x, end_y)
	{
		var children = MC.canvas_data.layout.component.node,
			groups = MC.canvas_data.layout.component.group,
			group_data = groups[ node_id ],
			group_weight = MC.canvas.GROUP_WEIGHT[ node_type ],
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
				(
					$.inArray(item.type, group_weight) > -1 ||
					item.type === node_type
				) &&
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
		var group_data = MC.canvas_data.layout.component.group[ group_node.id ],
			coordinate = group_data.coordinate;

		return MC.canvas.areaChild(
			group_node.id,
			group_data.type,
			coordinate[0],
			coordinate[1],
			coordinate[0] + group_data.size[0],
			coordinate[1] + group_data.size[1]
		);
	},

	lineTarget: function (line_id)
	{
		var data = MC.canvas_data.layout.connection[ line_id ].target,
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
			has_default_kp = false,
			connection_target_id,
			tmp,
			sg_uids;

		MC.paper = Canvon('#svg_canvas');

		MC.canvas_property = $.extend(true, {}, MC.canvas.STACK_PROPERTY);

		components = MC.canvas.data.get("component");

		var dict_sg = {}
		var dict_sg_elb = {}


		//patch: for duplicate sg name of elb (1)
		$.each(components, function (key, value)
		{
			try
			{
				if (value.type === "AWS.EC2.SecurityGroup")
				{
					if (value.resource.GroupDescription === "Automatically created SG for load-balancer")
					{
						if (!dict_sg[ value.name ])
						{
							dict_sg[ value.name ] = [];
						}
						dict_sg[ value.name ].push( value.uid );
					}
				}
				if (value.type === "AWS.ELB")
				{
					$.each(value.resource.SecurityGroups, function(sg_key, value_ref)
					{
						if (!dict_sg_elb[MC.extractID(value_ref)])
						{
							dict_sg_elb[MC.extractID(value_ref)]=[];
						}
						dict_sg_elb[MC.extractID(value_ref)].push(value.name);
					});
				}
			}
			catch(error)
			{
				console.warn("find duplicate sg name of elb failed");
				return true;
			}
		});
		//patch: for duplicate sg name of elb (2)
		$.each( dict_sg, function (elb_name, sg_uids)
		{
			try
			{
				if (sg_uids && sg_uids.length>1)
				{//duplicate
					$.each( sg_uids, function(k,sg_uid)
					{
						if (!dict_sg_elb[sg_uid])
						{//no reference
							console.warn("sg_uid " + sg_uid +" has no reference" );
							//delete sg rule
							MC.aws.sg.deleteRefInAllComp(sg_uid);
							//delete sg component
							delete components[sg_uid];
						}
					});
				}
			}
			catch(error)
			{
				console.warn("remove duplicate sg failed");
				return true;
			}
		});

		//patch 20140302: delete VPN when CGW component is not exist
		$.each(components, function (key, value)
		{
			try
			{
				if (value.type === "AWS.VPC.VPNConnection")
				{
					var cgwUid = MC.extractID(value.resource.CustomerGatewayId);
					if ( ! components[ cgwUid ] )
					{
						//delete vpn when cgw component not exist
						delete components[value.uid];
					}
				}
			}
			catch(error)
			{
				console.warn("error occur when delete vpn when cgw component not exist");
				return true;
			}
		});

		//patch 20140310: fix AZ of volume
		$.each(components, function (key, value)
		{
			try
			{
				if (value.type === "AWS.EC2.EBS.Volume")
				{
					var instanceId = MC.extractID(value.resource.AttachmentSet.InstanceId);
					if ( components[ instanceId ] )
					{
						//delete vpn when cgw component not exist
						if (value.resource.AvailabilityZone != components[ instanceId ].resource.Placement.AvailabilityZone )
						{
							value.resource.AvailabilityZone = components[ instanceId ].resource.Placement.AvailabilityZone;
							console.warn("patch - AZ of volume " + value.name + "(" + value.uid + ") had been fixed" );
						}
					}
					else
					{
						console.warn("volume " + value.name + "(" + value.uid + ") didn't attached to an instance" );
					}
				}
			}
			catch(error)
			{
				console.warn("error occur when patch AZ of volume");
				return true;
			}
		});
		//patch 20140310: fix xvda for windows ami
		$.each(components, function (key, value)
		{
			try
			{
				if (value.type === "AWS.EC2.Instance")
				{
					var volumeList    = value.resource.BlockDeviceMapping,
						volIdxvda     = null,
						maxDeviceName = null;

					$.each(volumeList, function (_key, _value)
					{
						if ($.type(_value) !== "string")
						{
							return true;
						}
						var volId = _value.substr(1),
							volComp = components[volId];

						if (volComp === null)
						{
							return true;
						}

						if ( volComp.resource.AttachmentSet.Device === "xvda" )
						{
							volIdxvda =  volId;
						}
						if ( maxDeviceName === null || maxDeviceName < volComp.resource.AttachmentSet.Device )
						{
							maxDeviceName = volComp.resource.AttachmentSet.Device;
						}

					});
					if (volIdxvda && maxDeviceName )
					{
						var oldName = components[volIdxvda].name,
							lastDevice = maxDeviceName.substr(-1),
							new_volume_name = maxDeviceName.substr(0,maxDeviceName.length-1) + String.fromCharCode((lastDevice.charCodeAt(0)+1));

						components[volIdxvda].resource.AttachmentSet.Device = new_volume_name;
						components[volIdxvda].name = components[volIdxvda].name.replace(oldName,new_volume_name);
						components[volIdxvda].serverGroupName = components[volIdxvda].serverGroupName.replace(oldName,new_volume_name);
						console.warn("patch - found xvda, change deviceName to " + new_volume_name );
					}
				}
			}
			catch(error)
			{
				console.warn("error occur when patch AZ of volume");
				return true;
			}
		});


		//patch 20140312: append root device for old stack/app
		$.each(components, function (key, value)
		{
			try
			{
				if (value.type === "AWS.EC2.Instance")
				{
					var volumeList    = value.resource.BlockDeviceMapping,
						root_device   = null;
					root_device = MC.aws.ami.getRootDevice(value.resource.ImageId);
					if (  (volumeList.length === 0 || $.type(volumeList[0]) === "string") && root_device !== null )
					{//need append root device
						value.resource.BlockDeviceMapping.splice(0,0,root_device);
						console.info("append root device to instance "+key);
					}
				}
				else if (value.type === "AWS.AutoScaling.LaunchConfiguration")
				{
					var volumeList    = value.resource.BlockDeviceMapping,
						root_device   = null;
					root_device = MC.aws.ami.getRootDevice(value.resource.ImageId);
					if (  (volumeList.length === 0 || volumeList[0].DeviceName !== "/dev/sda1") && root_device !== null )
					{//need append root device
						delete root_device.Ebs.Iops;
						value.resource.BlockDeviceMapping.splice(0,0,root_device);
						console.info("append root device to instance "+key);
					}
				}
			}
			catch(error)
			{
				console.warn("error occur when append root device to component " + key);
				return true;
			}
		});

		//patch 20140320: truncate long ELB name
		$.each(components, function (key, value)
		{
			try
			{
				if (value.type === "AWS.ELB")
				{
					if (value.name.length>17)
					{
						var elbName = value.name.substr(0,17);
						value.name = elbName;
						value.resource.LoadBalancerName = elbName;
						console.info("truncate long ELB name");
					}
				}
			}
			catch(error)
			{
				console.warn("error occur when fix long name of ELB " + key);
				return true;
			}
		});

		$.each(components, function (key, value)
		{
			try
			{
				if (value.type === 'AWS.EC2.KeyPair')
				{

					if (value.name === "$key-default$" || value.name === "key-default" || value.name === "kp-default" || value.name === "default-kp" )
					{
						value.name = "DefaultKP";
						value.resource.KeyName = value.name;
					}
					if (value.resource.KeyName === "")
					{
						value.resource.KeyName = value.name;
					}
					if (value.name === "DefaultKP")
					{
						has_default_kp=true;
					}
					MC.canvas_property.kp_list[ value.name ] = value.uid;
				}
				if (value.type === "AWS.EC2.SecurityGroup")
				{
					tmp = {};

					if (value.name === "$sg-default$" || value.name === "sg-default" || value.name === "default-sg" )
					{
						value.name = "DefaultSG";
						value.resource.GroupDescription = 'Stack Default Security Group';
						value.resource.GroupName = value.name;
					}

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
							});
						}
						if (v.type === "AWS.AutoScaling.LaunchConfiguration")
						{
							sg_uids = v.resource.SecurityGroups;
							$.each(sg_uids, function (id, sg_ref)
							{
								if (sg_ref.split('.')[0].slice(1) === tmp.uid)
								{
									tmp.member.push(v.uid);
								}
							});
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

				//patch: for assoc exist, but subnet not exist
				if (value.type === "AWS.VPC.NetworkAcl")
				{
					assoc = value.resource.AssociationSet;
					valid_assoc = [];
					if (assoc && assoc.length>0)
					{
						$.each(assoc, function (idx, item)
						{
							subnetId=MC.extractID(item.SubnetId);
							if (components[subnetId])
							{
								valid_assoc.push(item);
							}
						});
						if (value.resource.AssociationSet.length != valid_assoc.length)
						{
							value.resource.AssociationSet = valid_assoc;
							console.log("patch for NetworkAcl");
						}
					}
				}
			}
			catch(error)
			{
				console.error('[MC.canvas.layout.init]init component error:');

				return true;//continue
			}
		});

		if (!has_default_kp)
		{//add DefaultKP
			var kp = $.extend(true, {}, MC.canvas.KP_JSON.data),
				uid = MC.guid();
			kp.uid = uid;
			MC.canvas_property.kp_list[kp.name] = kp.uid;
			MC.canvas.data.get("component")[kp.uid] = kp;
		}

		$.each(MC.canvas_property.sg_list, function (key, value)
		{
			try
			{
				if (value.name === "DefaultSG" && key !== 0)
				{
					//move DefaultSG to the first one
					default_sg = MC.canvas_property.sg_list.splice(key, 1);
					MC.canvas_property.sg_list.unshift(default_sg[0]);
					return false;
				}
			}
			catch(error)
			{
				console.error('[MC.canvas.layout.init]init sg_list error:');

				return true;//continue
			}
		});

		//init sg color
		$.each(MC.canvas_property.sg_list, function (key, value)
		{
			try
			{
				if (key < MC.canvas.SG_COLORS.length)
				{//use color table
					MC.canvas_property.sg_list[key].color = MC.canvas.SG_COLORS[key];
				}
				else
				{//random color
					var rand = Math.floor(Math.random() * 0xFFFFFF).toString(16);
					for (; rand.length < 6;)
					{
						rand = '0' + rand;
					}
					MC.canvas_property.sg_list[key].color = rand;
				}
			}
			catch(error)
			{
				console.error('[MC.canvas.layout.init]init sg color error:');

				return true;//continue
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
				try
				{
					data.connection = [];
					MC.canvas.add(id);
				}
				catch(error)
				{
					console.error('[MC.canvas.layout.init]add node error');

					return true;//continue
				}
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
				try
				{
					if(data.connection){
						data.connection = [];
					}
					MC.canvas.add(id);
				}
				catch(error)
				{
					console.error('[MC.canvas.layout.init]add group error');

					return true;//continue
				}
			});
		}
		else
		{
			layout_data.component.group = {};
		}

		layout_data.connection = {};

		//store json to original_json
		MC.canvas_property.original_json = JSON.stringify(MC.canvas_data);

		return true;
	},

	create: function (option)
	{
		var uid = MC.guid(),
			canvas_size,
			data,
			vpc_group,
			node_rt,
			main_asso,
			sg_uid,
			acl,
			sg,
			kp,
			tmp;

		MC.paper = Canvon('#svg_canvas');

		//clone MC.canvas.STACK_JSON to MC.canvas_data
		MC.canvas_data = $.extend(true, {}, MC.canvas.STACK_JSON);

		//clone MC.canvas.STACK_PROPERTY to MC.canvas_property
		MC.canvas_property = $.extend(true, {}, MC.canvas.STACK_PROPERTY);

		canvas_size = MC.canvas.data.get('layout.size');

		data = MC.canvas.data.get('component');

		//set region and platform
		if (option.id)
		{
			MC.canvas_data.id = option.id; //tab_id (temp for new stack)
		}
		MC.canvas_data.name = option.name;
		MC.canvas_data.region = option.region;
		MC.canvas_data.platform = option.platform;

		kp = $.extend(true, {}, MC.canvas.KP_JSON.data);
		kp.uid = uid;
		MC.canvas_property.kp_list[kp.name] = kp.uid;

		sg_uid = MC.guid();
		sg = $.extend(true, {}, MC.canvas.SG_JSON.data);
		sg.uid = sg_uid;
		tmp = {};
		tmp.uid = sg.uid;
		tmp.name = sg.name;
		tmp.color = MC.canvas.SG_COLORS[0];
		tmp.member = [];
		MC.canvas_property.sg_list.push(tmp);

		data[kp.uid] = kp;
		data[sg.uid] = sg;
		MC.canvas.data.set('component', data);

		if (option.platform === MC.canvas.PLATFORM_TYPE.CUSTOM_VPC || option.platform === MC.canvas.PLATFORM_TYPE.EC2_VPC)
		{
			//has vpc (create vpc, az, and subnet by default)
			vpc_group = MC.canvas.add('AWS.VPC.VPC', {
				'name': 'vpc'
			}, {
				'x': 5,
				'y': 3
			});

			node_rt = MC.canvas.add('AWS.VPC.RouteTable', {
				'name': 'RT-0',
				'groupUId': vpc_group.id,
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
		var data = $.extend(true, {}, MC.canvas_data);

		if (data.layout.component.node)
		{
			$.each(data.layout.component.node, function (id, data)
			{
				if  (data.connection)
				{
					data.connection = [];
				}
			});
		}

		if (data.layout.component.group)
		{
			$.each(data.layout.component.group, function (id, data)
			{
				if  (data.connection)
				{
					data.connection = [];
				}
			});
		}

		delete data.layout.connection;

		return data;
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
				node_uid    = node.id.replace(/_[0-9]*$/ig, ''),
				target_data = target.hasClass('asgList-item') ? MC.data.resource_list[ MC.canvas_data.region ][ node_uid ] : component_data[ node_uid ],
				data = {'list': []},
				coordinate = {},
				is_deleted = '',
				node_volume_data,
				volume_id,
				width,
				height,
				target_offset,
				target_width,
				target_height;

			canvas_container.append('<div id="volume-bubble-box"><div class="arrow"></div><div id="volume-bubble-content"></div></div>');
			bubble_box = $('#volume-bubble-box');

			if (target_data && target_data.type === 'AWS.AutoScaling.LaunchConfiguration')
			{

				var root_devName  = '',
					volume_len    = 0,
					ami_info      = null;

				ami_info = MC.data.dict_ami[target_data.resource.ImageId];
				if (ami_info)
				{
					root_devName = ami_info.rootDeviceName;
				}

				node_volume_data = target_data.resource.BlockDeviceMapping;

				$.each(node_volume_data, function (index, item)
				{
					volume_id = node_uid + '_volume_' + item.DeviceName.replace('/dev/', '');
					if (item.DeviceName !== root_devName)
					{
						data.list.push({
							'volume_id': volume_id,
							'name': item.DeviceName,
							'size': item.Ebs.VolumeSize,
							'snapshotId': item.Ebs.SnapshotId,
							'json': JSON.stringify({
								'instance_id': node_uid,
								'id': volume_id,
								'name': item.DeviceName,
								'snapshotId': item.Ebs.SnapshotId,
								'volumeSize': item.Ebs.VolumeSize
							})
						});
						volume_len++;
					}
				});
			}
			else
			{
				node_volume_data = MC.canvas.getState() === 'app' ?
					MC.forge.stack.getVolumeList(node_uid) :
					target_data.resource.BlockDeviceMapping;

				if ( target.hasClass('asgList-item') )
				{

					var instance_data = MC.data.resource_list[MC.canvas_data.region][node_uid],
						root_devName  = '',
						volume_len    = 0,
						ami_info      = null;

					if (instance_data)
					{
						ami_info = MC.data.dict_ami[instance_data.imageId];
						if (ami_info)
						{
							root_devName = ami_info.rootDeviceName;
						}
					}

					//volume in asg
					$.each(node_volume_data, function (index, item)
					{
						if (!item)
						{
							return true;
						}

						volume_id = item.ebs.volumeId;
						if (item.deviceName === root_devName )
						{
							//delete node_volume_data[index];
							return true;
						}
						else
						{
							volume_len++;
						}

						if (MC.forge && MC.forge.app && MC.forge.app.getResourceById)
						{
							comp_vol = MC.data.resource_list[ MC.canvas_data.region ][volume_id];
							is_deleted = (comp_vol === null ? ' deleted' : '');
						}

						data.list.push({
							'is_deleted' : is_deleted,
							'volume_id': volume_id,
							'name': item.deviceName,
							'size': comp_vol ? comp_vol.size : '-',
							'snapshotId': comp_vol ? comp_vol.snapshotId : '-',
							'json': JSON.stringify({
								'instance_id': node_uid,
								'id': volume_id,
								'name': item.deviceName,
								'snapshotId': comp_vol ? comp_vol.snapshotId : '-',
								'volumeSize': comp_vol ? comp_vol.size : '-'
							})
						});
					});

				}
				else
				{
					//volume in instance
					$.each(node_volume_data, function (index, item)
					{
						if ($.type(item) === "object" )
						{//root device
							return true;
						}

						////external volume
						volume_id = item.replace('#', '');
						volume_data = component_data[ volume_id ];

						if (MC.forge && MC.forge.app && MC.forge.app.getResourceById)
						{
							comp_vol = MC.forge.app.getResourceById(volume_id);
							is_deleted = (comp_vol === null ? ' deleted' : '');
						}

						data.list.push({
							'is_deleted' : is_deleted,
							'volume_id': volume_id,
							'name': volume_data.name,
							'size': volume_data.resource.Size,
							'snapshotId': volume_data.resource.SnapshotId,
							'json': JSON.stringify({
								'instance_id': node_uid,
								'id': volume_id,
								'name': volume_data.name,
								'snapshotId': volume_data.resource.SnapshotId,
								'volumeSize': volume_data.resource.Size
							})
						});
					});
					volume_len = MC.aws.ebs.getVolumeLen( target_data.resource.BlockDeviceMapping );//exclude root device
				}
					
			}

			data.volumeLength = volume_len;

			$('#volume-bubble-content').html(
				MC.template.instanceVolume( data )
			);

			target_offset = target[0].getBoundingClientRect();
			target_width = target_offset.width;
			target_height = target_offset.height;

			width = bubble_box.width();
			height = bubble_box.height();

			coordinate.left = target_offset.left + target_width + 15 - canvas_offset.left;
			bubble_box.addClass('bubble-left');

			coordinate.top = target_offset.top - canvas_offset.top - ((height - target_height) / 2);

			bubble_box
				.data('target-id', node_uid)
				.css(coordinate)
				.show();

			if (target.prop('namespaceURI') === 'http://www.w3.org/2000/svg')
			{
				MC.canvas.update(node.id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_ATTACHED_ACTIVE);
			}
		}
	},

	show: function ()
	{
		var target = $(this),
			bubble_box = $('#volume-bubble-box'),
			target_id = target.data('target-id'),
			target_uid = target_id.replace(/_[0-9]*$/ig, ''),
			bubble_target_id;

		if (!bubble_box[0])
		{
			if (MC.canvas.getState() === 'app')
			{
				if (
					$('#' + target_id + '_instance-number').text() * 1 === 1 ||
					target.hasClass('instanceList-item-volume') ||
					target.hasClass('asgList-item-volume')
				)
				{
					MC.canvas.volume.bubble(
						document.getElementById( target_id )
					);

					return false;
				}
				else
				{
					MC.canvas.select( target_uid );

					return false;
				}

				if ($('#' + target_id).data('class') === 'AWS.AutoScaling.LaunchConfiguration')
				{
					MC.canvas.asgList.show.call( this, event );

					return false;
				}
			}

			if (MC.canvas.data.get('component.' + target_uid  + '.resource.BlockDeviceMapping').length > 0)
			{
				MC.canvas.volume.bubble(
					document.getElementById( target_id )
				);
			}
			else
			{
				if ($('#' + target_id ).prop('namespaceURI') === 'http://www.w3.org/2000/svg')
				{
					MC.canvas.update(target_id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_NOT_ATTACHED);
				}
			}
		}
		else
		{
			bubble_target_id = bubble_box.data('target-id');

			MC.canvas.volume.close();
			MC.canvas.event.clearSelected();

			MC.canvas.select( target_uid );

			if (target_uid !== bubble_target_id)
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
		if ($('#' + $('#volume-bubble-box').data('target-id')).data('class') === 'AWS.AutoScaling.LaunchConfiguration')
		{
			$("#svg_canvas").trigger("CANVAS_ASG_VOLUME_SELECTED", this.id);
		}
		else
		{
			$("#svg_canvas").trigger("CANVAS_NODE_SELECTED", this.id);
		}

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

			if ($('#' + target_id).prop('namespaceURI') === 'http://www.w3.org/2000/svg')
			{
				MC.canvas.update(target_id, 'image', 'volume_status', MC.canvas.IMAGE.INSTANCE_VOLUME_NOT_ATTACHED);
			}

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
			MC.canvas.getState() !== 'app' &&
			event.target === document.body
		)
		{
			var bubble_box = $('#volume-bubble-box'),
				target_id = bubble_box.data('target-id'),
				target_volume_data = MC.canvas.data.get('component.' + target_id + '.resource.BlockDeviceMapping'),
				target_node = $('#' + target_id),
				target_offset = target_node[0].getBoundingClientRect(),
				volume_id = $('#instance_volume_list').find('.selected').attr('id'),
				volumeList,
				volume_len;

			if (!volume_id)
			{
				return false;
			}

			if (target_node.data('class') === 'AWS.AutoScaling.LaunchConfiguration')
			{
				var rvolume = /volume_([a-zA-Z]{3,4})/ig,
					volume_match = rvolume.exec(volume_id),
					volume_name = volume_match[1],
					target_index;


				$.each(target_volume_data, function (i, item)
				{
					if (item.DeviceName.indexOf(volume_name) !== -1)
					{
						target_index = i;
					}
				});

				if ( target_index !== undefined )
				{
					target_volume_data.splice(target_index, 1);
				}
			}
			else
			{
				target_volume_data.splice(
					target_volume_data.indexOf(
						'#' + volume_id
					), 1
				);
			}

			volume_len = MC.aws.ebs.getVolumeLen( target_volume_data );

			$('#instance_volume_number, #' + target_id + '_volume_number').text(volume_len);//exclude root device

			document.getElementById(target_id + '_volume_number').setAttribute('value', volume_len); //exclude root device

			MC.canvas.data.set('component.' + target_id + '.resource.BlockDeviceMapping', target_volume_data);

			if (target_node.data('class') === 'AWS.EC2.Instance')
			{
				volumeList = MC.canvas_data.layout.component.node[ target_id ].volumeList[ volume_id ];

				if (volumeList)
				{
					$.each(volumeList, function (index, value)
					{
						MC.canvas.data.delete('component.' + value);
					});

					delete MC.canvas_data.layout.component.node[ target_id ].volumeList[ volume_id ];
				}

				MC.canvas.data.delete('component.' + volume_id);
			}

			$('#' + volume_id).parent().remove();

			bubble_box.css('top',  target_offset.top - $('#canvas_container').offset().top - ((bubble_box.height() - target_offset.height) / 2));

			$("#svg_canvas").trigger("CANVAS_NODE_SELECTED", "");

			$(document).off('keyup', MC.canvas.volume.remove);

			return true;
		}
	},

	mousedown: function (event)
	{
		if (event.which === 1)
		{
			var target = $(this),
				target_offset = target.offset(),
				canvas_offset = $('#svg_canvas').offset(),
				node_type = target.data('type'),
				target_component_type = target.data('component-type'),
				state = MC.canvas.getState(),
				shadow,
				clone_node;

			if (
				state === 'app' ||
				state === 'appview' ||
				$('#' + target.data('json')['instance_id']).data('class') === 'AWS.AutoScaling.LaunchConfiguration'
			)
			{
				MC.canvas.volume.select.call( $('#' + this.id )[0] );

				return false;
			}

			$(document.body)
				.append('<div id="drag_shadow"><div class="resource-icon resource-icon-volume"></div></div>')
				.append('<div id="overlayer" class="grabbing"></div>');

			shadow = $('#drag_shadow');

			shadow
				.addClass('AWS-EC2-EBS-Volume')
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50
				});

			Canvon('.AWS-EC2-Instance').addClass('attachable');

			$(document).on({
				'mousemove': MC.canvas.volume.mousemove,
				'mouseup': MC.canvas.volume.mouseup
			}, {
				'target': target,
				'canvas_offset': $('#svg_canvas').offset(),
				'canvas_body': $('#canvas_body'),
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
		var match_node = MC.canvas.matchPoint(
				event.pageX - event.data.canvas_offset.left,
				event.pageY - event.data.canvas_offset.top
			),
			node_type = match_node ? match_node.getAttribute('data-class') : null,
			event_data = event.data,
			target_type = MC.canvas.getState() === 'appedit' ? ['AWS.EC2.Instance'] : ['AWS.EC2.Instance', 'AWS.AutoScaling.LaunchConfiguration'];

		if (MC.canvas.getState() === 'appedit' && event_data.action ==='move' )
		{
			if (MC.canvas_data.component[$(event.data.target).data().json.id].resource.VolumeId)
				return false;
		}

		if (
			event_data.originalX !== event.pageX ||
			event_data.originalY !== event.pageY
		)
		{
			event_data.shadow
				.css({
					'top': event.pageY - 50,
					'left': event.pageX - 50
				})
				.show();

			event_data.canvas_body.addClass('node-dragging');
		}

		if (
			match_node &&
			$.inArray(node_type, target_type) > -1
		)
		{
			if (
				event_data.action === 'move' &&
				node_type === 'AWS.AutoScaling.LaunchConfiguration'
			)
			{
				MC.canvas.volume.close();
			}
			else
			{
				MC.canvas.volume.bubble(match_node);
			}
		}
		else
		{
			MC.canvas.volume.close();
		}

		return false;
	},

	mouseup: function (event)
	{
		var target = $(event.data.target),
			target_component_type = target.data('component-type'),
			node_option = target.data('option'),
			bubble_box = $('#volume-bubble-box'),
			original_node_volume_data,
			new_volume_name,
			target_volume_data,
			original_node_id,
			volume_type,
			new_volume,
			data_option,
			volume_id,
			target_id,
			target_az,
			volume_len;

		Canvon('.AWS-EC2-Instance, .AWS-AutoScaling-LaunchConfiguration').removeClass('attachable');

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
					if (target_node.data('class') === 'AWS.AutoScaling.LaunchConfiguration')
					{
						volume_id = new_volume;
					}
					else
					{
						volume_id = new_volume.id;
						//data_option.name = MC.canvas.data.get('component.' + volume_id + '.name');
					}
				}
			}

			if (event.data.action === 'move')
			{
				if (data_option.instance_id !== target_id)
				{
					new_volume_name = MC.aws.ebs.getDeviceName(target_id, volume_id);

					if (!new_volume_name) {
						notification('warning', 'Attached volume has reached instance limit.', false);
					} else {
						data_json = JSON.stringify({
							'instance_id': target_id,
							'id': volume_id,
							'name': new_volume_name,
							'snapshotId': data_option.snapshotId,
							'volumeSize': data_option.volumeSize
						});

						volume_type = data_option.snapshotId ? 'snapshot_item' : 'volume_item';

						$('#instance_volume_list').append('<li><a href="javascript:void(0)" id="' + volume_id +'" class="' + volume_type + '" data-json=\'' + data_json + '\'><span class="volume_name">' + new_volume_name + '</span><span class="volume_size">' + data_option.volumeSize + 'GB</span></a></li>');

						target_volume_data.push('#' + volume_id);

						volume_len = MC.aws.ebs.getVolumeLen( target_volume_data );

						$('#instance_volume_number').text(volume_len);//exclude root device

						MC.canvas.update(target_id, 'text', 'volume_number', volume_len);//exclude root device
						document.getElementById(target_id + '_volume_number').setAttribute('value', volume_len);//exclude root device

						target_az = MC.canvas.data.get('component.' + target_id + '.resource.Placement.AvailabilityZone');

						MC.canvas.data.set('component.' + volume_id + '.name', new_volume_name);
						MC.canvas.data.set('component.' + volume_id + '.serverGroupName', new_volume_name);
						MC.canvas.data.set('component.' + volume_id + '.resource.AttachmentSet.Device', new_volume_name);
						MC.canvas.data.set('component.' + volume_id + '.resource.AvailabilityZone', target_az);
						MC.canvas.data.set('component.' + volume_id + '.resource.AttachmentSet.InstanceId', '@' + target_id + '.resource.InstanceId');

						MC.canvas.volume.select.call( document.getElementById( volume_id ) );

						// Update original data
						original_node_id = data_option.instance_id;
						original_node_volume_data = MC.canvas.data.get('component.' + original_node_id + '.resource.BlockDeviceMapping');

						original_node_volume_data.splice(
							original_node_volume_data.indexOf('#' + volume_id), 1
						);

						MC.canvas.data.set('component.' + original_node_id + '.resource.BlockDeviceMapping', original_node_volume_data);

						volume_len = MC.aws.ebs.getVolumeLen( original_node_volume_data );
						MC.canvas.update(original_node_id, 'text', 'volume_number', volume_len);//exclude root device

						document.getElementById(original_node_id + '_volume_number').setAttribute('value', volume_len);//exclude root device
					}
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

				if ( MC.canvas.data.get('component.' + target_id).type === 'AWS.EC2.Instance')
				{
					target_volume_data.push('#' + volume_id);
				}

				volume_len = MC.aws.ebs.getVolumeLen(target_volume_data);

				$('#instance_volume_number').text(volume_len);//exclude root device

				MC.canvas.update(target_id, 'text', 'volume_number', volume_len );//exclude root device

				document.getElementById(target_id + '_volume_number').setAttribute('value', volume_len);//exclude root device

				MC.canvas.data.set('component.' + target_id + '.resource.BlockDeviceMapping', target_volume_data);

				MC.canvas.volume.select.call( document.getElementById( volume_id ) );
			}

			bubble_box.css('top',  target_offset.top - $('#canvas_container').offset().top - ((bubble_box.height() - target_offset.height) / 2));
		}
		else
		{
			// dispatch event when is not matched
			$("#svg_canvas").trigger("CANVAS_PLACE_NOT_MATCH", {
				'type': 'AWS.EC2.EBS.Volume'
			});
		}

		event.data.shadow.remove();

		event.data.canvas_body.removeClass('node-dragging');

		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.volume.mousemove,
			'mouseup': MC.canvas.volume.mouseup
		});

		return false;
	}
};

MC.canvas.asgList = {
	show: function (event)
	{
		event.stopImmediatePropagation();

		if (event.which === 1)
		{
			MC.canvas.event.clearList();

			var target = this.parentNode,
				target_id = target.id,
				target_offset = Canvon(target).offset(),
				canvas_offset = $('#svg_canvas').offset();

			// Prepare data
			var uid     = MC.extractID( target_id );
			var layout  = MC.canvas_data.layout.component.node[ uid ];
			var volume_len = 0;
			if (!layout) {
				return;
			}
			var lc_comp = MC.canvas_data.component[ layout.groupUId ];
			var appData = MC.data.resource_list[ MC.canvas_data.region ];
			var asgData = appData[ lc_comp.resource.AutoScalingGroupARN ];

			if ( !asgData ) {
				return true;
			}

			// var statusMap = {
			// 	"Pending"     : "orange",
			// 	"Quarantined" : "orange",
			// 	"InService"   : "green",
			// 	"Terminating" : "red",
			// 	"Terminated"  : "red"
			// };
			var statusMap = {
				   "pending"       : "yellow"
				 , "stopping"      : "yellow"
				 , "shutting-down" : "yellow"
				 , "running"       : "green"
				 , "stopped"       : "red"
				 , "terminated"    : "red"
				 , "unknown"       : "grey"
			};


			var temp_data = {
				name      : lc_comp.name,
				instances : []
			};

			lc_comp = MC.canvas_data.component[ MC.extractID( lc_comp.resource.LaunchConfigurationName ) ];
			volume_len = MC.aws.ebs.getVolumeLen( lc_comp.resource.BlockDeviceMapping );
			temp_data.volume = volume_len;

			if ( layout ) {
				temp_data.background = [layout.osType, layout.architecture, layout.rootDeviceType].join(".");
			}

			var instances = asgData.Instances.member,
				state = null;
			if ( instances )
			{
				for ( var i = 0, l = instances.length; i < l; ++i ) {
					//get instance state
					if (MC.aws && MC.aws.instance && MC.aws.instance.getInstanceState ){
						state = MC.aws.instance.getInstanceState( instances[i].InstanceId );
					}
					if (!state){
						state = 'unknown';
					}

					temp_data.instances.push({
							id     : instances[i].InstanceId
						//, color : statusMap[ instances[i].LifecycleState ]
						//, state : instances[i].LifecycleState
						, color : statusMap[state]
						, state : state
					});
				}
			}

			$('#canvas_container').append( MC.template.asgList( temp_data ) );

			$('#asgList-wrap')
				.on('click', '.asgList-item', MC.canvas.asgList.select)
				.css({
					'top': target_offset.top - canvas_offset.top - 30,
					'left': target_offset.left - canvas_offset.left - 20
				});

			MC.canvas.asgList.select.call($('#asgList-wrap .asgList-item').first());

			return true;
		}
	},

	close: function ()
	{
		$('#asgList-wrap').remove();

		return false;
	},

	select: function (event)
	{
		var target = $(this);

		$('#asgList-wrap .selected').removeClass('selected');

		target.addClass('selected');

		$('#svg_canvas').trigger('CANVAS_ASG_SELECTED', target.data('id'));

		return false;
	}
};

MC.canvas.instanceList = {
	add: function (data)
	{
		$('#instanceList').append(
			MC.template.instanceListItem(data)
		);

		return true;
	},

	remove: function (id)
	{
		$('#' + id).parent().remove();

		return true;
	},

	show: function (event)
	{
		event.stopImmediatePropagation();

		if (event.which === 1)
		{
			MC.canvas.event.clearList();

			var target = this.parentNode,
				target_id = target.id,
				target_offset = Canvon('#' + target_id).offset(),
			   	canvas_offset = $('#svg_canvas').offset();

			if ($('#' + target_id + '_instance-number').text() * 1 === 1)
			{
				MC.canvas.select( target_id );

				return false;
			}

			var uid     = MC.extractID( target_id ),
			    layout  = MC.canvas_data.layout.component.node[ uid ];

			var temp_data = {
				  instances : []
				, name      : "Server Group List"
			};
			var statusMap = {
				"pending"       : "yellow"
				 , "stopping"      : "yellow"
				 , "shutting-down" : "yellow"
				 , "running"       : "green"
				 , "stopped"       : "red"
				 , "terminated"    : "red"
				 , "unknown"       : "grey"
			};

			if ( layout ) {
				temp_data.background = [layout.osType, layout.architecture, layout.rootDeviceType].join(".");
			}

			for ( var i = 0; i < layout.instanceList.length; ++i ) {

				var inst_comp = MC.canvas_data.component[ layout.instanceList[ i ] ],
					state = null,
					instance_data = null;
				temp_data.name = inst_comp.serverGroupName;

				//get instance state
				if (MC.aws && MC.aws.instance && MC.aws.instance.getInstanceState ){
					state = MC.aws.instance.getInstanceState( inst_comp.resource.InstanceId );
				}

				if (!state){
					state = 'unknown';
				}

				temp_data.instances.push( {
					  color : statusMap[ state ]
					, id     : inst_comp.uid
					, volume : MC.aws.ebs.getVolumeLen(inst_comp.resource.BlockDeviceMapping)
					, name   : inst_comp.name
					, state  : state
					, is_deleted : 'terminated|shutting-down|unknown'.indexOf(state) !== -1 ? ' deleted' : ''
				} );
			}

			$('#canvas_container').append( MC.template.instanceList( temp_data ) );

			$('#instanceList-wrap')
				.on('click', '.instanceList-item', MC.canvas.instanceList.select)
				.css({
					'top': target_offset.top - canvas_offset.top - 30,
					'left': target_offset.left - canvas_offset.left - 20
				});

			MC.canvas.instanceList.select.call($('#instanceList-wrap .instanceList-item').first());
		}

		return false;
	},

	close: function ()
	{
		$('#instanceList-wrap').remove();

		return false;
	},

	select: function (event)
	{
		var target = $(this),
			bubble_box = $('#volume-bubble-box');

		if (
			bubble_box[0] &&
			bubble_box.data('target-id') !== target.data('id')
		)
		{
			MC.canvas.volume.close();
		}

		$('#instanceList-wrap .selected').removeClass('selected');

		target.addClass('selected');

		$('#svg_canvas').trigger('CANVAS_INSTANCE_SELECTED', target.data('id'));

		return false;
	}
};

MC.canvas.eniList = {
	add: function (data)
	{
		$('#eniList').append(
			MC.template.eniListItem(data)
		);

		return true;
	},

	remove: function (id)
	{
		$('#' + id).parent().remove();

		return true;
	},

	show: function (event)
	{
		event.stopImmediatePropagation();

		if (event.which === 1)
		{
			MC.canvas.event.clearList();

			var target = this.parentNode,
				target_id = target.id,
				target_offset = Canvon('#' + target_id).offset(),
				canvas_offset = $('#svg_canvas').offset();

			if ($('#' + target_id + '_eni-number').text() * 1 === 1)
			{
				MC.canvas.select( target_id );

				return false;
			}

			var uid      = MC.extractID( target_id ),
			    layout   = MC.canvas_data.layout.component.node[ uid ],
			    eni_comp = MC.canvas_data.component[ uid ];

			var temp_data = {
				  enis : []
				, name : eni_comp.serverGroupName
				, eip  : layout.eniList.length === layout.eipList.length
			};

			// if ( eni_comp.resource.Attachment && eni_comp.resource.Attachment.InstanceId ) {
			// 	var ins_comp = MC.canvas_data.component[ MC.extractID( eni_comp.resource.Attachment.InstanceId ) ];
			// 	if ( ins_comp.serverGroupName ) {
			// 		temp_data.name += " - " + ins_comp.serverGroupName;
			// 	}
			// }

			for ( var i = 0, l = layout.eniList.length; i < l; ++i )
			{
				var is_deleted = '',
					found_eni = null;

				var eni_comp = MC.canvas_data.component[ layout.eniList[ i ] ];

				//get eni
				if (MC.aws && MC.aws.eni && MC.aws.eni.getENIById ){
					found_eni = MC.aws.eni.getENIById( eni_comp.resource.NetworkInterfaceId );
				}
				if (found_eni === undefined){
					is_deleted = " deleted";
				}

				temp_data.enis.push({
					'id'   : eni_comp.uid,
					'name' : eni_comp.resource.NetworkInterfaceId,
					'is_deleted' : is_deleted
				});
			}

			$('#canvas_container').append( MC.template.eniList( temp_data ) );

			$('#eniList-wrap')
				.on('click', '.eniList-item', MC.canvas.eniList.select)
				.css({
					'top': target_offset.top - canvas_offset.top - 30,
					'left': target_offset.left - canvas_offset.left - 20
				});

			MC.canvas.eniList.select.call($('#eniList-wrap .eniList-item').first());

			return false;
		}
	},

	close: function ()
	{
		$('#eniList-wrap').remove();

		return false;
	},

	select: function (event)
	{
		var target = $(this);

		$('#eniList-wrap .selected').removeClass('selected');

		target.addClass('selected');

		$('#svg_canvas').trigger('CANVAS_ENI_SELECTED', target.data('id'));

		return false;
	}
};

MC.canvas.event = {};

// Double click event simulation
MC.canvas.event.dblclick = function (callback)
{
	if (MC.canvas.event.dblclick.timer)
	{
		// Double click event call
		callback.call(this, event);

		return true;
	}

	MC.canvas.event.dblclick.timer = setTimeout(function ()
	{
		MC.canvas.event.dblclick.timer = null;
	}, 500);

	return false;
};

MC.canvas.event.dblclick.timer = null;

MC.canvas.event.dragable = {
	mousedown: function (event)
	{
		if (
			event.which === 1 &&
			event.ctrlKey
		)
		{
			event.stopImmediatePropagation();

			MC.canvas.event.ctrlMove.mousedown.call( this, event );

			return false;
		}

		if (event.which === 1)
		{
			// Double click event
			if (MC.canvas.event.dblclick(function ()
			{
				$('#svg_canvas').trigger('SHOW_PROPERTY_PANEL');
			}))
			{
				return false;
			}

			var target = $(this),
				target_offset = Canvon(this).offset(),
				target_type = target.data('type'),
				node_type = target.data('class'),
				svg_canvas = $('#svg_canvas'),
				canvas_offset = svg_canvas.offset(),
				canvas_body = $('#canvas_body'),
				platform = MC.canvas_data.platform,
				currentTarget = $(event.target),
				shadow,
				target_group_type,
				SVGtranslate;

			if (node_type === 'AWS.AutoScaling.LaunchConfiguration')
			{
				if (currentTarget.is('.instance-volume'))
				{
					MC.canvas.volume.show.call(event.target);
				}
				else
				{
					MC.canvas.event.clearSelected();
					MC.canvas.select(this.id);
				}

				return false;
			}

			if (currentTarget.is('.instance-volume'))
			{
				MC.canvas.volume.show.call(event.target);

				return false;
			}

			if (currentTarget.is('.eip-status') && MC.canvas.getState() !== 'appview')
			{
				MC.canvas.event.EIPstatus.call(event.target);

				return false;
			}

			if (node_type === 'AWS.VPC.Subnet')
			{
				target.find('.port').hide();
			}

			shadow = target.clone();

			svg_canvas.append(shadow);

			target_group_type = MC.canvas.MATCH_PLACEMENT[ platform ][ node_type ];

			if (target_group_type)
			{
				$.each(target_group_type, function (index, item)
				{
					if (item !== 'AWS.AutoScaling.Group' && item !== 'Canvas')
					{
						Canvon('.' + item.replace(/\./ig, '-')).addClass('dropable-group');
					}
				});
			}

			$(document.body).append('<div id="overlayer" class="grabbing"></div>');

			// Caching the SVGtranslate object at first for fastest value manipulating.
			if (shadow[0].transform.numberOfItems === 0)
			{
				SVGtranslate = shadow[0].transform.baseVal.appendItem(
					shadow[0].ownerSVGElement.createSVGTransform()
				);
			}
			else
			{
				SVGtranslate = shadow[0].transform.baseVal.getItem(0);
			}

			if (node_type === 'AWS.VPC.InternetGateway' || node_type === 'AWS.VPC.VPNGateway')
			{
				Canvon(shadow).addClass('shadow');

				$(document).on({
					'mousemove': MC.canvas.event.dragable.gatewaymove,
					'mouseup': MC.canvas.event.dragable.gatewayup
				}, {
					'target': target,
					'canvas_body': canvas_body,
					'target_type': target_type,
					'node_type': node_type,
					'vpc_data': MC.canvas.data.get('layout.component.group.' + $('.AWS-VPC-VPC').attr('id')),
					'shadow': shadow,
					'offsetX': event.pageX - target_offset.left + canvas_offset.left,
					'offsetY': event.pageY - target_offset.top + canvas_offset.top,
					'originalPageX': event.pageX,
					'originalPageY': event.pageY,
					'scale_ratio': MC.canvas_property.SCALE_RATIO,
					'SVGtranslate': SVGtranslate
				});
			}
			else
			{
				$(document).on({
					'mousemove': MC.canvas.event.dragable.mousemove,
					'mouseup': Canvon(event.target).hasClass('asg-resource-dragger') ?
						// For asgExpand
						MC.canvas.event.dragable.asgExpandup :
						// Default
						MC.canvas.event.dragable.mouseup
				}, {
					'target': target,
					'canvas_body': canvas_body,
					'target_type': target_type,
					'node_type': node_type,
					'shadow': shadow,
					'offsetX': event.pageX - target_offset.left + canvas_offset.left,
					'offsetY': event.pageY - target_offset.top + canvas_offset.top,
					'groupChild': target_type === 'group' ? MC.canvas.groupChild(this) : null,
					'originalPageX': event.pageX,
					'originalPageY': event.pageY,
					'originalTarget': event.target,
					'component_size': target_type === 'node' ? MC.canvas.COMPONENT_SIZE[ node_type ] : MC.canvas.data.get('layout.component.group.' + target[0].id + '.size'),
					'grid_width': MC.canvas.GRID_WIDTH,
					'grid_height': MC.canvas.GRID_HEIGHT,
					'scale_ratio': MC.canvas_property.SCALE_RATIO,
					'SVGtranslate': SVGtranslate
				});
			}

			MC.canvas.volume.close();
			MC.canvas.event.clearSelected();
		}

		return false;
	},
	mousemove: function (event)
	{
		var event_data = event.data,
			target_id = event_data.target[0].id,
			target_type = event_data.target_type,
			node_type = event_data.node_type,
			component_size = event_data.component_size,
			grid_width = event_data.grid_width,
			grid_height = event_data.grid_height,
			scale_ratio = event_data.scale_ratio,
			coordinate = {
				'x': Math.round((event.pageX - event_data.offsetX) / (grid_width / scale_ratio)),
				'y': Math.round((event.pageY - event_data.offsetY) / (grid_height / scale_ratio))
			},
			match_place = MC.canvas.isMatchPlace(
				target_id,
				target_type,
				node_type,
				coordinate.x,
				coordinate.y,
				component_size[0],
				component_size[1]
			);

		if (
			event.pageX !== event_data.originalPageX &&
			event.pageY !== event_data.originalPageY &&
			!Canvon(event_data.shadow).hasClass('shadow')
		)
		{
			Canvon(event_data.shadow).addClass('shadow');
			event_data.canvas_body.addClass('node-dragging');
		}

		Canvon('.match-dropable-group').removeClass('match-dropable-group');

		if (match_place.is_matched)
		{
			Canvon('#' + match_place.target).addClass('match-dropable-group');
		}

		// Cached SVGtranslate (fast)
		event_data.SVGtranslate.setTranslate(coordinate.x * grid_width, coordinate.y * grid_height);

		return false;
	},
	mouseup: function (event)
	{
		var target = event.data.target,
			target_id = target.attr('id'),
			target_type = event.data.target_type,
			node_type = target.data('class');

		if (node_type === 'AWS.VPC.Subnet')
		{
			event.data.target.find('.port').show();
		}

		// Selected
		if (
			event.pageX === event.data.originalPageX &&
			event.pageY === event.data.originalPageY
		)
		{
			if (MC.canvas.getState() === 'app')
			{
				MC.canvas.instanceList.show.call( target[0], event);
			}
			else
			{
				var originalTarget = event.data.originalTarget,
					originalTargetNode = $(originalTarget),
					component_data = MC.canvas.data.get('layout.component.' + target_type + '.' + target_id);

				MC.canvas.select( target_id );
				MC.canvas.volume.close();
			}
		}
		else
		{
			var svg_canvas = $("#svg_canvas"),
				canvas_offset = svg_canvas.offset(),
				shadow_offset = Canvon(event.data.shadow).offset(),
				layout_node_data = MC.canvas.data.get('layout.component.node'),
				layout_connection_data = MC.canvas.data.get('layout.connection'),
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
					node_type,
					coordinate.x,
					coordinate.y,
					coordinate.x + component_size[0],
					coordinate.y + component_size[1]
				);

				if (
					coordinate.x > 0 &&
					coordinate.y > 0 &&
					match_place.is_matched &&
					// Disallow Instance to ASG
					!(
						parentGroup &&
						parentGroup.getAttribute('data-class') === 'AWS.AutoScaling.Group' &&
						node_type === 'AWS.EC2.Instance'
					)
					&&
					(
						svg_canvas.trigger(BEFORE_DROP_EVENT, {'src_node': target_id, 'tgt_parent': parentGroup ? parentGroup.id : ''}) &&
						!BEFORE_DROP_EVENT.isDefaultPrevented()
					)
				)
				{
					MC.canvas.position(document.getElementById(target_id), coordinate.x, coordinate.y);

					MC.canvas.reConnect(target_id);

					svg_canvas.trigger("CANVAS_NODE_CHANGE_PARENT", {
						'src_node': target_id,
						'tgt_parent': parentGroup ? parentGroup.id : ''
					});

					MC.canvas.select(target_id);
				}
				else if (
					parentGroup &&
					parentGroup.getAttribute('data-class') === 'AWS.AutoScaling.Group' &&
					node_type === 'AWS.EC2.Instance'
				)
				{
					notification('warning', 'Launch Configuration can only be created by using AMI from Resource Panel.');
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
					connection_stack = {},
					coordinate_fixed = false,
					match_place,
					areaChild,
					parentGroup,
					parent_data,
					parent_coordinate,
					parent_size,
					data,
					connection_target_id,
					fixed_areaChild,
					group_offsetX,
					group_offsetY,
					matched_child,
					child_data,
					child_type,
					isBlank;

				if (group_data.type === 'AWS.VPC.VPC')
				{
					if (coordinate.y <= 3)
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
					// Make it larger for better place determination
					coordinate.x - 1,
					coordinate.y - 1,
					group_size[0] + 2,
					group_size[1] + 2
				);

				areaChild = MC.canvas.areaChild(
					target_id,
					node_type,
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
							node_type,
							coordinate.x,
							coordinate.y,
							coordinate.x + group_size[0],
							coordinate.y + group_size[1]
						);
					}
				}

				group_offsetX = coordinate.x - group_coordinate[0];
				group_offsetY = coordinate.y - group_coordinate[1];

				isBlank =
					MC.canvas.isBlank(
						'group',
						target_id,
						group_data.type,
						coordinate.x,
						coordinate.y,
						group_size[0],
						group_size[1]
					) &&
					event.data.groupChild.length === unique_stack.length;

				if (
					(
						(
							coordinate_fixed &&
							match_place.is_matched &&
							event.data.groupChild.length === fixed_areaChild.length
						)
						||
						(
							!coordinate_fixed &&
							match_place.is_matched &&
							isBlank
						)
					)
					&&
					(
						svg_canvas.trigger(BEFORE_DROP_EVENT, {'src_node': target_id, 'tgt_parent': parentGroup ? parentGroup.id : ''}) &&
						!BEFORE_DROP_EVENT.isDefaultPrevented()
					)
				)
				{
					MC.canvas.position(event.data.target[0], coordinate.x, coordinate.y);

					$.each(event.data.groupChild, function (index, item)
					{
						child_type = item.getAttribute('data-type');

						if (child_type === 'node')
						{
							node_data = layout_node_data[ item.id ];
						}

						if (child_type === 'group')
						{
							node_data = layout_group_data[ item.id ];
						}

						MC.canvas.position(item, node_data.coordinate[0] + group_offsetX, node_data.coordinate[1] + group_offsetY);

						// Re-draw group connection
						if (
							node_data.type === 'AWS.VPC.Subnet' ||
							 node_data.type === 'AWS.AutoScaling.Group' ||
							child_type === 'node'
						)
						{
							$.each(node_data.connection, function (i, data)
							{
								connection_stack[ data.line ] = true;
							});
						}
					});

					$.each(connection_stack, function (key, value)
					{
						data = layout_connection_data[ key ];

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
								'line_uid': key
							}
						);
					});

					// Re-draw group connection
					if (group_data.type === 'AWS.VPC.Subnet' || group_data.type === 'AWS.AutoScaling.Group')
					{
						MC.canvas.reConnect(target_id);
					}

					var group_left = coordinate.x,
						group_top = coordinate.y,
						group_width = group_size[0],
						group_height = group_size[1],
						igw_gateway,
						igw_gateway_id,
						igw_gateway_data,
						igw_top,
						vgw_gateway,
						vgw_gateway_id,
						vgw_gateway_data,
						vgw_top;

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
							MC.canvas.position(igw_gateway[0],  group_left - 4, igw_top);

							MC.canvas.reConnect(igw_gateway_id);
						}

						if (vgw_gateway[0])
						{
							vgw_gateway_id = vgw_gateway.attr('id');
							vgw_gateway_data = layout_node_data[ vgw_gateway_id ];
							vgw_top = vgw_gateway_data.coordinate[1] + group_offsetY;

							// MC.canvas.COMPONENT_SIZE[0] / 2 = 4
							MC.canvas.position(vgw_gateway[0],  group_left + group_width - 4, vgw_top);

							MC.canvas.reConnect(vgw_gateway_id);
						}
					}

					// after change node to another group,trigger event
					svg_canvas.trigger("CANVAS_GROUP_CHANGE_PARENT", {
						'src_group': target_id,
						'tgt_parent': parentGroup ? parentGroup.id : ''
					});

					MC.canvas.select(target_id);
				}
				else if (!isBlank)
				{
					//dispatch event when is not blank
					$("#svg_canvas").trigger("CANVAS_PLACE_OVERLAP");
				}
			}
		}

		event.data.shadow.remove();
		event.data.canvas_body.removeClass('node-dragging');

		$('#overlayer').remove();

		Canvon('.dropable-group').removeClass('dropable-group');

		Canvon('.match-dropable-group').removeClass('match-dropable-group');

		$(document).off({
			'mousemove': MC.canvas.event.dragable.mousemove,
			'mouseup': MC.canvas.event.dragable.mouseup
		});
	},
	gatewaymove: function (event)
	{
		var event_data = event.data,
			gateway_top = Math.round((event.pageY - event_data.offsetY) / (MC.canvas.GRID_HEIGHT / event_data.scale_ratio)),
			vpc_coordinate = event_data.vpc_data.coordinate,
			vpc_size = event_data.vpc_data.size,
			node_type = event_data.node_type;

		// MC.canvas.COMPONENT_SIZE for AWS.VPC.InternetGateway and AWS.VPC.VPNGateway = 8
		if (gateway_top > vpc_coordinate[1] + vpc_size[1] - 8)
		{
			gateway_top = vpc_coordinate[1] + vpc_size[1] - 8;
		}

		if (gateway_top < vpc_coordinate[1])
		{
			gateway_top = vpc_coordinate[1];
		}

		if (node_type === 'AWS.VPC.InternetGateway')
		{
			// Cached SVGtranslate (fast)
			event_data.SVGtranslate.setTranslate(
				(vpc_coordinate[0] - 4) * MC.canvas.GRID_WIDTH,
				gateway_top * MC.canvas.GRID_HEIGHT
			);
		}

		if (node_type === 'AWS.VPC.VPNGateway')
		{
			// Cached SVGtranslate (fast)
			event_data.SVGtranslate.setTranslate(
				(vpc_coordinate[0] + vpc_size[0] - 4) * MC.canvas.GRID_WIDTH,
				gateway_top * MC.canvas.GRID_HEIGHT
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
			shadow_offset = Canvon(event.data.shadow).offset(),
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			layout_connection_data = MC.canvas.data.get('layout.connection'),
			node_type = target.data('class'),
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			coordinate;

		coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top);

		MC.canvas.position(target[0], layout_node_data[ target_id ].coordinate[0], coordinate.y);

		MC.canvas.reConnect(target_id);

		MC.canvas.select(target_id);

		Canvon('.dropable-group').removeClass('dropable-group');

		event.data.shadow.remove();

		event.data.canvas_body.removeClass('node-dragging');

		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.event.gatewaymove,
			'mouseup': MC.canvas.event.gatewayup
		});
	},
	asgExpandup: function (event)
	{
		var target = event.data.target,
			target_id = target.attr('id'),
			target_type = event.data.target_type,
			svg_canvas = $('#svg_canvas'),
			canvas_offset = svg_canvas.offset(),
			shadow_offset = Canvon(event.data.shadow).offset(),
			layout_node_data = MC.canvas.data.get('layout.component.node'),
			layout_connection_data = MC.canvas.data.get('layout.connection'),
			node_type = target.data('class'),
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			coordinate = MC.canvas.pixelToGrid(shadow_offset.left - canvas_offset.left, shadow_offset.top - canvas_offset.top),
			component_size = MC.canvas.GROUP_DEFAULT_SIZE[ node_type ],
			BEFORE_ASG_EXPAND_EVENT = $.Event("CANVAS_BEFORE_ASG_EXPAND"),
			areaChild = MC.canvas.areaChild(
				target_id,
				node_type,
				coordinate.x,
				coordinate.y,
				coordinate.x + component_size[0],
				coordinate.y + component_size[1]
			),
			match_place = MC.canvas.isMatchPlace(
				null,
				target_type,
				node_type,
				coordinate.x,
				coordinate.y,
				component_size[0],
				component_size[1]
			),
			parentGroup = MC.canvas.parentGroup(
				target_id,
				node_type,
				coordinate.x,
				coordinate.y,
				coordinate.x + component_size[0],
				coordinate.y + component_size[1]
			);

		if (
			areaChild.length === 0 &&
			match_place.is_matched &&
			svg_canvas.trigger(BEFORE_ASG_EXPAND_EVENT, {'src_node': target_id, 'tgt_parent': parentGroup ? parentGroup.id : ''}) &&
			!BEFORE_ASG_EXPAND_EVENT.isDefaultPrevented()
		)
		{
			new_node = MC.canvas.add(node_type, {'name': MC.canvas.data.get('component')[target_id].name, 'groupUId': match_place.target, 'originalId': target_id}, coordinate);

			if (new_node)
			{
				MC.canvas.select(new_node.id);
			}
		}

		Canvon('.dropable-group').removeClass('dropable-group');

		event.data.shadow.remove();

		event.data.canvas_body.removeClass('node-dragging');

		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.event.dragable.mousemove,
			'mouseup': MC.canvas.event.dragable.asgExpandup
		});
	}
};

MC.canvas.event.drawConnection = {
	mousedown: function (event)
	{
		if (event.which === 1)
		{
			var svg_canvas = $('#svg_canvas'),
				canvas_offset = svg_canvas.offset(),
				target = $(this),
				target_offset = Canvon(this).offset(),
				parent = target.parent(),
				node_id = parent.attr('id'),
				node_type = parent.data('class'),
				layout_component_data = MC.canvas_data.layout.component,
				layout_connection_data = MC.canvas_data.layout.connection,
				layout_node_data = layout_component_data[ parent.data('type') ],
				node_connections = layout_node_data[ node_id ].connection,
				position = target.data('position'),
				port_type = target.data('type'),
				port_name = target.data('name'),
				connection_option = MC.canvas.CONNECTION_OPTION[ node_type ],
				scale_ratio = MC.canvas_property.SCALE_RATIO,
				CHECK_CONNECTABLE_EVENT = $.Event("CHECK_CONNECTABLE_EVENT"),
				offset = {},
				port_position_offset = 8 / scale_ratio,
				target_connection_option,
				target_data,
				target_node,
				target_port,
				is_connected,
				line_data;

			//calculate point of junction
			switch (position)
			{
				case 'left':
					offset.left = target_offset.left;
					offset.top  = target_offset.top + port_position_offset;
					break;

				case 'right':
					offset.left = target_offset.left + port_position_offset;
					offset.top  = target_offset.top + port_position_offset;
					break;

				case 'top':
					offset.left = target_offset.left + port_position_offset;
					offset.top  = target_offset.top;
					break;

				case 'bottom':
					offset.left = target_offset.left + port_position_offset;
					offset.top  = target_offset.top + port_position_offset;
					break;
			}

			$(document.body).append('<div id="overlayer"></div>');

			svg_canvas.append(Canvon.group().attr({
				'class': 'draw-line-wrap line-' + port_type,
				'id': 'draw-line-connection'
			}));

			$(document).on({
				'mousemove': MC.canvas.event.drawConnection.mousemove,
				'mouseup': MC.canvas.event.drawConnection.mouseup
			}, {
				'connect': target.data('connect'),
				'originalTarget': target.parent(),
				'originalX': (offset.left - canvas_offset.left) * scale_ratio,
				'originalY': (offset.top - canvas_offset.top) * scale_ratio,
				'option': connection_option,
				'draw_line': $('#draw-line-connection'),
				'port_name': port_name,
				'canvas_offset': canvas_offset,
				'scale_ratio': scale_ratio
			});

			MC.canvas.event.clearSelected();

			// Keep hover style on
			$.each(node_connections, function (index, item)
			{
				Canvon('#' + item.line).addClass('view-keephover');
			});

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
												line_data = layout_connection_data[data.line];

												if (line_data.target[node_id] === value.from && data.target === node_id)
												//if (data.port === value.to && data.target === node_id)
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

							svg_canvas.trigger(CHECK_CONNECTABLE_EVENT, {
								  from      : node_id
								, to        : item.id
								, from_port : value.from
								, to_port   : value.to});

							if (!CHECK_CONNECTABLE_EVENT.isDefaultPrevented())
							{
								target_node = this;

								$(target_node).find('.port-' + value.to).each(function ()
								{
									target_port = $(this);

									if (target_port.css('display') !== 'none')
									{
										Canvon(target_node).addClass('connectable');

										Canvon(target_port).addClass("connectable-port view-show");
									}
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
		var event_data = event.data,
			canvas_offset = event_data.canvas_offset,
			scale_ratio = event_data.scale_ratio,
			endX = (event.pageX - canvas_offset.left) * scale_ratio,
			endY = (event.pageY - canvas_offset.top) * scale_ratio,
			startX = event_data.originalX,
			startY = event_data.originalY,
			angle = Math.atan2(endY - startY, endX - startX),
			arrow_length = 8,

			arrowPI = 3.141592653589793 / 6,
			arrowAngleA = angle - arrowPI,
			arrowAngleB = angle + arrowPI;

		event_data.draw_line.empty().append(
			Canvon.line(startX, startY, endX, endY).attr('class', 'draw-line'),

			Canvon.polygon([
				[endX, endY],
				[endX - arrow_length * Math.cos(arrowAngleA), endY - arrow_length * Math.sin(arrowAngleA)],
				[endX - arrow_length * Math.cos(arrowAngleB), endY - arrow_length * Math.sin(arrowAngleB)]
			]).attr('class', 'draw-line-arrow')
		);

		return false;
	},

	mouseup: function (event)
	{
		event.data.draw_line.remove();

		var match_node = MC.canvas.matchPoint(
				Math.round(event.pageX - event.data.canvas_offset.left),
				Math.round(event.pageY - event.data.canvas_offset.top)
			),
			svg_canvas = $('#svg_canvas'),
			from_node = event.data.originalTarget,
			port_name = event.data.port_name,
			from_type = from_node.data('class'),
			// CHECK_CONNECTABLE_EVENT = $.Event("CHECK_CONNECTABLE_EVENT"),
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

			if (
				$.inArray(from_node.data('class'), ['AWS.EC2.Instance', 'AWS.AutoScaling.LaunchConfiguration']) > -1 &&
				to_node.data('class') === 'AWS.ELB'
			)
			{
				match_node_offset = match_node.getBoundingClientRect();

				if (event.pageX > (match_node_offset.left + match_node_offset.width / 2))
				{
					to_port_name = 'elb-sg-out';
				}
				if (event.pageX < (match_node_offset.left + match_node_offset.width / 2))
				{
					to_port_name = 'elb-sg-in';
				}
			}
			else
			{
				to_port_name = to_node.find('.connectable-port').data('name');
			}

			if (!from_node.is(to_node) && to_port_name !== undefined)
			{
				// No need to trigger CHECK_CONNECTABLE_EVENT
				// Because the error handling has been implemented
				// in line creation.

				/*
				svg_canvas.trigger(CHECK_CONNECTABLE_EVENT, [from_node.attr('id'), port_name, to_node.attr('id'), to_port_name]);

				if (!CHECK_CONNECTABLE_EVENT.isDefaultPrevented())
				{
					line_id = MC.canvas.connect(from_node, port_name, to_node, to_port_name);

					// trigger event when connect two port
					svg_canvas.trigger("CANVAS_LINE_CREATE", line_id);
				}
				*/

				line_id = MC.canvas.connect(from_node, port_name, to_node, to_port_name);

				// trigger event when connect two port
				svg_canvas.trigger("CANVAS_LINE_CREATE", line_id);
			}
		}

		Canvon('#svg_canvas .connectable').removeClass('connectable');

		Canvon('#svg_canvas .view-keephover').removeClass('view-keephover');

		Canvon('#svg_canvas .view-show').removeClass('view-show');

		Canvon('#svg_canvas .connectable-port').removeClass('connectable-port');

		$('#overlayer').remove();

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
			var target = $(this),
				target_offset = target.offset(),
				svg_canvas = $('#svg_canvas'),
				canvas_offset = svg_canvas.offset(),
				node_type = target.data('type'),
				target_type = target.data('component-type'),
				platform = MC.canvas_data.platform,
				shadow,
				clone_node,
				default_width,
				default_height,
				target_group_type,
				size,
				component_size;

			if (target.data('enable') === false)
			{
				return false;
			}

			$(document.body).append('<div id="drag_shadow"></div><div id="overlayer" class="grabbing"></div>');
			shadow = $('#drag_shadow');

			if (target_type === 'group')
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
				component_size = MC.canvas.COMPONENT_SIZE[ node_type ];

				shadow
					.css({
						'top': event.pageY - 50,
						'left': event.pageX - 50,
						'width': component_size[0] * MC.canvas.GRID_WIDTH,
						'height': component_size[1] * MC.canvas.GRID_HEIGHT
					})
					.show();
			}

			if (node_type === 'AWS.EC2.EBS.Volume')
			{
				if (MC.canvas.getState() === 'appedit')
				{
					Canvon('.AWS-EC2-Instance').addClass('attachable');
				}
				else
				{
					Canvon('.AWS-EC2-Instance, .AWS-AutoScaling-LaunchConfiguration').addClass('attachable');
				}

				shadow.addClass('AWS-EC2-EBS-Volume');

				$(document).on({
					'mousemove': MC.canvas.volume.mousemove,
					'mouseup': MC.canvas.volume.mouseup
				}, {
					'target': target,
					'canvas_offset': svg_canvas.offset(),
					'canvas_body': $('#canvas_body'),
					'shadow': shadow
				});
			}
			else
			{
				target_group_type = MC.canvas.MATCH_PLACEMENT[ platform ][ node_type ];

				if (target_group_type)
				{
					$.each(target_group_type, function (index, item)
					{
						if (item !== 'Canvas')
						{
							Canvon('.' + item.replace(/\./ig, '-')).addClass('dropable-group');
						}
					});
				}

				$(document).on({
					'mousemove': MC.canvas.event.siderbarDrag.mousemove,
					'mouseup': MC.canvas.event.siderbarDrag.mouseup
				}, {
					'target': target,
					'target_type': target_type,
					'canvas_offset': svg_canvas.offset(),
					'node_type': node_type,
					'shadow': shadow,
					'scale_ratio': MC.canvas_property.SCALE_RATIO,
					'component_size': target_type === 'node' ? MC.canvas.COMPONENT_SIZE[ node_type ] : MC.canvas.GROUP_DEFAULT_SIZE[ node_type ]
				});
			}

			$('#canvas_body').addClass('node-dragging');
		}

		MC.canvas.volume.close();
		MC.canvas.event.clearSelected();

		return false;
	},

	mousemove: function (event)
	{
		var event_data = event.data,
			shadow = event_data.shadow[0],
			canvas_offset = event_data.canvas_offset,
			target_id = event_data.target[0].id,
			target_type = event_data.target_type,
			node_type = event_data.node_type,
			component_size = event_data.component_size,

			// MC.canvas.GRID_WIDTH
			grid_width = 10,

			// MC.canvas.GRID_HEIGHT
			grid_height = 10,

			scale_ratio = event_data.scale_ratio,
			coordinate = {
				'x': Math.round((event.pageX - canvas_offset.left - 50) / (grid_width / scale_ratio)),
				'y': Math.round((event.pageY - canvas_offset.top - 50) / (grid_height / scale_ratio))
			},
			match_place = MC.canvas.isMatchPlace(
				null,
				target_type,
				node_type,
				coordinate.x,
				coordinate.y,
				component_size[0],
				component_size[1]
			);

		Canvon('.match-dropable-group').removeClass('match-dropable-group');

		if (match_place.is_matched)
		{
			Canvon('#' + match_place.target).addClass('match-dropable-group');
		}

		shadow.style.top = (event.pageY - 50) + 'px';
		shadow.style.left = (event.pageX - 50) + 'px';

		return false;
	},

	mouseup: function (event)
	{
		if (!$('#canvas_body').hasClass('canvas_zoomed'))
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
				vpc_coordinate,
				areaChild;

			if (coordinate.x > 0 && coordinate.y > 0)
			{
				if (target_type === 'node')
				{
					component_size = MC.canvas.COMPONENT_SIZE[ node_type ];

					if (node_type === 'AWS.VPC.InternetGateway' || node_type === 'AWS.VPC.VPNGateway')
					{
						vpc_id = $('.AWS-VPC-VPC').attr('id');
						vpc_data = MC.canvas_data.layout.component.group[ vpc_id ];
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

							if (new_node)
							{
								MC.canvas.select(new_node.id);
							}
						}
						else
						{
							// dispatch event when is not matched
							$("#svg_canvas").trigger("CANVAS_PLACE_NOT_MATCH", {
								'type': node_type
							});
						}
					}
				}

				if (target_type === 'group')
				{
					default_group_size = MC.canvas.GROUP_DEFAULT_SIZE[ node_type ];

					// Move a little bit offset for Subnet because its port
					if (node_type === 'AWS.VPC.Subnet')
					{
						//coordinate.x -= 1;
					}

					match_place = MC.canvas.isMatchPlace(
						null,
						target_type,
						node_type,
						coordinate.x,
						coordinate.y,
						default_group_size[0],
						default_group_size[1]
					),
					areaChild = MC.canvas.areaChild(
						null,
						target_type,
						coordinate.x,
						coordinate.y,
						coordinate.x + default_group_size[0],
						coordinate.y + default_group_size[1]
					);

					if (
						match_place.is_matched
					)
					{
						if (
							MC.canvas.isBlank(
								'group',
								target_id,
								node_type,
								// Enlarge a little bit to make the drop place correctly.
								coordinate.x - 1,
								coordinate.y - 1,
								default_group_size[0] + 2,
								default_group_size[1] + 2
							) && areaChild.length === 0
						)
						{
							node_option.groupUId = match_place.target;
							new_node = MC.canvas.add(node_type, node_option, coordinate);
							if (!(MC.aws.vpc.getVPCUID() && node_type === "AWS.EC2.AvailabilityZone"))
							{
								//has no vpc
								MC.canvas.select(new_node.id);
							}
						}
						else
						{
							// dispatch event when is not blank
							$("#svg_canvas").trigger("CANVAS_PLACE_OVERLAP");
						}
					}
					else
					{
						// dispatch event when is not matched
						$("#svg_canvas").trigger("CANVAS_PLACE_NOT_MATCH", {
							type: node_type
						});
					}
				}
			}

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
		}
		else
		{
			$("#svg_canvas").trigger("CANVAS_ZOOMED_DROP_ERROR");

			event.data.shadow.remove();
		}

		Canvon('.dropable-group').removeClass('dropable-group');

		Canvon('.match-dropable-group').removeClass('match-dropable-group');

		$('#overlayer').remove();

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
			var target = event.target,
				parent = $(target.parentNode.parentNode),
				group = parent.find('.group'),
				group_offset = group[0].getBoundingClientRect(),
				canvas_offset = $('#svg_canvas').offset(),
				scale_ratio = MC.canvas_property.SCALE_RATIO,
				grid_width = MC.canvas.GRID_WIDTH,
				grid_height = MC.canvas.GRID_HEIGHT,
				group_left = (group_offset.left - canvas_offset.left) * scale_ratio,
				group_top = (group_offset.top - canvas_offset.top) * scale_ratio,
				type = parent.data('class'),
				line_layer = document.getElementById('line_layer'),
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

			// Hide label
			parent.find('.group-label').hide();

			$(document.body).append('<div id="overlayer" style="cursor: ' + $(event.target).css('cursor') + '"></div>');

			$(document)
				.on({
					'mousemove': MC.canvas.event.groupResize.mousemove,
					'mouseup': MC.canvas.event.groupResize.mouseup
				}, {
					'parent': parent,
					'resizer': target,
					'group_title': parent.find('.group-label'),
					'target': group,
					'originalTarget': group[0],
					'group_child': MC.canvas.groupChild(target.parentNode.parentNode),
					'label_offset': MC.canvas.GROUP_LABEL_COORDINATE[ type ],
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
					//'group_border': parseInt(group.css('stroke-width'), 10) * 2,
					'group_type': type,
					'scale_ratio': scale_ratio,
					'group_min_padding': MC.canvas.GROUP_MIN_PADDING,
					'parentGroup': MC.canvas.parentGroup(
						parent.attr('id'),
						parent.data('class'),
						Math.ceil(group_left / grid_width),
						Math.ceil(group_top / grid_height),
						Math.ceil((group_offset.left + group_offset.width) / grid_width),
						Math.ceil((group_offset.top + group_offset.height) / grid_height)
					),
					'group_port': type === 'AWS.VPC.Subnet' ? [
						parent.find('.port-subnet-assoc-in').first(),
						parent.find('.port-subnet-assoc-out').first()
					] : null
				});
		}

		return false;
	},
	mousemove: function (event)
	{
		var event_data = event.data,
			target = event_data.originalTarget,
			direction = event_data.direction,
			type = event_data.group_type,
			//group_border = event_data.group_border,
			scale_ratio = event_data.scale_ratio,
			group_min_padding = event_data.group_min_padding,
			left = Math.ceil((event.pageX - event_data.originalLeft) / 10) * 10 * scale_ratio,
			max_left = event_data.originalWidth * scale_ratio - group_min_padding,
			top = Math.ceil((event.pageY - event_data.originalTop) / 10) * 10 * scale_ratio,
			max_top = event_data.originalHeight * scale_ratio - group_min_padding,
			label_offset = event_data.label_offset,
			prop,
			key;

		switch (direction)
		{
			case 'topleft':
				prop = {
					'y': top > max_top ? max_top : top,
					'x': left > max_left ? max_left : left,
					'width': event_data.originalWidth * scale_ratio - left,
					'height': event_data.originalHeight * scale_ratio - top
				};
				break;

			case 'topright':
				prop = {
					'y': top > max_top ? max_top : top,
					'width': Math.round((event_data.originalWidth + event.pageX - event_data.originalX) / 10) * 10 * scale_ratio,
					'height': event_data.originalHeight * scale_ratio - top
				};
				break;

			case 'bottomleft':
				prop = {
					'x': left > max_left ? max_left : left,
					'width': event_data.originalWidth * scale_ratio - left,
					'height': Math.round((event_data.originalHeight + event.pageY - event_data.originalY) / 10) * 10 * scale_ratio
				};
				break;

			case 'bottomright':
				prop = {
					'width': Math.round((event_data.originalWidth + event.pageX - event_data.originalX) / 10) * 10 * scale_ratio,
					'height': Math.round((event_data.originalHeight + event.pageY - event_data.originalY) / 10) * 10 * scale_ratio
				};
				break;

			case 'top':
				prop = {
					'y': top > max_top ? max_top : top,
					'height': event_data.originalHeight * scale_ratio - top
				};
				break;

			case 'right':
				prop = {
					'width': Math.round((event_data.originalWidth + event.pageX - event_data.originalX) / 10) * 10 * scale_ratio
				};
				break;

			case 'bottom':
				prop = {
					'height': Math.round((event_data.originalHeight + event.pageY - event_data.originalY) / 10) * 10 * scale_ratio
				};
				break;

			case 'left':
				prop = {
					'x': left > max_left ? max_left : left,
					'width': event_data.originalWidth * scale_ratio - left
				};
				break;
		}

		if (prop.width !== undefined && prop.width < group_min_padding)
		{
			prop.width = group_min_padding;
		}

		if (prop.height !== undefined && prop.height < group_min_padding)
		{
			prop.height = group_min_padding;
		}

		// Using baseVal for best performance
		for (key in prop)
		{
			target[ key ].baseVal.value = prop[ key ];
		}

		return false;
	},
	mouseup: function (event)
	{
		var event_data = event.data,
			parent = event_data.parent,
			target = event_data.target,
			type = event_data.group_type,
			group_title = event_data.group_title,
			direction = event_data.direction,
			parent_offset = parent[0].getBoundingClientRect(),
			canvas_offset = event_data.canvas_offset,
			scale_ratio = MC.canvas_property.SCALE_RATIO,
			grid_width = MC.canvas.GRID_WIDTH,
			grid_height = MC.canvas.GRID_HEIGHT,
			offsetX = target.attr('x') * 1,
			offsetY = target.attr('y') * 1,
			group_id = parent.attr('id'),

			group_width = Math.round(target.attr('width') / grid_width),
			group_height = Math.round(target.attr('height') / grid_height),
			group_left = Math.round(((parent_offset.left - canvas_offset.left) * scale_ratio + offsetX) / grid_width),
			group_top = Math.round(((parent_offset.top - canvas_offset.top) * scale_ratio + offsetY) / grid_height),

			layout_node_data = MC.canvas_data.layout.component.node,
			layout_group_data = MC.canvas_data.layout.component.group,
			canvas_size = MC.canvas_data.layout.size,
			node_minX = [],
			node_minY = [],
			node_maxX = [],
			node_maxY = [],
			component_size = MC.canvas.COMPONENT_SIZE,
			group_padding = MC.canvas.GROUP_PADDING,
			parentGroup = event_data.parentGroup,
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

		// adjust group_left
		if (offsetX < 0)
		{
			// when resize by left,topleft, bottomleft
			group_left = Math.round((parent_offset.left - canvas_offset.left) * scale_ratio / grid_width);
		}

		// adjust group_top
		if (
			direction === 'top' ||
			direction === 'topleft' ||
			direction === 'topright'
		)
		{
			if (offsetY < 0)
			{
				group_top = Math.round((parent_offset.top - canvas_offset.top) * scale_ratio / grid_height);
			}
			else if (offsetY > 0)
			{
				group_top = Math.round(((parent_offset.top - canvas_offset.top)  * scale_ratio + offsetY) / grid_width);
			}
		}

		$.each(event_data.group_child, function (index, item)
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

			if (group_left < parent_coordinate[0] + group_padding)
			{
				group_width = group_left + group_width - parent_coordinate[0] - group_padding;
				group_left = parent_coordinate[0] + group_padding;
			}

			if (group_top < parent_coordinate[1] + group_padding)
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
		else
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

			event_data.group_child.length === MC.canvas.areaChild(
				group_id,
				type,
				group_left,
				group_top,
				group_left + group_width,
				group_top + group_height
			).length &&

			// canvas right offset = 3
			group_left + group_width < canvas_size[0] - 3 &&
			group_top + group_height < canvas_size[1] - 3
		)
		{
			if (type === 'AWS.VPC.VPC')
			{
				layout_connection_data = MC.canvas.data.get('layout.connection');

				igw_gateway = $('.AWS-VPC-InternetGateway');
				vgw_gateway = $('.AWS-VPC-VPNGateway');

				if (igw_gateway[0])
				{
					igw_gateway_id = igw_gateway[0].id;
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
					MC.canvas.position(igw_gateway[0],  group_left - 4, igw_top);

					MC.canvas.reConnect(igw_gateway_id);
				}

				if (vgw_gateway[0])
				{
					vgw_gateway_id = vgw_gateway[0].id;
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
					MC.canvas.position(vgw_gateway[0], group_left + group_width - 4, vgw_top);

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

			MC.canvas.updateResizer(parent, group_width, group_height);
		}
		else
		{
			group_width = Math.round(event_data.originalWidth * scale_ratio / 10);
			group_height = Math.round(event_data.originalHeight * scale_ratio / 10);

			parent.attr('transform', event_data.originalTranslate);

			target.attr({
				'x': 0,
				'y': 0,
				'width': event_data.originalWidth * scale_ratio,
				'height': event_data.originalHeight * scale_ratio
			});

			group_title.attr({
				'x': label_coordinate[0],
				'y': label_coordinate[1]
			});
		}

		if (type === 'AWS.VPC.Subnet')
		{
			port_top = (group_height * MC.canvas.GRID_HEIGHT / 2) - 13;

			event_data.group_port[0].attr('transform', 'translate(-10, ' + port_top + ')').show();

			event_data.group_port[1].attr('transform', 'translate(' + (group_width * MC.canvas.GRID_WIDTH + 2) + ', ' + port_top + ')').show();

			// Re-draw group connections
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

		// Show label
		group_title.show();

		$('#overlayer').remove();

		$(document)
			.off({
				'mousemove': MC.canvas.event.groupResize.mousemove,
				'mouseup': MC.canvas.event.groupResize.mouseup
			});
	}
};

MC.canvas.event.ctrlMove = {
	mousedown: function (event)
	{
		if (
			event.which === 1 &&
			event.ctrlKey
		)
		{
			event.stopImmediatePropagation();

			var canvas_offset = $('#svg_canvas').offset(),
				canvas = $('#canvas'),
				scroll_content = canvas.find('.scroll-content').first()[0];

			$(document).on({
				'mousemove': MC.canvas.event.ctrlMove.mousemove,
				'mouseup': MC.canvas.event.ctrlMove.mouseup
			}, {
				'canvas': canvas,
				'offsetX': event.pageX,
				'offsetY': event.pageY,
				'originalCoordinate': {
					'left': scroll_content.realScrollLeft ? scroll_content.realScrollLeft : 0,
					'top': scroll_content.realScrollTop ? scroll_content.realScrollTop : 0
				}
			});

			$(document.body).append('<div id="overlayer" class="grabbing"></div>');

			return false;
		}
	},

	mousemove: function (event)
	{
		var event_data = event.data;

		scrollbar.scrollTo(event_data.canvas, {
			'left': event_data.offsetX - event.pageX - event_data.originalCoordinate.left,
			'top': event_data.offsetY - event.pageY - event_data.originalCoordinate.top
		});

		return false;
	},

	mouseup: function ()
	{
		$('#overlayer').remove();

		$(document).off({
			'mousemove': MC.canvas.event.ctrlMove.mousemove,
			'mouseup': MC.canvas.event.ctrlMove.mouseup
		});
	}
};

MC.canvas.event.EIPstatus = function ()
{
	$("#svg_canvas").trigger("CANVAS_EIP_STATE_CHANGE", {
		'id': this.parentNode.id,
		'eip_state': this.getAttribute('data-eip-state')
	});

	return false;
};

MC.canvas.event.selectLine = function (event)
{
	if (event.which === 1)
	{
		MC.canvas.event.clearSelected();

		MC.canvas.select(this.id);
	}

	return false;
};

MC.canvas.event.selectNode = function (event)
{
	if (event.which === 1)
	{
		// Double click event
		if (MC.canvas.event.dblclick(function ()
		{
			$('#svg_canvas').trigger('SHOW_PROPERTY_PANEL');
		}))
		{
			return false;
		}

		MC.canvas.event.clearSelected();
		MC.canvas.select(this.id);
	}

	return false;
};

MC.canvas.event.appMove = function (event)
{
	if (event.which === 1)
	{
		MC.canvas.event.clearSelected();

		var target = $(this),
			target_type = target.data('class'),
			node_type = target.data('type');

		if (
			target_type === 'AWS.EC2.Instance' ||
			node_type === 'group'
		)
		{
			MC.canvas.event.dragable.mousedown.call( this, event );
		}
		else
		{
			MC.canvas.select( this.id );
		}
	}

	return false;
};

MC.canvas.event.appDrawConnection = function ()
{
	if ($(this).is([
		'.port-instance-sg',
		'.port-eni-sg',
		'.port-launchconfig-sg',
		'.port-elb-sg'
		].join(', ')
	))
	{
		MC.canvas.event.drawConnection.mousedown.call( this, event );
	}

	return false;
};

MC.canvas.event.clearList = function (event)
{
	MC.canvas.instanceList.close();
	MC.canvas.eniList.close();
	MC.canvas.asgList.close();
	MC.canvas.event.clearSelected(event);

	return true;
};

MC.canvas.event.nodeHover = function (event)
{
	if (event.type === 'mouseenter')
	{
		var target = $(this),
			target_id = this.id,
			node_connections = MC.canvas_data.layout.component.node[ target_id ].connection,
			//layout_connection_data = MC.canvas_data.layout.connection,
			i = node_connections.length;

		while ( i-- )
		{
			Canvon('#' + node_connections[ i ].line).addClass('view-hover');
		}
	}

	if (event.type === 'mouseleave')
	{
		Canvon('#svg_canvas .view-hover').removeClass('view-hover');
	}
};

MC.canvas.event.clearSelected = function (event)
{
	// Except for tab switching
	if (event && $(event.currentTarget).is('#tab-bar li'))
	{
		return false;
	}

	Canvon('#svg_canvas .selected').removeClass('selected');

	Canvon('#svg_canvas .view-show').removeClass('view-show');

	MC.canvas_property.selected_node = [];
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

MC.canvas.keypressed = [];

MC.canvas.event.keyEvent = function (event)
{
	var canvas_status = MC.canvas.getState();

	if (
		canvas_status === 'new' ||
		canvas_status === 'app' ||
		canvas_status === 'stack' ||
		canvas_status === 'appedit' ||
		canvas_status === 'appview'
	)
	{
		var keyCode = event.which,
			nodeName = event.target.nodeName.toLowerCase(),
			canvas_status = MC.canvas.getState(),
			//is_zoomed = $('#canvas_body').hasClass('canvas_zoomed'),
			selected_node;

		MC.canvas.keypressed.push(keyCode);

		// Disable key event for input & textarea
		if (
			nodeName === 'input' ||
			nodeName === 'textarea'
		)
		{
			return true;
		}

		// Delete resource - [delete/backspace]
		if (
			(
				keyCode === 46 ||
				// For Mac
				keyCode === 8
			) &&
			(
				canvas_status === 'stack' ||
				canvas_status === 'appedit'
			) &&
			MC.canvas_property.selected_node.length > 0 &&
			event.target === document.body
		)
		{
			MC.canvas.volume.close();
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

		if (
			MC.canvas_property.selected_node.length === 1 &&
			MC.canvas.keypressed.join('').match(/383840403739373966656665$/i)
		)
		{
			if ($('#' + MC.canvas_property.selected_node[ 0 ]).data('type') !== 'node')
			{
				return false;
			}

			var offset = Canvon('#' + MC.canvas_property.selected_node[ 0 ]).offset();

			$(document.body).append('<div id="s"></div>');

			$('#s')
				.text('HP +' + MC.rand(100, 9999))
				.css({
					'border-radius': '4px',
					'padding': '5px 0',
					'background-color': 'rgba(102, 45, 63, 0.8)',
					'font-weight': '700',
					'position': 'absolute',
					'z-index': 999,
					'text-align': 'center',
					'color': 'rgb(252, 232, 244)',
					'font-weigh': 'bold',
					'font-size': 12,
					'width': offset.width,
					'top': offset.top + offset.height / 2 - 15,
					'left': offset.left
				});

			setTimeout(function ()
			{
				$('#s').fadeOut(function () {$(this).remove();});
			}, 1500);

			MC.canvas.keypressed = [];

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
			(
				canvas_status === 'stack' ||
				canvas_status === 'appedit' ||
				canvas_status === 'appview'
			) &&
			MC.canvas_property.selected_node.length === 1 &&
			$('#' + MC.canvas_property.selected_node[ 0 ]).data('type') !== 'line'
		)
		{
			var target = $('#' + MC.canvas_property.selected_node[ 0 ]),
				target_id = MC.canvas_property.selected_node[ 0 ],
				node_type = target.data('class'),
				target_type = target.data('type'),
				target_data = MC.canvas.data.get('layout.component.' + target_type + '.' + target_id),
				canvas_size = MC.canvas.data.get('layout.size'),
				scale_ratio = MC.canvas_property.SCALE_RATIO,
				coordinate = {'x': target_data.coordinate[0], 'y': target_data.coordinate[1]},
				component_size = MC.canvas.COMPONENT_SIZE[ node_type ],
				match_place,
				vpc_id,
				vpc_data,
				vpc_coordinate;

			if (target_type !== 'node')
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
				match_place.is_matched &&

				coordinate.x + component_size[0] < canvas_size[0] - 3 &&
				coordinate.y + component_size[1] < canvas_size[1] - 3
			)
			{
				MC.canvas.position(target[0], coordinate.x, coordinate.y);

				MC.canvas.reConnect(target_id);
			}

			return false;
		}

		// Save stack - [Ctrl + S]
		if (
			event.ctrlKey && keyCode === 83 &&
			canvas_status === 'stack'
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
	}
};

MC.canvas.analysis = function ( data )
{
	console.info(data);
	var component_data = data.component,
		layout_data = data.layout,
		connection_data = data.layout.connection,

		resources = {},
		resource_stack = {},

		elb_child_stack = [],
		elb_connection,

		GROUP_INNER_PADDING = 2,
		GROUP_MARGIN = 2,

		VPC_PADDING_LEFT = 20,
		VPC_PADDING_TOP = 10,
		VPC_PADDING_RIGHT = 8,
		VPC_PADDING_BOTTOM = 5,

		ELB_START_LEFT = 14,
		ELB_SIZE = MC.canvas.COMPONENT_SIZE['AWS.ELB'],

		// Initialize group construction
		SUBGROUP = {
			'AWS.VPC.VPC': ['AWS.EC2.AvailabilityZone'],
			'AWS.EC2.AvailabilityZone': ['AWS.VPC.Subnet'],
			'AWS.VPC.Subnet': [
				'AWS.EC2.Instance',
				'AWS.AutoScaling.Group',
				'AWS.VPC.NetworkInterface'
			],
			'AWS.AutoScaling.Group': ['AWS.AutoScaling.LaunchConfiguration']
		},

		SORT_ORDER = {
			'AWS.AutoScaling.Group': 1,
			'AWS.EC2.Instance': 2,
			'AWS.VPC.NetworkInterface': 3
		},

		GROUP_DEFAULT_SIZE = {
			'AWS.VPC.VPC': [60, 60],
			'AWS.EC2.AvailabilityZone': [17, 17],
			'AWS.VPC.Subnet': [15, 15],
			'AWS.AutoScaling.Group' : [13, 13]
		},

		// For children node order
		POSITION_METHOD = {
			'AWS.VPC.VPC': 'vertical',
			'AWS.EC2.AvailabilityZone': 'horizontal',
			'AWS.VPC.Subnet': 'matrix',
			'AWS.AutoScaling.Group': 'center'
		},

		layout,
		previous_node;

	$.each(data.layout.component.node, function (key, value)
	{
		resources[ key ] = value;
	});

	$.each(data.layout.component.group, function (key, value)
	{
		resources[ key ] = value;
	});

	$.each(resources, function (key, value)
	{
		var type = value.type,
			stack = resource_stack[ type ];

		if (stack === undefined)
		{
			resource_stack[ type ] = [];
		}

		resource_stack[ type ].push(key);
	});

	layout = {
		'id': resource_stack[ 'AWS.VPC.VPC' ][0],
		'coordinate': [5, 3],
		'size': [0, 0],
		'type': 'AWS.VPC.VPC'
	};

	var elb_connection;

	// ELB connected children
	if (resource_stack[ 'AWS.ELB' ] !== undefined)
	{
		$.each(resource_stack[ 'AWS.ELB' ], function (current_index, id)
		{
			elb_connection = layout_data.component.node[ id ].connection;

			$.each(elb_connection, function (i, item)
			{
				if (item.port === 'elb-sg-out')
				{
					elb_child_stack.push( item.target );
				}
			});
		});
	}

	function searchChild(id)
	{
		var children = [],
			target_group = SUBGROUP[ resources[ id ].type ],
			node_data,
			node_child;

		$.each(resources, function (key, value)
		{
			if (
				$.inArray(resources[ key ].type, target_group) > -1 &&
				value.groupUId === id
			)
			{
				node_child = searchChild(key);

				node_data = {
					'id': key,
					'coordinate': [0, 0],
					'size': [0, 0],
					'type': value.type
				};

				if (MC.canvas.COMPONENT_SIZE[ value.type ] !== undefined)
				{
					node_data.size = MC.canvas.COMPONENT_SIZE[ value.type ];
				}

				if (GROUP_DEFAULT_SIZE[ value.type ] !== undefined)
				{
					node_data.size = GROUP_DEFAULT_SIZE[ value.type ];
				}

				if (node_child)
				{
					node_data[ 'children' ] = node_child;
				}

				children.push(node_data);
			}
		});

		return children.length < 1 ? false : children;
	}

	node_child = searchChild( resource_stack[ 'AWS.VPC.VPC' ][0] );

	if (node_child)
	{
		layout[ 'children' ] = node_child;
	}

	function checkChild(node)
	{
		if (node.children !== undefined)
		{
			var count = 0;

			$.each(node.children, function (i, item)
			{
				count += checkChild(item);
			});

			node.totalChild = count + node.children.length;

			if (node.type === 'AWS.VPC.Subnet')
			{
				node.hasELBConnected = false;

				$.each(node.children, function (i, item)
				{
					if ($.inArray(item.id, elb_child_stack) > -1)
					{
						node.hasELBConnected = true;
					}

					if (item.type === 'AWS.AutoScaling.Group')
					{
						if (
							item.children !== undefined &&
							$.inArray(item.children[ 0 ].id, elb_child_stack) > -1
						)
						{
							node.hasELBConnected = true;
						}
					}
				});
			}

			return node.children.length;
		}
		else
		{
			node.totalChild = 0;

			if (node.type === 'AWS.VPC.Subnet')
			{
				node.hasELBConnected = false;
			}

			return 0;
		}
	}

	checkChild( layout );

	function sortChild(node)
	{
		if (node.children !== undefined)
		{
			if (node.type === 'AWS.EC2.AvailabilityZone')
			{
				node.children.sort(function (a, b)
				{
					if (
						(a.hasELBConnected === true && b.hasELBConnected === true)
						||
						(a.hasELBConnected === false && b.hasELBConnected === false)
					)
					{
						return b.totalChild - a.totalChild;
					}
					else
					{
						if (
							a.hasELBConnected === true &&
							b.hasELBConnected === false
						)
						{
							return -1;
						}

						if (
							a.hasELBConnected === false &&
							b.hasELBConnected === true
						)
						{
							return 1;
						}
					}
				});
			}
			else
			{
				node.children.sort(function (a, b)
				{
					return b.totalChild - a.totalChild;
				});
			}

			$.each(node.children, function (i, item)
			{
				sortChild( item );
			});
		}
	}

	sortChild( layout );

	function absPosition(node, x, y)
	{
		node.coordinate[0] += x;
		node.coordinate[1] += y;

		if (node.children !== undefined)
		{
			$.each(node.children, function (i, item)
			{
				absPosition(item, node.coordinate[0], node.coordinate[1]);
			});
		}
	}

	absPosition( layout, 0, 0 );

	function positionSubnetChild(node)
	{
		var stack = {},
			children = node.children,
			length = children.length,
			method = POSITION_METHOD[ node.type ],
			max_width = 0,
			max_height = 0,

			NODE_MARGIN_LEFT = 2,
			NODE_MARGIN_TOP = 2,

			unique_row = {},
			noELBstack = [],

			elb_connected_instance = [],
			normal_instance = [],
			hasUniqueInstanceConnectedToELB = false,

			max_column = Math.ceil( Math.sqrt( length ) ),
			max_row = length === 0 ? 0 : Math.ceil( length / max_column ),
			column_index = 0,
			row_index = 0,

			node_connection,
			hasELBConnected,
			targetELB;

		children.sort(function (a, b)
		{
			return SORT_ORDER[ a.type ] - SORT_ORDER[ b.type ];
		});

		$.each(children, function (current_index, item)
		{
			hasELBConnected = false;
			targetELB = null;

			if (stack[ item.type ] === undefined)
			{
				stack[ item.type ] = [];
			}

			stack[ item.type ].push( item );

			// Check connection
			if (
				(
					item.type === 'AWS.AutoScaling.Group' ||
					item.type === 'AWS.EC2.Instance'
				) &&
				item.children !== undefined
			)
			{
				node_connection = resources[ item.children[ 0 ].id ].connection;	
			}
			else
			{
				node_connection = resources[ item.id ].connection;
			}

			if (node_connection)
			{
				$.each(node_connection, function (i, data)
				{
					if (resources[ data.target ].type === 'AWS.ELB')
					{
						if (connection_data[ data.line ].target[ data.target ] === 'elb-sg-out')
						{
							hasELBConnected = true;
							targetELB = data.target;
						}
					}
				});

				if (hasELBConnected)
				{
					if (unique_row[ targetELB ] === undefined)
					{
						unique_row[ targetELB ] = [];
					}

					unique_row[ targetELB ].push( item );
				}
				else
				{
					if (item.type === 'AWS.AutoScaling.Group')
					{
						noELBstack.push( item );
					}
				}
			}
			else
			{
				if (item.type === 'AWS.AutoScaling.Group')
				{
					noELBstack.push( item );
				}
			}
		});

		var column_count = 0,
			row_width = 0,
			row_top = 0,
			left_padding = 0,
			row_index,

			// Range
			ASG_WIDTH = 15,
			ASG_HEIGHT = 15,
			INSTANCE_WIDTH = 11,
			INSTANCE_HEIGHT = 11;

		if (noELBstack.length > 0)
		{
			unique_row[ 'zz' ] = noELBstack;
		}

		$.each(unique_row, function (row, row_stack)
		{
			row_top = 0;

			row_stack.sort(function (a, b)
			{
				return SORT_ORDER[ a.type ] - SORT_ORDER[ b.type ];
			});

			$.each(row_stack, function (row_index, item)
			{
				if (item.type === 'AWS.AutoScaling.Group')
				{
					row_width = ASG_WIDTH;

					item.coordinate = [
						left_padding + 2,
						row_top + GROUP_INNER_PADDING
					];

					row_top += ASG_HEIGHT;

					if (item.children !== undefined)
					{
						positionChild( item );
					}
				}

				if (item.type === 'AWS.EC2.Instance')
				{
					row_width = row_width === ASG_WIDTH ? ASG_WIDTH : INSTANCE_WIDTH;

					item.coordinate = [
						// Adjust instance x axis with ASG (+2)
						left_padding + (row_width === ASG_WIDTH ? 4 : 2),
						// Adjust instance y axis with ASG (+4)
						row_top + GROUP_INNER_PADDING
					];

					row_top += INSTANCE_HEIGHT;
				}
			});

			column_count++;

			left_padding += row_width;
		})

		if (stack[ 'AWS.EC2.Instance' ] !== undefined)
		{
			$.each(stack[ 'AWS.EC2.Instance' ], function (i, item)
			{
				if ($.inArray(item.id, elb_child_stack) === -1)
				{
					normal_instance.push( item );
				}
			});

			normal_instance.sort(function (a, b)
			{
				return MC.canvas_data.component[ a.id ].name.localeCompare( MC.canvas_data.component[ b.id ].name );
			});
		}

		if (normal_instance.length > 0)
		{
			var childLength = normal_instance.length,
				max_child_column = Math.ceil( Math.sqrt( childLength ) ),
				max_child_row = childLength === 0 ? 0 : Math.ceil( childLength / max_child_column ),
				column_index = 0,
				row_index = 0;

			$.each(normal_instance, function (i, item)
			{
				if (column_index >= max_child_column)
				{
					column_index = 0;
					row_index++;
				}

				item.coordinate = [
					column_index * 9 + (column_index * NODE_MARGIN_LEFT) + GROUP_INNER_PADDING,
					row_index * 9 + (row_index * NODE_MARGIN_LEFT) + GROUP_INNER_PADDING
				];

				column_index++;
			});

			$.each(normal_instance, function (i, item)
			{
				item.coordinate[0] += left_padding;
			});

			left_padding += max_child_column * INSTANCE_WIDTH;
		}

		if (stack[ 'AWS.VPC.NetworkInterface' ] !== undefined)
		{
			var childLength = stack[ 'AWS.VPC.NetworkInterface' ].length,
				max_child_column = Math.ceil( Math.sqrt( childLength ) ),
				max_child_row = childLength === 0 ? 0 : Math.ceil( childLength / max_child_column ),
				eni_padding = 0,
				column_index = 0,
				row_index = 0;

			$.each(stack[ 'AWS.VPC.NetworkInterface' ], function (i, item)
			{
				if (column_index >= max_child_column)
				{
					column_index = 0;
					row_index++;
				}

				item.coordinate = [
					column_index * 9 + (column_index * NODE_MARGIN_LEFT) + eni_padding + GROUP_INNER_PADDING,
					row_index * 9 + (row_index * NODE_MARGIN_LEFT) + GROUP_INNER_PADDING
				];

				column_index++;
			});
		}

		if (stack[ 'AWS.VPC.NetworkInterface' ] !== undefined)
		{
			$.each(stack[ 'AWS.VPC.NetworkInterface' ], function (i, item)
			{
				item.coordinate[0] += left_padding;
			});
		}

		var max_width = 0,
			max_height = 0,
			item_coordinate,
			component_size;

		$.each(children, function (i, item)
		{
			item_coordinate = item.coordinate;

			component_size = MC.canvas.COMPONENT_SIZE[ item.type ];

			if (item_coordinate[0] + component_size[0] > max_width)
			{
				max_width = item_coordinate[0] + component_size[0];
			}

			if (item_coordinate[1] + component_size[1] > max_height)
			{
				max_height = item_coordinate[1] + component_size[1];
			}
		});

		node.size = [
			max_width + GROUP_INNER_PADDING,
			max_height + GROUP_INNER_PADDING
		];
	}

	function sortSubnet( children )
	{
		var internetELBconnected = [],
			internalELBconnected = [],
			normalSubnet = [],

			isInternetELBconnected,
			isInternalELBconnected,

			layout_component_data = MC.canvas_data.

			elb_type,
			item_connection;

		$.each(children, function (i, item)
		{
			isInternetELBconnected = false;
			isInternalELBconnected = false;

			if (item.children !== undefined)
			{
				$.each(item.children, function (index, node)
				{
					if (
						node.type === 'AWS.AutoScaling.Group' &&
						node.children !== undefined
					)
					{
						node = node.children[ 0 ];
					}

					node_connection = resources[ node.id ].connection;

					if (node_connection)
					{
						$.each(node_connection, function (index, data)
						{
							if (resources[ data.target ].type === 'AWS.ELB')
							{
								elb_type = component_data[ data.target ].resource.Scheme;

								if (elb_type === 'internet-facing')
								{
									isInternetELBconnected = true;
								}

								if (elb_type === 'internal')
								{
									isInternalELBconnected = true;
								}
							}
						});
					}
				});

				if (isInternetELBconnected)
				{
					internetELBconnected.push( item );
				}
				else if (isInternalELBconnected)
				{
					internalELBconnected.push( item );
				}
			}

			if (!isInternetELBconnected && !isInternalELBconnected)
			{
				normalSubnet.push( item );
			}
		});

		internetELBconnected.sort(function (a, b)
		{
			return b.totalChild - a.totalChild;
		});

		internetELBconnected.sort(function (a, b)
		{
			return b.totalChild - a.totalChild;
		});

		normalSubnet.sort(function (a, b)
		{
			if (
				b.totalChild === a.totalChild &&
				(
					b.totalChild > 0 &&
					a.totalChild > 0
				)
			)
			{
				var weight = {
						'a': 0,
						'b': 0
					};

				$.each({"a": a, "b": b}, function (key, value)
				{
					$.each(value.children, function (i, item)
					{
						if (item.type === 'AWS.AutoScaling.Group')
						{
							weight[ key ] += 3;
						}

						if (item.type === 'AWS.EC2.Instance')
						{
							weight[ key ] += 2;
						}

						if (item.type === 'AWS.VPC.NetworkInterface')
						{
							weight[ key ] += 1;
						}
					});
				});

				return weight.b - weight.a;
			}
			else
			{
				return b.totalChild - a.totalChild;
			}
		});

		children = internetELBconnected.concat(internalELBconnected, normalSubnet);

		return children;
	}

	function positionChild(node)
	{
		var children = node.children,
			GROUP_MARGIN = 2,

			length = children.length,
			method = POSITION_METHOD[ node.type ],
			max_width = 0,
			max_height = 0,

			NODE_MARGIN_LEFT = 2,
			NODE_MARGIN_TOP = 2;

		if (node.type === 'AWS.EC2.AvailabilityZone')
		{
			GROUP_MARGIN = 4;
		}

		if (method === 'matrix')
		{
			positionSubnetChild(node);
		}

		if (method === 'vertical')
		{
			$.each(children, function (current_index, item)
			{
				item.coordinate = [
					0 + GROUP_INNER_PADDING,
					current_index + GROUP_INNER_PADDING
				];

				if (item.children !== undefined)
				{
					positionChild( item );
				}

				if (item.size[0] > max_width)
				{
					max_width = item.size[0];
				}

				max_height += item.size[1];

				if (current_index > 0)
				{
					previous_node = children[ current_index - 1 ];
					item.coordinate = [
						0 + GROUP_INNER_PADDING,
						previous_node.size[1] + previous_node.coordinate[1] + GROUP_MARGIN
					];

					max_height += GROUP_MARGIN * 2;
				}
			});

			node.size = [
				max_width + (GROUP_INNER_PADDING * 2),
				max_height + (GROUP_MARGIN * (length - 1)) + GROUP_INNER_PADDING
			];
		}

		if (method === 'horizontal')
		{
			if (node.type === 'AWS.EC2.AvailabilityZone')
			{
				children = sortSubnet( children );
			}

			$.each(children, function (current_index, item)
			{
				item.coordinate = [
					current_index + GROUP_INNER_PADDING,
					0 + GROUP_INNER_PADDING
				];

				if (item.children !== undefined)
				{
					positionChild( item );
				}

				if (item.size[1] > max_height)
				{
					max_height = item.size[1];
				}

				max_width += item.size[0];

				if (current_index > 0)
				{
					previous_node = children[ current_index - 1 ];
					item.coordinate = [
						previous_node.size[0] + previous_node.coordinate[0] + GROUP_MARGIN,
						0 + GROUP_INNER_PADDING
					];

					max_width += GROUP_MARGIN * 2;
				}
			});

			node.size = [
				max_width - (GROUP_MARGIN * (length - 1)) + (GROUP_INNER_PADDING * 2),
				max_height + (GROUP_INNER_PADDING * 2)
			];
		}

		if (method === 'center')
		{
			$.each(children, function (current_index, item)
			{
				item.coordinate = [2, 2];
			});

			node.size = [13, 13];
		}
	}

	if (layout.children)
	{
		positionChild( layout );
	}

	// VPC padding
	if (layout.children)
	{
		$.each(layout.children, function (i, item)
		{
			item.coordinate[0] += VPC_PADDING_LEFT;
			item.coordinate[1] += VPC_PADDING_TOP;
		});
	}

	// RouteTable
	if (resource_stack[ 'AWS.VPC.RouteTable' ] !== undefined)
	{
		var ROUTE_TABLE_START_LEFT = 15,
			ROUTE_TABLE_START_TOP = 5,
			ROUTE_TABLE_MARGIN = 4,
			ROUTE_TABLE_SIZE = MC.canvas.COMPONENT_SIZE['AWS.VPC.RouteTable'],
			RT_to_IGW = [],
			RT_to_VGW = [],
			RT_other = [],
			RT_prefer,
			RT_connection,
			RT_connect_target;

		if (resource_stack[ 'AWS.VPC.RouteTable' ].length > 0)
		{
			resource_stack[ 'AWS.VPC.RouteTable' ].sort(function (a, b)
			{
				return MC.canvas_data.component[ a ].name.localeCompare( MC.canvas_data.component[ b ].name );
			});

			$.each(resource_stack[ 'AWS.VPC.RouteTable' ], function (index, id)
			{
				RT_prefer = false;
				RT_connection = layout_data.component.node[ id ].connection;

				$.each(RT_connection, function (i, data)
				{
					if (data.port === 'rtb-tgt')
					{
						RT_connect_target = layout_data.component.node[ data.target ].type;

						if (RT_connect_target === 'AWS.VPC.InternetGateway')
						{
							RT_prefer = true;
							RT_to_IGW.push( id );
						}

						if (RT_connect_target === 'AWS.VPC.VPNGateway')
						{
							RT_prefer = true;
							RT_to_VGW.push( id );
						}

					}
				});

				if (RT_prefer === false)
				{
					RT_other.push( id );
				}
			});

			// RT Children join
			resource_stack[ 'AWS.VPC.RouteTable' ] = _.unique( RT_to_IGW.concat(RT_to_VGW, RT_other) );

			$.each(resource_stack[ 'AWS.VPC.RouteTable' ], function (current_index, id)
			{
				resources[ id ].coordinate = [
					(current_index + 1) * ROUTE_TABLE_SIZE[0] + ((current_index + 1) * ROUTE_TABLE_MARGIN) + ROUTE_TABLE_START_LEFT,
					ROUTE_TABLE_START_TOP
				];
			});
		}
	}

	// Add AZ margin for ELB
	var elb_stack = layout.children,
		max_first_height = 0;

	if (
		elb_stack !== undefined &&
		elb_stack.length > 1 &&
		resource_stack[ 'AWS.ELB' ] !== undefined
	)
	{
		// var i = 1,
		// 	l = elb_stack.length;

		// for ( ; i < l ; i++ )
		// {
		// 	elb_stack[ i ].coordinate[ 1 ] += 15;
		// }

		max_first_height = elb_stack[ 0 ].coordinate[ 1 ] + elb_stack[ 0 ].size[ 1 ];

		if (elb_stack[ 2 ])
		{
			if (elb_stack[ 2 ].size[ 1 ] > elb_stack[ 0 ].size[ 1 ])
			{
				elb_stack[ 2 ].coordinate = [
					elb_stack[ 0 ].coordinate[ 0 ] + elb_stack[ 0 ].size[ 0 ] + 5,
					elb_stack[ 0 ].coordinate[ 1 ]
				];

				elb_stack[ 0 ].coordinate = [
					elb_stack[ 0 ].coordinate[ 0 ],
					elb_stack[ 0 ].coordinate[ 1 ] + (elb_stack[ 2 ].size[ 1 ] - elb_stack[ 0 ].size[ 1 ]) / 2
				];

				max_first_height = elb_stack[ 2 ].coordinate[ 1 ] + elb_stack[ 2 ].size[ 1 ];
			}
			else
			{
				elb_stack[ 2 ].coordinate = [
					elb_stack[ 0 ].coordinate[ 0 ] + elb_stack[ 0 ].size[ 0 ] + 5,
					elb_stack[ 0 ].coordinate[ 1 ] + elb_stack[ 0 ].size[ 1 ] - elb_stack[ 2 ].size[ 1 ]
				];
			}
		}

		if (elb_stack[ 1 ])
		{
			elb_stack[ 1 ].coordinate[ 1 ] = max_first_height + 15;
		}

		if (elb_stack[ 3 ])
		{
			elb_stack[ 3 ].coordinate = [
				elb_stack[ 1 ].coordinate[ 0 ] + elb_stack[ 1 ].size[ 0 ] + 5,
				elb_stack[ 1 ].coordinate[ 1 ]
			];
		}
	}

	// ELB
	if (resource_stack[ 'AWS.ELB' ] !== undefined)
	{
		resource_stack[ 'AWS.ELB' ].sort(function (a, b)
		{
			return component_data[ b ].resource.Scheme.localeCompare( component_data[ a ].resource.Scheme );
		});

		if (elb_stack.length > 1)
		{
			$.each(resource_stack[ 'AWS.ELB' ], function (current_index, id)
			{
				resources[ id ].coordinate = [
					ELB_START_LEFT + (current_index * 10) + (current_index * 10),
					max_first_height + 5
				];
			});
		}
		else
		{
			$.each(resource_stack[ 'AWS.ELB' ], function (current_index, id)
			{
				resources[ id ].coordinate = [
					ELB_START_LEFT,
					elb_stack[ 0 ].coordinate[ 0 ] + (elb_stack[ 0 ].size[ 1 ] / 2 - 5) + current_index * 10
				];
			});
		}
	}

	function absPosition(node, x, y)
	{
		var coordinate = node.coordinate;

		coordinate[0] += x;
		coordinate[1] += y;

		if (node.children !== undefined)
		{
			$.each(node.children, function (i, item)
			{
				absPosition(item, coordinate[0], coordinate[1]);
			});
		}
	}

	function updateLayoutData(node)
	{
		var resource = resources[ node.id ];

		resource.coordinate = node.coordinate;

		if (resource.size !== undefined)
		{
			resource.size = node.size;
		}

		if (node.children !== undefined)
		{
			$.each(node.children, function (i, item)
			{
				updateLayoutData( item );
			});
		}
	}

	absPosition( layout, 0, 0 );

	function VPCsize()
	{
		var VPC_max_width = 0,
			VPC_max_height = 0,
			layout_data = data.layout.component,
			ignore_type = ['AWS.VPC.CustomerGateway', 'AWS.VPC.InternetGateway', 'AWS.VPC.VPNGateway'],
			component_size,
			group_size,
			item_type;

		$.each(layout_data.node, function (i, item)
		{
			if ($.inArray(item.type, ignore_type) === -1)
			{
				component_size = MC.canvas.COMPONENT_SIZE[ item.type ];

				if (item.coordinate[0] + component_size[0] > VPC_max_width)
				{
					VPC_max_width = item.coordinate[0] + component_size[0];
				}

				if (item.coordinate[1] + component_size[1] > VPC_max_height)
				{
					VPC_max_height = item.coordinate[1] + component_size[1];
				}
			}
		});

		$.each(layout_data.group, function (i, item)
		{
			group_size = item.size;

			if (item.type !== 'AWS.AutoScaling.Group')
			{
				if (item.coordinate[0] + group_size[0] > VPC_max_width)
				{
					VPC_max_width = item.coordinate[0] + group_size[0];
				}

				if (item.coordinate[1] + group_size[1] > VPC_max_height)
				{
					VPC_max_height = item.coordinate[1] + group_size[1];
				}
			}
		});

		layout.size[0] = VPC_max_width - layout.coordinate[0] + VPC_PADDING_RIGHT;
		layout.size[1] = VPC_max_height - layout.coordinate[1] + VPC_PADDING_BOTTOM;
	}

	updateLayoutData( layout );

	VPCsize();

	// IGW & VGW
	if (resource_stack[ 'AWS.VPC.InternetGateway' ] !== undefined)
	{
		resources[ resource_stack[ 'AWS.VPC.InternetGateway' ][ 0 ] ].coordinate = [
			layout.coordinate[0] - 4,
			layout.coordinate[1] + (layout.size[1] / 2) - 4
		];
	}

	if (resource_stack[ 'AWS.VPC.VPNGateway' ] !== undefined)
	{
		resources[ resource_stack[ 'AWS.VPC.VPNGateway' ][ 0 ] ].coordinate = [
			layout.coordinate[0] + layout.size[0] - 4,
			layout.coordinate[1] + (layout.size[1] / 2) - 4
		];
	}

	// CGW
	if (resource_stack[ 'AWS.VPC.CustomerGateway' ] !== undefined)
	{
		$.each(resource_stack[ 'AWS.VPC.CustomerGateway' ], function (i, item)
		{
			resources[ item ].coordinate = [
				layout.coordinate[0] + layout.size[0] + 8,
				layout.coordinate[1] + (i * 11) + (layout.size[1] / 2) - 5
			];
		});
	}

	// Canvas size
	var canvas_width = layout.size[ 0 ] + 80,
		canvas_height = layout.size[ 1 ] + 50;

	MC.canvas_data.layout.size = [
		canvas_width < 180 ? 180 : canvas_width,
		canvas_height < 150 ? 150 : canvas_height
	];

	console.info(layout);

	return true;
};




/* Blob.js
 * A Blob implementation.
 * 2013-06-20
 *
 * By Eli Grey, http://eligrey.com
 * By Devin Samarin, https://github.com/eboyjr
 * License: X11/MIT
 *   See LICENSE.md
 */

/*global self, unescape */
/*jslint bitwise: true, regexp: true, confusion: true, es5: true, vars: true, white: true,
  plusplus: true */

/*! @source http://purl.eligrey.com/github/Blob.js/blob/master/Blob.js */
if (!(typeof Blob === "function" || typeof Blob === "object") || typeof URL === "undefined")
if ((typeof Blob === "function" || typeof Blob === "object") && typeof webkitURL !== "undefined") (self || window).URL = webkitURL;
else var Blob = (function (view) {
  "use strict";

  var BlobBuilder = view.BlobBuilder || view.WebKitBlobBuilder || view.MozBlobBuilder || view.MSBlobBuilder || (function(view) {
    var
        get_class = function(object) {
        return Object.prototype.toString.call(object).match(/^\[object\s(.*)\]$/)[1];
      }
      , FakeBlobBuilder = function BlobBuilder() {
        this.data = [];
      }
      , FakeBlob = function Blob(data, type, encoding) {
        this.data = data;
        this.size = data.length;
        this.type = type;
        this.encoding = encoding;
      }
      , FBB_proto = FakeBlobBuilder.prototype
      , FB_proto = FakeBlob.prototype
      , FileReaderSync = view.FileReaderSync
      , FileException = function(type) {
        this.code = this[this.name = type];
      }
      , file_ex_codes = (
          "NOT_FOUND_ERR SECURITY_ERR ABORT_ERR NOT_READABLE_ERR ENCODING_ERR "
        + "NO_MODIFICATION_ALLOWED_ERR INVALID_STATE_ERR SYNTAX_ERR"
      ).split(" ")
      , file_ex_code = file_ex_codes.length
      , real_URL = view.URL || view.webkitURL || view
      , real_create_object_URL = real_URL.createObjectURL
      , real_revoke_object_URL = real_URL.revokeObjectURL
      , URL = real_URL
      , btoa = view.btoa
      , atob = view.atob

      , ArrayBuffer = view.ArrayBuffer
      , Uint8Array = view.Uint8Array
    ;
    FakeBlob.fake = FB_proto.fake = true;
    while (file_ex_code--) {
      FileException.prototype[file_ex_codes[file_ex_code]] = file_ex_code + 1;
    }
    if (!real_URL.createObjectURL) {
      URL = view.URL = {};
    }
    URL.createObjectURL = function(blob) {
      var
          type = blob.type
        , data_URI_header
      ;
      if (type === null) {
        type = "application/octet-stream";
      }
      if (blob instanceof FakeBlob) {
        data_URI_header = "data:" + type;
        if (blob.encoding === "base64") {
          return data_URI_header + ";base64," + blob.data;
        } else if (blob.encoding === "URI") {
          return data_URI_header + "," + decodeURIComponent(blob.data);
        } if (btoa) {
          return data_URI_header + ";base64," + btoa(blob.data);
        } else {
          return data_URI_header + "," + encodeURIComponent(blob.data);
        }
      } else if (real_create_object_URL) {
        return real_create_object_URL.call(real_URL, blob);
      }
    };
    URL.revokeObjectURL = function(object_URL) {
      if (object_URL.substring(0, 5) !== "data:" && real_revoke_object_URL) {
        real_revoke_object_URL.call(real_URL, object_URL);
      }
    };
    FBB_proto.append = function(data/*, endings*/) {
      var bb = this.data;
      // decode data to a binary string
      if (Uint8Array && (data instanceof ArrayBuffer || data instanceof Uint8Array)) {
        var
            str = ""
          , buf = new Uint8Array(data)
          , i = 0
          , buf_len = buf.length
        ;
        for (; i < buf_len; i++) {
          str += String.fromCharCode(buf[i]);
        }
        bb.push(str);
      } else if (get_class(data) === "Blob" || get_class(data) === "File") {
        if (FileReaderSync) {
          var fr = new FileReaderSync;
          bb.push(fr.readAsBinaryString(data));
        } else {
          // async FileReader won't work as BlobBuilder is sync
          throw new FileException("NOT_READABLE_ERR");
        }
      } else if (data instanceof FakeBlob) {
        if (data.encoding === "base64" && atob) {
          bb.push(atob(data.data));
        } else if (data.encoding === "URI") {
          bb.push(decodeURIComponent(data.data));
        } else if (data.encoding === "raw") {
          bb.push(data.data);
        }
      } else {
        if (typeof data !== "string") {
          data += ""; // convert unsupported types to strings
        }
        // decode UTF-16 to binary string
        bb.push(unescape(encodeURIComponent(data)));
      }
    };
    FBB_proto.getBlob = function(type) {
      if (!arguments.length) {
        type = null;
      }
      return new FakeBlob(this.data.join(""), type, "raw");
    };
    FBB_proto.toString = function() {
      return "[object BlobBuilder]";
    };
    FB_proto.slice = function(start, end, type) {
      var args = arguments.length;
      if (args < 3) {
        type = null;
      }
      return new FakeBlob(
          this.data.slice(start, args > 1 ? end : this.data.length)
        , type
        , this.encoding
      );
    };
    FB_proto.toString = function() {
      return "[object Blob]";
    };
    return FakeBlobBuilder;
  }(view));

  return function Blob(blobParts, options) {
    var type = options ? (options.type || "") : "";
    var builder = new BlobBuilder();
    if (blobParts) {
      for (var i = 0, len = blobParts.length; i < len; i++) {
        builder.append(blobParts[i]);
      }
    }
    return builder.getBlob(type);
  };
}(window));

/* canvas-toBlob.js
 * A canvas.toBlob() implementation.
 * 2011-07-13
 *
 * By Eli Grey, http://eligrey.com and Devin Samarin, https://github.com/eboyjr
 * License: X11/MIT
 *   See LICENSE.md
 */

/*global self */
/*jslint bitwise: true, regexp: true, confusion: true, es5: true, vars: true, white: true,
  plusplus: true */

/*! @source http://purl.eligrey.com/github/canvas-toBlob.js/blob/master/canvas-toBlob.js */

(function(view) {
"use strict";
var
    Uint8Array = view.Uint8Array
  , HTMLCanvasElement = view.HTMLCanvasElement
  , is_base64_regex = /\s*;\s*base64\s*(?:;|$)/i
  , base64_ranks
  , decode_base64 = function(base64) {
    var
        len = base64.length
      , buffer = new Uint8Array(len / 4 * 3 | 0)
      , i = 0
      , outptr = 0
      , last = [0, 0]
      , state = 0
      , save = 0
      , rank
      , code
      , undef
    ;
    while (len--) {
      code = base64.charCodeAt(i++);
      rank = base64_ranks[code-43];
      if (rank !== 255 && rank !== undef) {
        last[1] = last[0];
        last[0] = code;
        save = (save << 6) | rank;
        state++;
        if (state === 4) {
          buffer[outptr++] = save >>> 16;
          if (last[1] !== 61 /* padding character */) {
            buffer[outptr++] = save >>> 8;
          }
          if (last[0] !== 61 /* padding character */) {
            buffer[outptr++] = save;
          }
          state = 0;
        }
      }
    }
    // 2/3 chance there's going to be some null bytes at the end, but that
    // doesn't really matter with most image formats.
    // If it somehow matters for you, truncate the buffer up outptr.
    return buffer.buffer;
  }
;
if (Uint8Array) {
  base64_ranks = new Uint8Array([
      62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1
    , -1, -1,  0, -1, -1, -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9
    , 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25
    , -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35
    , 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51
  ]);
}
if (HTMLCanvasElement && !HTMLCanvasElement.prototype.toBlob) {
  HTMLCanvasElement.prototype.toBlob = function(callback, type /*, ...args*/) {
      if (!type) {
      type = "image/png";
    } if (this.mozGetAsFile) {
      callback(this.mozGetAsFile("canvas", type));
      return;
    }
    var
        args = Array.prototype.slice.call(arguments, 1)
      , dataURI = this.toDataURL.apply(this, args)
      , header_end = dataURI.indexOf(",")
      , data = dataURI.substring(header_end + 1)
      , is_base64 = is_base64_regex.test(dataURI.substring(0, header_end))
      , blob
    ;
    if (Blob.fake) {
      // no reason to decode a data: URI that's just going to become a data URI again
      blob = new Blob
      if (is_base64) {
        blob.encoding = "base64";
      } else {
        blob.encoding = "URI";
      }
      blob.data = data;
      blob.size = data.length;
    } else if (Uint8Array) {
      if (is_base64) {
        blob = new Blob([decode_base64(data)], {type: type});
      } else {
        blob = new Blob([decodeURIComponent(data)], {type: type});
      }
    }
    callback(blob, dataURI);
  };
}
}(window));

MC.canvas.exportPNG = function ( $svg_canvas_element, data )
{

	/*
	data = {
		isExport   : boolean
		createBlob : false
		drawInfo   : true
		onFinish   : function (required)
		name       : string
	}
	*/

	if ( !data.onFinish ) { return; }
	// Prepare grid background
	if ( !MC.canvas.exportPNG.bg )
	{
		var img = document.createElement("img");
		img.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAIAAAACUFjqAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAHUlEQVQYV2P48ePHf9yAgabSHz9+/I4bENI9gNIA0iYpJd74eOIAAAAASUVORK5CYII=";
		MC.canvas.exportPNG.bg = img;

		$("<div id='export-png-wrap'></div>").appendTo("body").hide();
	}


	var svg_canvas_element = $svg_canvas_element[0];
	var size               = svg_canvas_element.getBBox();
	var clone              = svg_canvas_element.cloneNode( true );
	var beforeRender       = null;
	var line               = clone.getElementById("svg_padding_line");

	// cloneNode won't clone the xmlns:xlink attribute
	clone.setAttribute( "xmlns:xlink", "http://www.w3.org/1999/xlink" );
	clone.removeAttribute( "id" );

	// Insert the document so that we can calculate the style.
	$("#export-png-wrap")
		.append( clone )
		.attr("class", $("#canvas_container").attr("class"));

	// Inline styles
	var removeArray = [ clone ]; /// Detach the clone from document.
	var children = clone.children || clone.childNodes;
	for ( var i = 0; i < children.length; ++i ) {
		if ( !children[i].tagName ) { continue; }
		MC.canvas.exportPNG.fixSVG( children[i], removeArray );
	}
	// Remove unnecessary elements
	if ( removeArray[i].remove ) {
		for ( i = 0; i < removeArray.length; ++i ) {
			removeArray[i].remove();
		}
	} else {
		for ( i = 0; i < removeArray.length; ++i ) {
			removeArray[i].parentNode.removeChild( removeArray[i] );
		}
	}

	// Prepare to insert header for Exporting Image
	if ( data.isExport ) {
		var replaceEl = document.createElementNS("http://www.w3.org/2000/svg", "g");
		replaceEl.textContent = "PLACEHOLDER";
		// We use canvg's translate instead of calling context.translate()
		// because context.translate seems a little bit slow.
		replaceEl.setAttribute("transform","translate(0 54)");
		clone.insertBefore( replaceEl, line );
	}

	// Remove a line that is useless
	clone.removeChild(line);

	// Generate svg text, and remove data attributes
	var svg = (new XMLSerializer()).serializeToString( clone )
							.replace(/data-[^=]+="[^"]*?"/g, "");

	// Insert header
	if ( data.isExport ) {
		if ( MC.canvas.exportPNG.href === undefined ) {
			// In IE, XMLSerializer will change xlink:href to href
			MC.canvas.exportPNG.href = svg.indexOf("xlink:href") == -1 ? "href" : "xlink:href";
		}

		var time = "";
		var name = "";
		if ( data.drawInfo !== false ) {
			time = MC.dateFormat( new Date(), 'yyyy-MM-dd hh:mm:ss' );
			name = data.name;
		}

		var head = '<rect fill="#ad5992" width="100%" height="4" y="-54"></rect><rect fill="#252526" width="100%" height="50" y="-50"></rect><image ' + MC.canvas.exportPNG.href + '="./assets/images/ide/logo-t.png" x="10" y="-42" width="160" height="34"></image><text x="100%" y="-27" fill="#fff" text-anchor="end" transform="translate(-10 0)">' + time + '</text><text fill="#fff" x="100%" y="-13" text-anchor="end" transform="translate(-10 0)">' + name + '</text>';

		svg = svg.replace("PLACEHOLDER</g>", head).replace("</svg>", "</g></svg>");
	}

	// Calc the size for the canvas
	// In IE, getBBox returns SvgRect which is not allowed to modified.
	size = { width : size.width + 50, height : size.height + 30 };

	// Calc the perfect size
	if ( data.isExport ) {
		size.height += 54;

		if ( size.width  < 360 ) { size.width  = 360; }
		if ( size.height < 380 ) { size.height = 380; }

		beforeRender = function( ctx ){
			var pat = ctx.createPattern( MC.canvas.exportPNG.bg, 'repeat' );
			ctx.fillStyle = pat;
			ctx.fillRect(0, 54, size.width, size.height-54);
		}
	} else {
		beforeRender = function( ctx ){
			var ratio1 = 220 / size.width;
			var ratio2 = 145 / size.height;
			var ratio  = ratio1 <= ratio2 ? ratio2 : ratio1;

			var pattern = document.createElement('canvas');
			pattern.width  = size.width;
			pattern.height = size.height;

			size.width  = 220;
			size.height = 145;

			patternctx = pattern.getContext("2d");

			patternctx.fillStyle = patternctx.createPattern( MC.canvas.exportPNG.bg, 'repeat' );
			patternctx.fillRect(0, 0, pattern.width, pattern.height);

			ctx.scale( ratio, ratio );
			ctx.drawImage( pattern, 0, 0, pattern.width, pattern.height );
		}
	}

	// Draw
	var canvas = document.createElement('canvas');
	canvas.width  = size.width;
	canvas.height = size.height;
	canvg( canvas, svg, {
		beforeRender : beforeRender,
		afterRender  : function() {

			onFinish = data.onFinish;
			data.onFinish = null;

			if ( data.createBlob === true ) {
				canvas.toBlob(function( blob, possibleDataURL ){

					if ( typeof possibleDataURL === "string" ) {
						// We are using an 3rd party implementation of toBlob
						// And we get the DataURL.
						data.image = possibleDataURL;
					} else {
						data.image = canvas.toDataURL();
					}
					data.blob = blob;
					onFinish( data );
				});
			} else {
				data.image = canvas.toDataURL();
				onFinish( data );
			}
		}
	});
};

MC.canvas.exportPNG.fixSVG = function( element, removeArray ) {

	var tagName = element.tagName.toLowerCase();

	// Remove <defs/>, empty <g/> and g.resizer-wrap
	if ( tagName === "defs" ) { return removeArray.push( element ); }

	var children = element.children || element.childNodes;
	var remove   = false;

	if ( tagName === "g" ) {
		if ( children.length == 0 ) {
			remove = true;
		} else if ( !element.classList ) {
			var k = element.getAttribute("class");
			if ( k && k.indexOf("resizer-wrap") != -1 ) {
				remove = true;
			}
		} else if ( element.classList.contains("resizer-wrap") ) {
				remove = true;
		}
	}

	if ( !remove ) {
		if ( !element.classList ) {
			k = element.getAttribute("class");
			if ( k && k.indexOf("fill-line") != -1 ) {
				remove = true;
			}
		} else if ( element.classList.contains("fill-line") ) {
			remove = true;
		}
	}
	if ( remove ) { return removeArray.push(element); }

	var ss = window.getComputedStyle( element );
	// Remove non-visual element
	if ( ss.visibility == "hidden" || ss.display == "none" || ss.opacity == "0" ) {
		return removeArray.push( element );
	}

	// Store the inline stylesheet in stylez
	var s = [];

	if ( ss.opacity != 1 ) { s.push( "opacity:" + ss.opacity ); }

	if ( tagName !== "g" && tagName !== "image" ) {
		// Fill
		if ( ss.fillOpacity == 0 ) {
			s.push( "fill:none" );
		} else {
			if ( ss.fill != "#000000" ) { s.push( "fill:" + ss.fill ); }
			if ( ss.fillOpacity != 1 )  { s.push( "fill-opacity:" + ss.fillOpacity ); }
		}

		// Stroke
		var t1 = (ss.strokeWidth + "").replace("px", "");
		if ( ss.strokeWidth == 0 || ss.strokeOpacity == 0 ) {
			s.push( "stroke:none" );
		} else {
			s.push( "stroke:" + ss.stroke );
			if ( t1 != 1 )               { s.push( "stroke-width:" + ss.strokeWidth ); }
			if ( ss.strokeOpacity != 1 ) { s.push( "stroke-opacity:" + ss.strokeOpacity ); }
		}
		if ( ss.strokeLinejoin !="miter" ) { s.push("stroke-linejoin:"+ss.strokeLinejoin); }
		if ( ss.strokeDasharray!="none"  ) { s.push("stroke-dasharray:"+ss.strokeDasharray); }

		// Text ( Font-family is hard coded in UI.canvg )
		if ( tagName === "text" ) {
			s.push( "font-size:"+ ss.fontSize );
			if ( ss.textAnchor != "start" ) { s.push( "text-anchor:" + ss.textAnchor ); }
		}
	}

	if ( s.length ) {
		element.setAttribute("stylez", s.join(";"));
	}

	for ( var i = 0; i < children.length; ++i ) {
		var c = children[i];
		if ( !c.tagName ) { continue; }
		MC.canvas.exportPNG.fixSVG( c, removeArray );
		c.removeAttribute("id");
		c.removeAttribute("class");
	}
}
