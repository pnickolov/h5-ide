/*
#**********************************************************
#* Filename: UI.accordion
#* Creator: Angel
#* Description: UI.accordion
#* Date: 20130601
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var accordion = {
	show: function (event)
	{
		var accordion_head = $(this),
			accordion_group = accordion_head.parent(),
			accordion_body = accordion_group.find('.accordion-body'),
			is_collapsed = accordion_body.hasClass('expanded'),
			is_exclusive = accordion_group.parent().data('accordion-option') === 'exclusive';

		if (is_exclusive)
		{
			accordion_group.parent().find('.expanded').slideUp(300, function ()
			{
				$(this).removeClass('expanded');
			});
		}

		if (!is_collapsed)
		{
			accordion_body.slideDown(300).addClass('expanded');
		}
		else
		{
			if (!is_exclusive)
			{
				accordion_body.slideUp(300, function ()
				{
					$(this).removeClass('expanded');
				});
			}
		}
	}
};

$(document).ready(function ()
{
	$(document).on('click', '.accordion-head', accordion.show);
});