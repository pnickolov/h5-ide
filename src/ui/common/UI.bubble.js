/*
#**********************************************************
#* Filename: UI.bubble
#* Creator: Angel
#* Description: UI.bubble
#* Date: 20130612
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var bubble = {
	show: function (event)
	{
		var target = $(this),
			content = target.data('bubble-template'),
			data = target.data('bubble-data'),
			target_offset = target.offset(),
			bubble_box = $('#bubble-box'),
			coordinate = {},
			width,
			height;

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

			width = bubble_box.width();
			height = bubble_box.height();

			if (target_offset.left + width - document.body.scrollLeft > window.innerWidth)
			{
				coordinate.left = target_offset.left - width - 15;
				bubble_box.addClass('bubble-right');
			}
			else
			{
				coordinate.left = target_offset.left + target.innerWidth() + 15;
				bubble_box.addClass('bubble-left');
			}

			coordinate.top = target_offset.top + height - document.body.scrollTop + 45 > window.innerHeight ?
				target_offset.top:
				target_offset.top - ((height - target.innerHeight()) / 2);

			bubble_box.css(coordinate).show();
		}
	},
	hide: function ()
	{
		$('#bubble-box').remove();
	}
};

$(document).ready(function ()
{
	$(document).on('mouseenter', '.bubble', bubble.show);
	$(document).on('mouseleave', '.bubble', bubble.hide);
});