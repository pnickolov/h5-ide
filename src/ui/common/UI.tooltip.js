// Tooltip
// Author: Angel
var tooltip = {
	show: function (event)
	{
		var target = $(event.target),
			content = target.data('tooltip'),
			target_offset = target.offset(),
			tooltip_box = $('#tooltip_box');

		if ($.trim(content) != '')
		{
			if (!tooltip_box[0])
			{
				$(document.body).append('<div id="tooltip_box"></div>');
			}
			$('#tooltip_box').text(content).css({
				'top': target_offset.top + target.height() + 10,
				'left': target_offset.left + 5
			}).show();
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