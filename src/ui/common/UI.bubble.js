/*
#**********************************************************
#* Filename: UI.bubble
#* Creator: Angel
#* Description: UI.bubble
#* Date: 20130823
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

(function ()
{
	var bubble = function (event)
	{
		if (event.type === 'mouseleave')
		{
			bubble.clear();

			return false;
		}

		var target = $(this),
			content = target.data('bubble-template'),
			data = target.data('bubble-data'),
			bubble_box = $('#bubble-box'),
			coordinate = {},
			width,
			height,
			target_offset,
			target_width,
			target_height;

		if ($.trim(content) !== '')
		{
			if (!bubble_box[0])
			{
				$(document.body).append('<div id="bubble-box"><div class="arrow"></div><div id="bubble-content"></div></div>');
				bubble_box = $('#bubble-box');
			}

			$('#bubble-content').html(
				MC.template[ content ]( data )
			);

			target_offset = target.offset();
			target_width = target.innerWidth();
			target_height = target.innerHeight();

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

			bubble_box.css(coordinate).show();
		}

		bubble.timer = setInterval(function ()
		{
			if (target.closest('html').length === 0)
			{
				bubble.clear();
			}
		}, 1000);
	};

	bubble.clear = function ()
	{
		$('#bubble-box').remove();

		clearInterval(bubble.timer);
	};

	$(document).ready(function ()
	{
		$(document.body).on('mouseenter mouseleave', '.bubble', bubble);
	});
})();