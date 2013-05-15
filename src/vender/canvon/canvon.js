//
// Canvon SVG framework
// Copyright Angel Lai 2013
// MIT license
// 
var Canvon = function (canvas_id)
{
	return new Canvon.fn.init(document.getElementById(canvas_id));
};

Canvon.fn = Canvon.prototype = {

	drawn: null,

	init: function (canvas)
	{
		$.each(Canvon.prototype, function (name, fn)
		{
			canvas[name] = fn;
		});

		return canvas;
	},

	start: function (style)
	{
		var group = document.createElementNS("http://www.w3.org/2000/svg", 'g');

		if (style)
		{
			$(group).css(style);
		}
		$(this).append(group);
		this.drewGroup = group;
	},

	draw: function (canvas, type)
	{
		if (this.drawn && !canvas.drewGroup)
		{
			return $(this.drawn);
		}

		var element = document.createElementNS("http://www.w3.org/2000/svg", type);

		if (canvas.drewGroup)
		{
			$(canvas.drewGroup).append(element);
		}
		else
		{
			$(canvas).append(element);
		}
		this.drawn = element;

		return $(element);
	},

	save: function ()
	{
		var data = this.drewGroup;
		if (data)
		{
			this.drewGroup = null;

			return data;
		}
	},

	clear: function (elem)
	{
		if (elem && elem.parentNode != null)
		{
			if (elem == this.drewGroup)
			{
				this.drewGroup = null;
			}
			this.removeChild(elem);
		}
	},

	line: function (x1, y1, x2, y2, style)
	{
		return this.draw(this, 'line').attr({
			'x1': x1,
			'y1': y1,
			'x2': x2,
			'y2': y2
		}).css(style || '');
	},

	/**
	 * Draw polyline
	 * @param  {array} path  The points of path
	 * [
			[startX1, endY1],
			[startX2, endY2],
			[startX3, endY3]
		]
	 * @param  {object} style The style stroke
	 * @return {object} The SVG line object
	 */
	polyline: function (path, style)
	{
		var points = [],
			length = path.length,
			i;

		for (i = 0; i < length; i++) {
			points.push(path[i][0] + ',' + path[i][1]);
		};

		return this.draw(this, 'polyline').attr({
			'points': points.join(' ')
		}).css(style || '');
	},

	polygon: function (path, style)
	{
		var points = [],
			length = path.length,
			i;

		for (i = 0; i < length; i++) {
			points.push(path[i][0] + ',' + path[i][1]);
		};

		return this.draw(this, 'polygon').attr({
			'points': points.join(' ')
		}).css(style || '');
	},

	circle: function (x, y, r, style)
	{
		return this.draw(this, 'circle').attr({
			'cx': x,
			'cy': y,
			'r': r
		}).css(style || '');
	},

	ellipse: function (x, y, rx, ry, style)
	{
		return this.draw(this, 'ellipse').attr({
			'cx': x,
			'cy': y,
			'rx': rx,
			'ry': ry
		}).css(style || '');
	},

	rectangle: function (x, y, width, height, style)
	{
		return this.draw(this, 'rect').attr({
			'x': x,
			'y': y,
			'width': width,
			'height': height 
		}).css(style || '');
	},

	path: function (path, style)
	{
		return this.draw(this, 'path').attr({
			'd': path
		}).css(style || '');
	},

	text: function (x, y, text, style)
	{
		return this.draw(this, 'text').attr({
				'x': x,
				'y': y
		}).text(text).css(style || '');
	},

	image: function (src, x, y, width, height)
	{
		return this.draw(this, 'image').attr({
			'x': x,
			'y': y,
			'width': width,
			'height': height,
			"preserveAspectRatio": "none"
		}).setAttributeNS("http://www.w3.org/1999/xlink", "href", src);
	}
};