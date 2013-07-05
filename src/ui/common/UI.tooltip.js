/*
#**********************************************************
#* Filename: UI.tooltip
#* Creator: Angel
#* Description: UI.tooltip
#* Date: 20130704
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var tooltip = function (event)
{
	if (event.type === 'mouseleave')
	{
		$('#tooltip_box').hide();
		return false;
	}

	var target = $(this),
		content = $.trim(target.data('tooltip')),
		target_offset = target.offset(),
		tooltip_box = $('#tooltip_box'),
		width,
		height,
		target_width,
		target_height;

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
		}).fadeIn("fast");
	}
};

$(document).ready(function ()
{
	$(document.body).on('mouseenter mouseleave', '.tooltip', tooltip);
});