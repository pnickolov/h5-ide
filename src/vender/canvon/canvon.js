//
// Canvon SVG framework
// Copyright Angel Lai 2013
// MIT license
//

(function () {

var
	ns = "http://www.w3.org/2000/svg",
	SVG_CANVAS = document.createElementNS(ns, "svg");

var Canvon = function (selector)
{
	return new Canvon.fn.init( selector );
};

Canvon.fn = Canvon.prototype = {

	drawn: null,

	init: function (selector)
	{
		var elem = $(selector);
		
		$.each(Canvon.prototype, function (name, fn)
		{
			elem[ name ] = fn;
		});

		return elem;
	},

	start: function (style)
	{
		var group = document.createElementNS(ns, 'g');

		if (style)
		{
			$(group).css(style);
		}
		$(this).append(group);
		this.drewGroup = group;

		return group;
	},

	draw: function (canvas, type)
	{
		if (this.drawn && !canvas.drewGroup)
		{
			return $(this.drawn);
		}

		var element = document.createElementNS(ns, type);

		if (canvas.drewGroup)
		{
			$(canvas.drewGroup).append(element);
		}
		else
		{
			if (this !== Canvon)
			{
				$(canvas).append(element);
			}
		}

		if (this !== Canvon)
		{
			this.drawn = element;
		}

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

			return true;
		}
	},

	line: function (x1, y1, x2, y2, style)
	{
		var target = this.draw(this, 'line'),
			originalTarget = target[0];

		originalTarget.x1.baseVal.value = x1;
		originalTarget.y1.baseVal.value = y1;
		originalTarget.x2.baseVal.value = x2;
		originalTarget.y2.baseVal.value = y2;

		return target.css(style || {});
	},

	polyline: function (path, style)
	{
		var target = this.draw(this, 'polyline'),
			originalTarget = target[0],
			point,
			length = path.length,
			i;

		originalTarget.points.clear();

		for (i = 0; i < length; i++)
		{
			point = SVG_CANVAS.createSVGPoint();

			point.x = path[ i ][0];
			point.y = path[ i ][1];

			originalTarget.points.appendItem(point);
		}

		return target.css(style || {});
	},

	polygon: function (path, style)
	{
		var target = this.draw(this, 'polygon'),
			originalTarget = target[0],
			point,
			length = path.length,
			i;

		originalTarget.points.clear();

		for (i = 0; i < length; i++)
		{
			point = SVG_CANVAS.createSVGPoint();

			point.x = path[ i ][0];
			point.y = path[ i ][1];

			originalTarget.points.appendItem(point);
		}

		return target.css(style || {});
	},

	circle: function (x, y, r, style)
	{
		var target = this.draw(this, 'circle'),
			originalTarget = target[0];

		originalTarget.cx.baseVal.value = x;
		originalTarget.cy.baseVal.value = y;
		originalTarget.r.baseVal.value = r;

		return target.css(style || {});
	},

	ellipse: function (x, y, rx, ry, style)
	{
		var target  = this.draw(this, 'ellipse'),
			originalTarget = target[0];

		originalTarget.x.baseVal.value = x;
		originalTarget.y.baseVal.value = y;
		originalTarget.rx.baseVal.value = ry;
		originalTarget.ry.baseVal.value = ry;

		return target.css(style || {});
	},

	rectangle: function (x, y, width, height, style)
	{
		var target = this.draw(this, 'rect'),
			originalTarget = target[0];

		originalTarget.x.baseVal.value = x;
		originalTarget.y.baseVal.value = y;
		originalTarget.width.baseVal.value = width;
		originalTarget.height.baseVal.value = height;

		return target.css(style || {});
	},

	path: function (path, style)
	{
		return this.draw(this, 'path').attr({
			'd': path
		}).css(style || {});
	},

	text: function (x, y, text, style)
	{
		var target = this.draw(this, 'text'),
			originalTarget = target[0],
			SVGLength_x = SVG_CANVAS.createSVGLength(),
			SVGLength_y = SVG_CANVAS.createSVGLength();

		SVGLength_x.value = x;
		SVGLength_y.value = y;

		originalTarget.x.baseVal.initialize(SVGLength_x);
		originalTarget.y.baseVal.initialize(SVGLength_y);

		originalTarget.textContent = text;

		return target.css(style || {});
	},

	image: function (src, x, y, width, height)
	{
		var target = this.draw(this, 'image'),
			originalTarget = target[0];

		originalTarget.x.baseVal.value = x;
		originalTarget.y.baseVal.value = y;
		originalTarget.width.baseVal.value = width;
		originalTarget.height.baseVal.value = height;

		// SVG_PRESERVEASPECTRATIO_NONE = 1
		originalTarget.preserveAspectRatio.baseVal.align = 1;
		originalTarget.href.baseVal = src;

		return target;
	},

	// use: function (href, attr, style)
	// {
	// 	var use = this.draw(this, 'use').attr(attr || {}).css(style || {});

	// 	use[ 0 ].setAttributeNS("http://www.w3.org/1999/xlink", 'href', href);

	// 	return use;
	// },

	group: function (style)
	{
		return this.draw(this, 'g').css(style || {});
	},

	addClass: function (name)
	{
		var target,
			className,
			nclass;

		this.each(function ()
		{
			target = $(this);
			className = target.attr('class');
			nclass = [];

			if (className === '')
			{
				target.attr('class', name);
			}
			else
			{
				$.each(name.split(/\s+/), function (i, item)
				{
					if (!new RegExp('\\b(' + item + ')\\b').test(className))
					{
						nclass.push(' ' + item);
					}
				});
				className += nclass.join('');

				target.attr('class', className);
			}
		});

		return this;
	},

	removeClass: function (name)
	{
		var target,
			className;

		this.each(function ()
		{
			target = $(this);
			className = target.attr('class');

			if (className)
			{
				target.attr('class', name ?
					$.trim(
						className.replace(
							new RegExp('\\b(' + name.split(/\s+/).join('|') + ')\\b'), '')
							.split(/\s+/)
							.join(' ')
					) : ''
				);
			}
		});

		return this;
	},

	hasClass: function (name)
	{
		return new RegExp('\\b(' + name.split(/\s+/).join('|') + ')\\b').test( this.attr('class') );
	},

	offset: function ()
	{
		return this[ 0 ].getBoundingClientRect();
	}
};

$.each(Canvon.prototype, function (name, fn)
{
	Canvon[ name ] = fn;
});

window.Canvon = Canvon;

})();