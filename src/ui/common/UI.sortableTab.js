/*
#**********************************************************
#* Filename: UI.sortableTab
#* Creator: Angel
#* Description: UI.sortableTab
#* Date: 20130603
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var sortableTab = {
	mousedown: function (event)
	{
		event.preventDefault();

		if (this.id === 'tab-bar-dashboard')
		{
			return false;
		}

		var target = $(this),
			position = target.position(),
			tab_list = $('#tab-bar li');

		target.find('.truncate').tab('show');
		dragging_tab = target.clone().css({
			'position': 'absolute',
			'left': position.left
		});

		$('#tab-bar ul').append(dragging_tab);
		target.css('visibility', 'hidden');

		$(document).on('mousemove', {
			'target': target,
			'dragging_tab': dragging_tab,
			'offset_left': $('#tab-bar').offset().left + event.pageX - target.offset().left,
			'tab_list': tab_list,
			'tab_width': tab_list.width()
		}, sortableTab.mousemove);

		$(document).on('mouseup', {
			'target': target,
			'dragging_tab': dragging_tab
		}, sortableTab.mouseup);

		return false;
	},

	mousemove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var left = event.pageX - event.data.offset_left,
			index = Math.round(left / event.data.tab_width),
			length = event.data.tab_list.length;

		left = left > 0 ? left : 0;

		event.data.dragging_tab.css('left', left);

		if (index > 0)
		{
			if (index >= length)
			{
				event.data.tab_list.eq(length - 1).after(event.data.target);
			}
			else
			{
				event.data.tab_list.eq(index).before(event.data.target);
			}
		}
	},

	mouseup: function (event)
	{
		event.data.target.css('visibility', 'visible');
		event.data.dragging_tab.remove();
		$(document).off({
			'mousemove': sortableTab.mousemove,
			'mouseup': sortableTab.mouseup
		});
	}
};

$(document).ready(function ()
{
	$('#tab-bar').on('mousedown', 'li', sortableTab.mousedown);
});