/*
#**********************************************************
#* Filename: UI.scrollbar
#* Creator: Angel
#* Description: UI.scrollbar
#* Date: 201306032
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var scrollbar = {
	init: function ()
	{
		var style = document.documentElement.style;
		scrollbar.isTransform = (style.webkitTransform !== undefined || style.MozTransform !== undefined || style.OTransform !== undefined || style.Transform !== undefined);
		scrollbar.isTouch = window.ontouchstart !== undefined;

		if (scrollbar.isTouch)
		{
			$(document).on('touchstart', '.scroll-wrap', scrollbar.mousedown);
		}
		else
		{
			$(document).on('mousewheel', '.scroll-wrap', scrollbar.wheel);
			$(document).on('DOMMouseScroll', '.scroll-wrap', scrollbar.wheel);
			$(document).on('mousedown', '.scrollbar-veritical-thumb', {'direction': 'veritical'}, scrollbar.mousedown);
			$(document).on('mousedown', '.scrollbar-horizontal-thumb', {'direction': 'horizontal'}, scrollbar.mousedown);
		}

		setInterval(function ()
		{
			scrollbar.thumb_size();
		}, 1500);
	},
	thumb_size: function ()
	{
		$('.scroll-wrap').map(function ()
		{
			var wrap = $(this),
				veritical_thumb = wrap.find('.scrollbar-veritical-thumb'),
				horizontal_thumb = wrap.find('.scrollbar-horizontal-thumb'),
				scroll_content = wrap.find('.scroll-content'),
				max_veritical_scroll = this.offsetHeight * 2 - scroll_content[0].scrollHeight,
				max_horizontal_scroll = this.offsetWidth * 2 - scroll_content[0].scrollWidth,
				scrollbar_height = (this.offsetHeight / scroll_content[0].scrollHeight) * this.offsetHeight,
				scrollbar_width = (this.offsetWidth / scroll_content[0].scrollWidth) * this.offsetWidth;

			if (veritical_thumb)
			{
				if (scrollbar_height <= max_veritical_scroll || scrollbar_height > wrap.height())
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
				if (scrollbar_width <= max_horizontal_scroll || scrollbar_width > wrap.width())
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
		});
	},
	mousedown: function (event)
	{
		var target = $(event.target),
			tag = target.prop('tagName').toLowerCase(),
			direction = event.data.direction,
			veritical_thumb,
			horizontal_thumb;

		if (tag === 'a' || tag === 'input' || tag === 'img')
		{
			return false;
		}

		event.preventDefault();
		event.stopPropagation();

		while (!target.hasClass('scroll-wrap'))
		{
			target = target.parent();
		}

		target.addClass('scrolling');

		if (direction === 'veritical')
		{
			veritical_thumb = target.find('.scrollbar-veritical-thumb');
		}
		if (direction === 'horizontal')
		{
			horizontal_thumb = target.find('.scrollbar-horizontal-thumb');
		}

		event = scrollbar.isTouch ? event.originalEvent.touches[0] : event;

		if (scrollbar.isTouch)
		{
			$(document).on({
				'touchmove': scrollbar.mousemove,
				'touchend': scrollbar.mouseup
			}, {
				'scroll_target': target,
				'thumbTop': thumb.offset().top + event.clientY
			});
		}
		else
		{
			$(document).on({
				'mousemove': scrollbar.mousemove,
				'mouseup': scrollbar.mouseup
			}, {
				'scroll_target': target,
				'direction': direction,
				'thumbPos': direction === 'veritical' ? event.clientY - veritical_thumb.offset().top : event.clientX - horizontal_thumb.offset().left
			});
		}
	},
	mousemove: function (event)
	{
		var target = $(event.data.scroll_target),
			direction = event.data.direction,
			thumbPos = event.data.thumbPos,
			scrollbar_wrap = target.find('.scrollbar-' + direction + '-wrap');

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
		var scroll_content = target.find('.scroll-content'),
			horizontal_thumb = target.find('.scrollbar-horizontal-thumb'),
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
		var scroll_content = target.find('.scroll-content'),
			thumb = target.find('.scrollbar-veritical-thumb'),
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
			thumb = target.find('.scrollbar-veritical-thumb'),
			thumb_wrap = target.find('.scrollbar-veritical-wrap'),
			scroll_content = target.find('.scroll-content'),
			scrollTop,
			max_scroll,
			scale,
			thumb_max;

		scrollTop = thumb[0].offsetTop - (delta * 12);
		max_scroll = scroll_content[0].scrollHeight - scroll_content.parent().height();
		scale = scroll_content[0].scrollHeight / scroll_content.parent().height();
		thumb_max = max_scroll / scale;
		if (thumb_wrap.css('display') === 'block')
		{
			scrollbar.scroll_to_top(target, scrollTop);
			if (scrollTop < 0 || scrollTop > thumb_max)
			{
				return false;
			}
			else
			{
				event.preventDefault();
			}
		}
	}
};

$(document).ready(function ()
{
	scrollbar.init();
});