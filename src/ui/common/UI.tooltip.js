/*
#**********************************************************
#* Filename: UI.tooltip
#* Creator: Angel
#* Description: UI.tooltip
#* Date: 20130527
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var tooltip = {
	show: function (event)
	{
		var target = $(event.target),
			content = target.data('tooltip'),
			target_offset = target.offset(),
			tooltip_box = $('#tooltip_box'),
			coordinate = {},
			width,
			height;

		if ($.trim(content) != '')
		{
			if (!tooltip_box[0])
			{
				$(document.body).append('<div id="tooltip_box"></div>');
				tooltip_box = $('#tooltip_box');
			}

			tooltip_box.text(content);

			width = tooltip_box.width();
			height = tooltip_box.height();

			coordinate.left =  target_offset.left + width > window.innerWidth ? target_offset.left - width :  target_offset.left + 5;
			coordinate.top = target_offset.top + height > window.innerHeight ? target_offset.top - height + 10 : target_offset.top + target.height() + 15;

			tooltip_box.css(coordinate).show();
		}
	},
	hide: function ()
	{
		$('#tooltip_box').hide();
	}
};

$(document).ready(function ()
{
	$(document).on('mouseenter', '.tooltip', tooltip.show);
	$(document).on('mouseleave', '.tooltip', tooltip.hide);
});