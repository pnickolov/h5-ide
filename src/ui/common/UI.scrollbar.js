/*
#**********************************************************
#* Filename: UI.scrollbar
#* Creator: Angel
#* Description: UI.scrollbar
#* Date: 20130705
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var scrollbar = {
	init: function ()
	{
		if (/webkit/ig.test(navigator.userAgent.toLowerCase()))
		{
			return true;
		}

		var style = document.documentElement.style,
			doc_scroll_wrap = document.getElementsByClassName('scroll-wrap');

		scrollbar.isTransform = (style.webkitTransform !== undefined || style.MozTransform !== undefined || style.OTransform !== undefined || style.Transform !== undefined);

		$(document.body)
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
					veritical_thumb = wrap.find('.scrollbar-veritical-thumb').first(),
					horizontal_thumb = wrap.find('.scrollbar-horizontal-thumb').first(),
					scroll_content = wrap.find('.scroll-content').first(),
					offsetHeight = target.offsetHeight,
					offsetWidth = target.offsetWidth,
					scrollbar_height,
					scrollbar_width;

				if (scroll_content[0])
				{
					scrollbar_height = offsetHeight * offsetHeight / scroll_content[0].scrollHeight;
					scrollbar_width = offsetWidth * offsetWidth / scroll_content[0].scrollWidth;

					if (veritical_thumb)
					{
						if (scrollbar_height <= offsetHeight * 2 - scroll_content[0].scrollHeight || scrollbar_height > wrap.height())
						{
							veritical_thumb.parent().hide();
							if (scrollbar.isTransform)
							{
								scroll_content.css('transform', 'translate3d(' + (scroll_content[0].realScrollLeft ? scroll_content[0].realScrollLeft : 0) + ', 0, 0)');
							}
							else
							{
								scroll_content.css('top', 0);
							}

							scroll_content[0].realScrollTop = 0;
							veritical_thumb.css('top', 0);
						}
						else
						{
							veritical_thumb.parent().show();
							veritical_thumb.css('height', scrollbar_height);
						}
					}

					if (horizontal_thumb)
					{
						if (scrollbar_width <=  offsetWidth * 2 - scroll_content[0].scrollWidth || scrollbar_width > wrap.width())
						{
							horizontal_thumb.parent().hide();
							if (scrollbar.isTransform)
							{
								scroll_content.css('transform', 'translate3d(0, ' + (scroll_content[0].realScrollTop ? scroll_content[0].realScrollTop : 0) + 'px, 0)');
							}
							else
							{
								scroll_content.css('left', 0);
							}

							scroll_content[0].realScrollLeft = 0;
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
		}, 2500);
	},
	mousedown: function (event)
	{
		var target = $(this).parent().parent(),
			tag = event.target.tagName.toLowerCase(),
			direction = event.data.direction,
			veritical_thumb,
			horizontal_thumb;

		if (tag === 'a' || tag === 'input' || tag === 'img')
		{
			return false;
		}

		event.preventDefault();
		event.stopPropagation();

		target.addClass('scrolling');

		if (direction === 'veritical')
		{
			veritical_thumb = target.find('.scrollbar-veritical-thumb').first();
		}
		if (direction === 'horizontal')
		{
			horizontal_thumb = target.find('.scrollbar-horizontal-thumb').first();
		}

		event = scrollbar.isTouch ? event.originalEvent.touches[0] : event;

		$(document).on({
			'mousemove': scrollbar.mousemove,
			'mouseup': scrollbar.mouseup
		}, {
			'scroll_target': target,
			'direction': direction,
			'thumbPos': direction === 'veritical' ? event.clientY - veritical_thumb.offset().top : event.clientX - horizontal_thumb.offset().left
		});
	},
	mousemove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = event.data.scroll_target,
			direction = event.data.direction,
			thumbPos = event.data.thumbPos,
			scrollbar_wrap = target.find('.scrollbar-' + direction + '-wrap').first();

		event = scrollbar.isTouch ? event.touches.originalEvent[0] : event;

		if (direction === 'veritical')
		{
			scrollbar.scroll_to_top(target, scrollbar.isTouch ? thumbPos - event.clientY : event.clientY - scrollbar_wrap.offset().top - thumbPos);
		}
		if (direction === 'horizontal')
		{
			scrollbar.scroll_to_left(target, scrollbar.isTouch ? thumbPos - event.clientX : event.clientX - scrollbar_wrap.offset().left - thumbPos);
		}

		return false;
	},
	mouseup: function (event)
	{
		event.data.scroll_target.removeClass('scrolling');
		$(document).off(scrollbar.isTouch ? {
			'touchmove': scrollbar.mousemove,
			'touchend': scrollbar.mouseup
		} : {
			'mousemove': scrollbar.mousemove,
			'mouseup': scrollbar.mouseup
		});
	},
	scroll_to_left: function (target, scroll_left)
	{
		var scroll_content = target.find('.scroll-content').first(),
			horizontal_thumb = target.find('.scrollbar-horizontal-thumb').first(),
			scroll_wrap_width = scroll_content.parent().width(),
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
	scroll_to_top: function (target, scroll_top)
	{
		var scroll_content = target.find('.scroll-content').first(),
			thumb = target.find('.scrollbar-veritical-thumb').first(),
			scroll_wrap_height = scroll_content.parent().height(),
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
			delta = event.originalEvent.wheelDelta ? event.originalEvent.wheelDelta / 120 : event.originalEvent.wheelDeltaY ? event.originalEvent.wheelDeltaY / 120 : -event.originalEvent.detail / 3,
			thumb = target.find('.scrollbar-veritical-thumb').first(),
			thumb_wrap = target.find('.scrollbar-veritical-wrap').first(),
			scroll_content = target.find('.scroll-content').first(),
			wrap_height = target.height(),
			scrollTop,
			max_scroll,
			scale,
			thumb_max;

		scrollTop = thumb[0].offsetTop - (delta * 12);
		max_scroll = scroll_content[0].scrollHeight - wrap_height;
		scale = scroll_content[0].scrollHeight / wrap_height;
		thumb_max = max_scroll / scale;

		if (thumb_wrap.css('display') === 'block')
		{
			scrollbar.scroll_to_top(target, scrollTop);
			if (scrollTop < 0 || scrollTop > thumb_max)
			{
				return true;
			}
			else
			{
				event.preventDefault();
			}
		}
		else
		{
			return true;
		}
	}
};

$(document).ready(function ()
{
	scrollbar.init();
});