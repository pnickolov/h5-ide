/*
#**********************************************************
#* Filename: UI.tooltip
#* Creator: Angel
#* Description: UI.tooltip
#* Date: 20130823
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

(function ()
{
	var tooltip = function (event)
	{
		var target = $(this),
			content = $.trim(target.data('tooltip')),
			tooltip_box = $('#tooltip_box'),
			target_offset,
			width,
			height,
			target_width,
			target_height,
			tooltip_timer;

    if (content !== '' && !target.hasClass('parsley-error'))
		{
			if (!tooltip_box[0])
			{
				$(document.body).append('<div id="tooltip_box"></div>');
				tooltip_box = $('#tooltip_box');
			}

			tooltip_box.text(content);

			if (target.prop('namespaceURI') === 'http://www.w3.org/2000/svg')
			{
				target_offset = target[0].getBoundingClientRect();
				target_width = target_offset.width;
				target_height = target_offset.height;
			}
			else
			{
				target_offset = target.offset();
				target_width = target.innerWidth();
				target_height = target.innerHeight();
			}

			width = tooltip_box.width();
			height = tooltip_box.height();
			
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
})();
