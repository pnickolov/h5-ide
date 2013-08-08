/*
#**********************************************************
#* Filename: UI.scrollbar
#* Creator: Angel
#* Description: UI.scrollbar
#* Date: 20130808
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
						scrollbar_width;

					if (scroll_content_elem && wrap.css('display') === 'block')
					{
						scrollbar_height = offsetHeight * offsetHeight / scroll_content_elem.scrollHeight;
						scrollbar_width = offsetWidth * offsetWidth / scroll_content_elem.scrollWidth;

						if (veritical_thumb && veritical_thumb.hasClass('scrollbar-veritical-thumb'))
						{
							if (scrollbar_height <= offsetHeight * 2 - scroll_content_elem.scrollHeight || scrollbar_height > wrap.height())
							{
								veritical_thumb.parent().hide();
								if (scrollbar.isTransform)
								{
									scroll_content.css('transform', 'translate3d(' + (scroll_content_elem.realScrollLeft ? scroll_content_elem.realScrollLeft : 0) + ', 0, 0)');
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
							}
						}

						if (horizontal_thumb && horizontal_thumb.hasClass('scrollbar-horizontal-thumb'))
						{
							if (scrollbar_width <=  offsetWidth * 2 - scroll_content_elem.scrollWidth || scrollbar_width > wrap.width())
							{
								horizontal_thumb.parent().hide();
								if (scrollbar.isTransform)
								{
									scroll_content.css('transform', 'translate3d(0, ' + (scroll_content_elem.realScrollTop ? scroll_content_elem.realScrollTop : 0) + 'px, 0)');
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
							}
						}
					}
				}
			}
		}, 2500);
	},
	mousedown: function (event)
	{
		var thumb = $(this),
			target = thumb.parent().parent(),
			tag = event.target.tagName.toLowerCase(),
			direction = event.data.direction,
			veritical_thumb,
			horizontal_thumb;

		if (tag === 'a' || tag === 'input' || tag === 'img')
		{
			return false;
		}

		$(document.body).addClass('disable-event');

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
			scrollbar.scroll_to_top(event.data, target, scrollbar.isTouch ? thumbPos - event_data.clientY : event_data.clientY - event.data.scrollbar_wrap.offset().top - thumbPos);
		}

		if (direction === 'horizontal')
		{
			scrollbar.scroll_to_left(event.data, target, scrollbar.isTouch ? thumbPos - event_data.clientX : event_data.clientX - event.data.scrollbar_wrap.offset().left - thumbPos);
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

		event.data.scroll_target.removeClass('scrolling');
		$(document.body).removeClass('disable-event');
	},
	scroll_to_left: function (data, target, scroll_left)
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

		if (scrollbar.isTransform)
		{
			scroll_content.css('transform', 'translate3d(' + scroll_value + 'px, ' + (scroll_content[0].realScrollTop ? scroll_content[0].realScrollTop : 0) + 'px, 0)');
		}
		else
		{
			scroll_content.css('left', scroll_value);
		}

		scroll_content[0].realScrollLeft = scroll_value;
	},
	scroll_to_top: function (data, target, scroll_top)
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

		if (scrollbar.isTransform)
		{
			scroll_content.css('transform', 'translate3d(' + (scroll_content[0].realScrollLeft ? scroll_content[0].realScrollLeft : 0) + 'px, ' + scroll_value + 'px, 0)');
		}
		else
		{
			scroll_content.css('top', scroll_value);
		}

		scroll_content[0].realScrollTop = scroll_value;
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

		if (originalEvent.wheelDeltaX !== 0)
		{
			delta = originalEvent.wheelDeltaX / 120;

			thumb = target.find('.scrollbar-horizontal-thumb').first(),
			scrollbar_wrap = target.find('.scrollbar-horizontal-wrap').first(),
			wrap_width = target.width(),
			scrollLeft = thumb[0].offsetLeft - (delta * 12),
			max_scroll = scroll_content[0].scrollWidth - wrap_width,
			scale = scroll_content[0].scrollWidth / wrap_width,
			thumb_max = max_scroll / scale;

			if (scrollbar_wrap.css('display') === 'block')
			{
				scrollbar.scroll_to_left({
					'scroll_content': scroll_content,
					'scrollbar_wrap': scrollbar_wrap,
					'thumb': thumb,
					'scroll_target': target
				}, target, scrollLeft);

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

		if (originalEvent.wheelDeltaY !== 0 || originalEvent.wheelDelta !== 0 || originalEvent.detail !== 0)
		{
			delta = originalEvent.wheelDelta ? originalEvent.wheelDelta / 120 : originalEvent.wheelDeltaY ? originalEvent.wheelDeltaY / 120 : -originalEvent.detail / 3;

			thumb = target.find('.scrollbar-veritical-thumb').first(),
			scrollbar_wrap = target.find('.scrollbar-veritical-wrap').first(),
			wrap_height = target.height(),
			scrollTop = thumb[0].offsetTop - (delta * 12),
			max_scroll = scroll_content[0].scrollHeight - wrap_height,
			scale = scroll_content[0].scrollHeight / wrap_height,
			thumb_max = max_scroll / scale;

			if (scrollbar_wrap.css('display') === 'block')
			{
				scrollbar.scroll_to_top({
					'scroll_content': scroll_content,
					'scrollbar_wrap': scrollbar_wrap,
					'thumb': thumb,
					'scroll_target': target
				}, target, scrollTop);

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
};

$(document).ready(function ()
{
	scrollbar.init();
});