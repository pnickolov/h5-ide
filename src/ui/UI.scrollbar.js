/*
#**********************************************************
#* Filename: UI.scrollbar
#* Creator: Angel
#* Description: UI.scrollbar
#* Date: 20140307
# **********************************************************
# (c) Copyright 2014 Madeiracloud  All Rights Reserved
# **********************************************************
*/

define(["jquery"], function(){


var style = document.documentElement.style,
	isTransform = false,
	cssTransform;

$.each([
	'webkitTransform',
	'MozTransform',
	'OTransform',
	'msTransform',
	'transform'
], function (i, cssName)
{
	if (cssName in style)
	{
		isTransform = true;
		cssTransform = cssName;
	}
});

var scrollbar = {
	init: function ()
	{
		var doc_scroll_wrap = document.getElementsByClassName('scroll-wrap');

		$(document)
			.on('mousewheel', '.scroll-wrap', scrollbar.wheel)
			.on('DOMMouseScroll', '.scroll-wrap', scrollbar.wheel)
			.on('mousedown', '.scrollbar-veritical-thumb', {'direction': 'veritical'}, scrollbar.mousedown)
			.on('mousedown', '.scrollbar-horizontal-thumb', {'direction': 'horizontal'}, scrollbar.mousedown);

		setInterval(function ()
		{
			var length = doc_scroll_wrap.length;

			while (length--)
			{
				var target = doc_scroll_wrap[ length ],
					wrap = $(target),
					children = wrap.children(),
					veritical_thumb = children[0] ? $(children[0].firstChild) : undefined,
					horizontal_thumb = children[1] ? $(children[1].firstChild) : undefined,
					scroll_content = target.getElementsByClassName('scroll-content')[0],
					offsetHeight = target.offsetHeight,
					offsetWidth = target.offsetWidth,
					scrollbar_height,
					scrollbar_width,
					wrap_height,
					wrap_width;

				if (
					scroll_content &&
					wrap.css('display') === 'block' &&
					!wrap.hasClass('scrolling')
				)
				{
					scrollbar_height = scroll_content.scrollHeight > 0 ? offsetHeight * offsetHeight / scroll_content.scrollHeight : 0;
					scrollbar_width = scroll_content.scrollWidth > 0 ? offsetWidth * offsetWidth / scroll_content.scrollWidth : 0;

					if (veritical_thumb && veritical_thumb.hasClass('scrollbar-veritical-thumb'))
					{
						wrap_height = wrap.height();

						if (scrollbar_height <= offsetHeight * 2 - scroll_content.scrollHeight || scrollbar_height > wrap_height)
						{
							veritical_thumb.parent().hide();

							if (isTransform)
							{
								scroll_content.style[ cssTransform ] = 'translate(' + (scroll_content.realScrollLeft ? scroll_content.realScrollLeft : 0) + ', 0)';
							}
							else
							{
								scroll_content.style.top = '0px';
							}

							scroll_content.realScrollTop = 0;
							veritical_thumb[0].style.top = '0px';
						}
						else
						{
							veritical_thumb.parent().show();
							veritical_thumb[0].style.height = scrollbar_height + 'px';

							if (
								scroll_content.realScrollTop !== 0 &&
								wrap_height - scroll_content.realScrollTop > scroll_content.scrollHeight
							)
							{
								scrollbar.scrollTop({
									'scroll_content': scroll_content,
									'scrollbar_wrap': children[0],
									'thumb': veritical_thumb[0],
									'scroll_target': wrap
								}, scroll_content.scrollHeight);
							}
						}
					}

					if (horizontal_thumb && horizontal_thumb.hasClass('scrollbar-horizontal-thumb'))
					{
						wrap_width = wrap.width();

						if (scrollbar_width <= offsetWidth * 2 - scroll_content.scrollWidth || scrollbar_width > wrap_width)
						{
							horizontal_thumb.parent().hide();
							if (isTransform)
							{
								scroll_content.style[ cssTransform ] = 'translate(0, ' + (scroll_content.realScrollTop ? scroll_content.realScrollTop : 0) + 'px)';
							}
							else
							{
								scroll_content.style.left = '0px';
							}

							scroll_content.realScrollLeft = 0;
							horizontal_thumb[0].style.left = '0px';
						}
						else
						{
							horizontal_thumb.parent().show();
							horizontal_thumb[0].style.width = scrollbar_width + 'px';

							if (
								scroll_content.realScrollLeft !== 0 &&
								wrap_width - scroll_content.realScrollLeft > scroll_content.scrollWidth
							)
							{
								scrollbar.scrollLeft({
									'scroll_content': scroll_content,
									'scrollbar_wrap': children[1],
									'thumb': horizontal_thumb[0],
									'scroll_target': wrap
								}, scroll_content.scrollWidth);
							}
						}
					}

					if (target.scrollTop !== 0)
					{
						scrollbar.scrollTop({
							'scroll_content': scroll_content,
							'scrollbar_wrap': children[0],
							'thumb': veritical_thumb[0],
							'scroll_target': wrap
						}, target.scrollTop);

						target.scrollTop = 0;
					}

					if (target.scrollLeft !== 0)
					{
						scrollbar.scrollLeft({
							'scroll_content': scroll_content,
							'scrollbar_wrap': children[0],
							'thumb': veritical_thumb[0],
							'scroll_target': wrap
						}, target.scrollLeft);

						target.scrollLeft = 0;
					}
				}
			}
		}, 800);

		return true;
	},

	mousedown: function (event)
	{
		var thumb = $(this),
			target = thumb.parent().parent(),
			direction = event.data.direction;

		$(document.body).append('<div id="overlayer"></div>');

		target
			.addClass('scrolling')
			.trigger('scroll');

		$(document)
			.on({
				'mousemove': scrollbar.mousemove,
				'mouseup': scrollbar.mouseup
			}, {
				'scroll_target': target,
				'direction': direction,
				'scrollbar_wrap': target.find('.scrollbar-' + direction + '-wrap').first(),
				'scroll_content': target.find('.scroll-content').first()[0],
				'thumb': thumb[0],
				'thumbPos': direction === 'veritical' ? event.clientY - thumb.offset().top : event.clientX - thumb.offset().left
			});

		// return false;
	},

	mousemove: function (event)
	{
		var event_data = event.data,
			target = event_data.scroll_target,
			direction = event_data.direction,
			thumbPos = event_data.thumbPos;

		if (direction === 'veritical')
		{
			scrollbar.scrollTop(event_data, event.clientY - event_data.scrollbar_wrap.offset().top - thumbPos);
		}

		if (direction === 'horizontal')
		{
			scrollbar.scrollLeft(event_data, event.clientX - event_data.scrollbar_wrap.offset().left - thumbPos);
		}

		return false;
	},

	mouseup: function (event)
	{
		$(document).off({
			'mousemove': scrollbar.mousemove,
			'mouseup': scrollbar.mouseup
		});

		$('#overlayer').remove();

		event.data.scroll_target.removeClass('scrolling');

		return true;
	},

	scrollTo: function (target, direction)
	{
		var scroll_content = target.find('.scroll-content').first(),
			scrollbar_wrap,
			thumb;

		if (direction.left >= 0)
		{
			thumb = target.find('.scrollbar-horizontal-thumb').first();
			scrollbar_wrap = target.find('.scrollbar-horizontal-wrap').first();

			if (thumb[0] && scrollbar_wrap[0])
			{
				scrollbar.scrollLeft({
					'scroll_content': scroll_content[0],
					'scrollbar_wrap': scrollbar_wrap,
					'thumb': thumb[0],
					'scroll_target': target
				}, direction.left / (scroll_content[0].scrollWidth / scrollbar_wrap.width()));
			}
		}

		if (direction.top >= 0)
		{
			thumb = target.find('.scrollbar-veritical-thumb').first();
			scrollbar_wrap = target.find('.scrollbar-veritical-wrap').first();

			if (thumb[0] && scrollbar_wrap[0])
			{
				scrollbar.scrollTop({
					'scroll_content': scroll_content[0],
					'scrollbar_wrap': scrollbar_wrap,
					'thumb': thumb[0],
					'scroll_target': target
				}, direction.top / (scroll_content[0].scrollHeight / scrollbar_wrap.height()));
			}
		}

		return true;
	},

	scrollLeft: function (data, scroll_left)
	{
		var scroll_content = data.scroll_content,
			horizontal_thumb = data.thumb,
			scroll_wrap_width = data.scroll_target.width(),
			max_scroll = scroll_content.scrollWidth - scroll_wrap_width,
			scale = scroll_content.scrollWidth / scroll_wrap_width,
			thumb_max = max_scroll / scale,
			scroll_value;

		if (max_scroll < 0)
		{
			return true;
		}

		if (scroll_left > 0 && scroll_left < thumb_max)
		{
			horizontal_thumb.style.left = scroll_left + 'px';
			scroll_value = -(scroll_left * scale);
		}
		else
		{
			if (scroll_left <= 0)
			{
				horizontal_thumb.style.left = '0px';
				scroll_value = 0;
			}
			if (scroll_left >= thumb_max)
			{
				horizontal_thumb.style.left = thumb_max + 'px';
				scroll_value = -max_scroll;
			}
		}

		scroll_value = Math.round(scroll_value);

		if (isTransform)
		{
			scroll_content.style[ cssTransform ] = 'translate(' + scroll_value + 'px, ' + (scroll_content.realScrollTop ? scroll_content.realScrollTop : 0) + 'px)';
		}
		else
		{
			scroll_content.style.left = scroll_value + 'px';
		}

		scroll_content.realScrollLeft = scroll_value;

		return true;
	},

	scrollTop: function (data, scroll_top)
	{
		var scroll_content = data.scroll_content,
			veritical_thumb = data.thumb,
			scroll_wrap_height = data.scroll_target.height(),
			max_scroll = scroll_content.scrollHeight - scroll_wrap_height,
			scale = scroll_content.scrollHeight / scroll_wrap_height,
			thumb_max = max_scroll / scale,
			scroll_value;

		if (max_scroll < 0)
		{
			return true;
		}

		if (scroll_top > 0 && scroll_top < thumb_max)
		{
			veritical_thumb.style.top = scroll_top + 'px';
			scroll_value = -(scroll_top * scale);
		}
		else
		{
			if (scroll_top <= 0)
			{
				veritical_thumb.style.top = '0px';
				scroll_value = 0;
			}
			if (scroll_top >= thumb_max)
			{
				veritical_thumb.style.top = thumb_max + 'px';
				scroll_value = -max_scroll;
			}
		}

		scroll_value = Math.round(scroll_value);

		if (isTransform)
		{
			scroll_content.style[ cssTransform ] = 'translate(' + (scroll_content.realScrollLeft ? scroll_content.realScrollLeft : 0) + 'px, ' + scroll_value + 'px)';
		}
		else
		{
			scroll_content.style.top = scroll_value + 'px';
		}

		scroll_content.realScrollTop = scroll_value;

		return true;
	},

	wheel: function (event, delta)
	{
		var target = $(this),
			event_target = event.target,
			originalEvent = event.originalEvent,
			scroll_content = target.find('.scroll-content').first(),
			thumb,
			scrollbar_wrap,
			wrap_height,
			scrollTop,
			max_scroll,
			scale,
			thumb_max;

		if (
			event_target.tagName.toLowerCase() === 'textarea' &&
			event_target.scrollHeight > event_target.offsetHeight
		)
		{
			return true;
		}

		if (
			originalEvent.wheelDeltaX ||
			originalEvent.axis === 1
		)
		{
			target.trigger('onscroll');

			thumb = target.find('.scrollbar-horizontal-thumb').first();

			if (thumb[0])
			{
				delta = originalEvent.wheelDeltaX ? originalEvent.wheelDeltaX / 120 : -originalEvent.detail / 3;
				scrollbar_wrap = target.find('.scrollbar-horizontal-wrap').first();
				wrap_width = target.width();
				scrollLeft = thumb[0].offsetLeft - (delta * 12);
				max_scroll = scroll_content[0].scrollWidth - wrap_width;
				scale = scroll_content[0].scrollWidth / wrap_width;
				thumb_max = max_scroll / scale;

				if (scrollbar_wrap.css('display') === 'block')
				{
					scrollbar.scrollLeft({
						'scroll_content': scroll_content[0],
						'scrollbar_wrap': scrollbar_wrap,
						'thumb': thumb[0],
						'scroll_target': target
					}, scrollLeft);

					return (scrollLeft < 0 || scrollLeft > thumb_max);
				}
				else
				{
					return true;
				}
			}
		}

		if (
			originalEvent.wheelDeltaY ||
			originalEvent.wheelDelta ||
			originalEvent.detail
		)
		{
			target.trigger('scroll');

			thumb = target.find('.scrollbar-veritical-thumb').first();

			if (thumb[0])
			{
				delta = originalEvent.wheelDelta ? originalEvent.wheelDelta / 120 : originalEvent.wheelDeltaY ? originalEvent.wheelDeltaY / 120 : -originalEvent.detail / 3;
				scrollbar_wrap = target.find('.scrollbar-veritical-wrap').first();
				wrap_height = target.height();
				scrollTop = thumb[0].offsetTop - (delta * 12);
				max_scroll = scroll_content[0].scrollHeight - wrap_height;
				scale = scroll_content[0].scrollHeight / wrap_height;
				thumb_max = max_scroll / scale;

				if (scrollbar_wrap.css('display') === 'block')
				{
					scrollbar.scrollTop({
						'scroll_content': scroll_content[0],
						'scrollbar_wrap': scrollbar_wrap,
						'thumb': thumb[0],
						'scroll_target': target
					}, scrollTop);

					return (scrollTop < 0 || scrollTop > thumb_max);
				}
				else
				{
					return true;
				}
			}
		}
	}
};

window.scrollbar = scrollbar;

$(document).ready(function ()
{
	scrollbar.init();
});

});
