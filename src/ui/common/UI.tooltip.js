/*
#**********************************************************
#* Filename: UI.tooltip
#* Creator: Angel
#* Description: UI.tooltip
#* Date: 20130810
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var tooltip = function (event)
{
	var target = $(this),
		content = $.trim(target.data('tooltip')),
		target_offset = target.offset(),
		tooltip_box = $('#tooltip_box'),
		width,
		height,
		target_width,
		target_height,
		tooltip_timer;

	if (content !== '')
	{
		if (!tooltip_box[0])
		{
			$(document.body).append('<div id="tooltip_box"></div>');
			tooltip_box = $('#tooltip_box');
		}

		tooltip_box.text(content);

		width = tooltip_box.width();
		height = tooltip_box.height();
		target_width = target.innerWidth();
		target_height = target.innerHeight();

		tooltip_box.css({
			'left': target_offset.left + width - document.body.scrollLeft > window.innerWidth ?
				target_offset.left - width :
				target_offset.left + 5,
			'top': target_offset.top + target_height + height - document.body.scrollTop + 45 > window.innerHeight ?
				target_offset.top - height - 15 :
				target_offset.top + target_height + 8
		}).show();

		$(document.body).on('mouseleave', '.tooltip', tooltip.clear);

		tooltip.timer = setInterval(function ()
		{
			if (target.closest('html').length === 0)
			{
				tooltip.clear();
			}
		}, 1000);
	}
};

tooltip.clear = function ()
{
	$('#tooltip_box').hide();
	$(document.body).off('mouseleave', '.tooltip', tooltip.clear);

	clearInterval(tooltip.timer);
};

$(document).ready(function ()
{
	$(document.body).on('mouseenter', '.tooltip', tooltip);
});