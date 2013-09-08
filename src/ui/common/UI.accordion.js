/*
#**********************************************************
#* Filename: UI.accordion
#* Creator: Angel
#* Description: UI.accordion
#* Date: 20130704
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
			is_expanded = accordion_group.hasClass('expanded'),
			is_exclusive = accordion_group.parent().data('accordion-option') === 'exclusive';

		if (is_exclusive)
		{
			accordion_group.parent().find('.expanded .accordion-body').slideUp(300, function ()
			{
				$(this).parent().removeClass('expanded');
			});
		}

		if (!is_expanded)
		{
			accordion_body.slideDown(300, function ()
			{
				accordion_group.addClass('expanded');
			});
		}
		else
		{
			if (!is_exclusive)
			{
				accordion_body.slideUp(300, function ()
				{
					accordion_group.removeClass('expanded');
				});
			}
		}
	}
};

$(document).ready(function ()
{
	$(document.body).on('click', '.accordion-head', accordion.show);
});