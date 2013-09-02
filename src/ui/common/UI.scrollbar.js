/*
#**********************************************************
#* Filename: UI.scrollbar
#* Creator: Angel
#* Description: UI.scrollbar
#* Date: 20130902
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

var scrollbar = {
	init: function ()
	{
		var style = document.documentElement.style,
			doc_scroll_wrap = document.getElementsByClassName('scroll-wrap');

		scrollbar.isTransform = (
			style.webkitTransform !== undefined ||
			style.MozTransform !== undefined ||
			style.OTransform !== undefined ||
			style.Transform !== undefined
		);

		$(document)
			.on('mousewheel', '.scroll-wrap', scrollbar.wheel)
			.on('DOMMouseScroll', '.scroll-wrap', scrollbar.wheel)
			.on('mousedown', '.scrollbar-veritical-thumb', {'direction': 'veritical'}, scrollbar.mousedown)
			.on('mousedown', '.scrollbar-horizontal-thumb', {'direction': 'horizontal'}, scrollbar.mousedown);

		setInterval(function ()
		{
			if (!$(document.body).hasClass('disable-event'))
			{
				var length = doc_scroll_wrap.length;

				while (length--)
				{
					var target = doc_scroll_wrap[ length ],
						wrap = $(target),
						children = wrap.children(),
						veritical_thumb = children[0] ? $(children[0].firstChild) : undefined,
						horizontal_thumb = children[1] ? $(children[1].firstChild) : undefined,
						scroll_content = wrap.find('.scroll-content').first(),
						scroll_content_elem = scroll_content[0],
						offsetHeight = target.offsetHeight,
						offsetWidth = target.offsetWidth,
						scrollbar_height,
						scrollbar_width,
						wrap_height,
						wrap_width;

					if (scroll_content_elem && wrap.css('display') === 'block')
					{
						scrollbar_height = offsetHeight * offsetHeight / scroll_content_elem.scrollHeight;
						scrollbar_width = offsetWidth * offsetWidth / scroll_content_elem.scrollWidth;

						if (veritical_thumb && veritical_thumb.hasClass('scrollbar-veritical-thumb'))
						{
							wrap_height = wrap.height();

							if (scrollbar_height <= offsetHeight * 2 - scroll_content_elem.scrollHeight || scrollbar_height > wrap_height)
							{
								veritical_thumb.parent().hide();

								if (scrollbar.isTransform)
								{
									scroll_content.css('transform', 'translate(' + (scroll_content_elem.realScrollLeft ? scroll_content_elem.realScrollLeft : 0) + ', 0)');
								}
								else
								{
									scroll_content.css('top', 0);
								}

								scroll_content_elem.realScrollTop = 0;
								veritical_thumb.css('top', 0);
							}
							else
							{
								veritical_thumb.parent().show();
								veritical_thumb.css('height', scrollbar_height);

								if (
									scroll_content_elem.realScrollTop !== 0 &&
									wrap_height - scroll_content_elem.realScrollTop > scroll_content[0].scrollHeight
								)
								{
									scrollbar.scrollTop({
										'scroll_content': scroll_content,
										'scrollbar_wrap': children[0],
										'thumb': veritical_thumb,
										'scroll_target': wrap
									}, scroll_content[0].scrollHeight);
								}
							}
						}

						if (horizontal_thumb && horizontal_thumb.hasClass('scrollbar-horizontal-thumb'))
						{
							wrap_width = wrap.width();

							if (scrollbar_width <= offsetWidth * 2 - scroll_content_elem.scrollWidth || scrollbar_width > wrap_width)
							{
								horizontal_thumb.parent().hide();
								if (scrollbar.isTransform)
								{
									scroll_content.css('transform', 'translate(0, ' + (scroll_content_elem.realScrollTop ? scroll_content_elem.realScrollTop : 0) + 'px)');
								}
								else
								{
									scroll_content.css('left', 0);
								}

								scroll_content_elem.realScrollLeft = 0;
								horizontal_thumb.css('left', 0);
							}
							else
							{
								horizontal_thumb.parent().show();
								horizontal_thumb.css('width', scrollbar_width);

								if (
									scroll_content_elem.realScrollLeft !== 0 &&
									wrap_width - scroll_content_elem.realScrollLeft > scroll_content[0].scrollWidth
								)
								{
									scrollbar.scrollLeft({
										'scroll_content': scroll_content,
										'scrollbar_wrap': children[1],
										'thumb': horizontal_thumb,
										'scroll_target': wrap
									}, scroll_content[0].scrollWidth);
								}
							}
						}
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
			tag = event.target.tagName.toLowerCase(),
			direction = event.data.direction;

		if (
			$.inArray(tag, ['a', 'input', 'img']) > -1
		)
		{
			return false;
		}

		$(document.body).append('<div id="overlayer"></div>');

		target.addClass('scrolling');

		event = scrollbar.isTouch ? event.originalEvent.touches[0] : event;

		$(document)
			.on({
				'mousemove': scrollbar.mousemove,
				'mouseup': scrollbar.mouseup
			}, {
				'scroll_target': target,
				'direction': direction,
				'scrollbar_wrap': target.find('.scrollbar-' + direction + '-wrap').first(),
				'scroll_content': target.find('.scroll-content').first(),
				'thumb': thumb,
				'thumbPos': direction === 'veritical' ? event.clientY - thumb.offset().top : event.clientX - thumb.offset().left
			});

		return false;
	},

	mousemove: function (event)
	{
		var target = event.data.scroll_target,
			direction = event.data.direction,
			thumbPos = event.data.thumbPos;

		event_data = scrollbar.isTouch ? event.touches.originalEvent[0] : event;

		if (direction === 'veritical')
		{
			scrollbar.scrollTop(event.data, scrollbar.isTouch ? thumbPos - event_data.clientY : event_data.clientY - event.data.scrollbar_wrap.offset().top - thumbPos);
		}

		if (direction === 'horizontal')
		{
			scrollbar.scrollLeft(event.data, scrollbar.isTouch ? thumbPos - event_data.clientX : event_data.clientX - event.data.scrollbar_wrap.offset().left - thumbPos);
		}

		return false;
	},

	mouseup: function (event)
	{
		$(document)
			.off(scrollbar.isTouch ? {
				'touchmove': scrollbar.mousemove,
				'touchend': scrollbar.mouseup
			} : {
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

		if (direction.left)
		{
			thumb = target.find('.scrollbar-horizontal-thumb').first();
			scrollbar_wrap = target.find('.scrollbar-horizontal-wrap').first();

			if (thumb[0] && scrollbar_wrap[0])
			{
				scrollbar.scrollLeft({
					'scroll_content': scroll_content,
					'scrollbar_wrap': scrollbar_wrap,
					'thumb': thumb,
					'scroll_target': target
				}, direction.left / (scroll_content[0].scrollWidth / scrollbar_wrap.width()));
			}
		}

		if (direction.top)
		{
			thumb = target.find('.scrollbar-veritical-thumb').first();
			scrollbar_wrap = target.find('.scrollbar-veritical-wrap').first();

			if (thumb[0] && scrollbar_wrap[0])
			{
				scrollbar.scrollTop({
					'scroll_content': scroll_content,
					'scrollbar_wrap': scrollbar_wrap,
					'thumb': thumb,
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
			max_scroll = scroll_content[0].scrollWidth - scroll_wrap_width,
			scale = scroll_content[0].scrollWidth / scroll_wrap_width,
			thumb_max = max_scroll / scale,
			scroll_value;

		if (scroll_left > 0 && scroll_left < thumb_max)
		{
			horizontal_thumb.css('left', scroll_left);
			scroll_value = -(scroll_left * scale);
		}
		else
		{
			if (scroll_left <= 0)
			{
				horizontal_thumb.css('left', 0);
				scroll_value = 0;
			}
			if (scroll_left >= thumb_max)
			{
				horizontal_thumb.css('left', thumb_max);
				scroll_value = -max_scroll;
			}
		}

		scroll_value = Math.round(scroll_value);

		if (scrollbar.isTransform)
		{
			scroll_content.css('transform', 'translate(' + scroll_value + 'px, ' + (scroll_content[0].realScrollTop ? scroll_content[0].realScrollTop : 0) + 'px)');
		}
		else
		{
			scroll_content.css('left', scroll_value);
		}

		scroll_content[0].realScrollLeft = scroll_value;

		return true;
	},

	scrollTop: function (data, scroll_top)
	{
		var scroll_content = data.scroll_content,
			thumb = data.thumb,
			scroll_wrap_height = data.scroll_target.height(),
			max_scroll = scroll_content[0].scrollHeight - scroll_wrap_height,
			scale = scroll_content[0].scrollHeight / scroll_wrap_height,
			thumb_max = max_scroll / scale,
			scroll_value;

		if (scroll_top > 0 && scroll_top < thumb_max)
		{
			thumb.css('top', scroll_top);
			scroll_value = -(scroll_top * scale);
		}
		else
		{
			if (scroll_top <= 0)
			{
				thumb.css('top', 0);
				scroll_value = 0;
			}
			if (scroll_top >= thumb_max)
			{
				thumb.css('top', thumb_max);
				scroll_value = -max_scroll;
			}
		}

		scroll_value = Math.round(scroll_value);

		if (scrollbar.isTransform)
		{
			scroll_content.css('transform', 'translate(' + (scroll_content[0].realScrollLeft ? scroll_content[0].realScrollLeft : 0) + 'px, ' + scroll_value + 'px)');
		}
		else
		{
			scroll_content.css('top', scroll_value);
		}

		scroll_content[0].realScrollTop = scroll_value;

		return true;
	},

	wheel: function (event, delta)
	{
		var target = $(this),
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
			originalEvent.wheelDeltaX ||
			originalEvent.axis === 1
		)
		{
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
						'scroll_content': scroll_content,
						'scrollbar_wrap': scrollbar_wrap,
						'thumb': thumb,
						'scroll_target': target
					}, scrollLeft);

					if (scrollLeft < 0 || scrollLeft > thumb_max)
					{
						return true;
					}
					else
					{
						return false;
					}
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
						'scroll_content': scroll_content,
						'scrollbar_wrap': scrollbar_wrap,
						'thumb': thumb,
						'scroll_target': target
					}, scrollTop);

					if (scrollTop < 0 || scrollTop > thumb_max)
					{
						return true;
					}
					else
					{
						return false;
					}
				}
				else
				{
					return false;
				}
			}
		}
	}
};

$(document).ready(function ()
{
	scrollbar.init();
});