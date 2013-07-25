/*
#**********************************************************
#* Filename: UI.tabbar
#* Creator: Angel
#* Description: UI.tabbar
#* Date: 20130719
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var Tabbar = {
	mousedown: function (event)
	{
		event.preventDefault();

		if (this.id === 'tab-bar-dashboard')
		{
			Tabbar.open('dashboard');
			return false;
		}

		var target = $(this),
			position = target.position(),
			tab_list = $('#tab-bar li'),
			dragging_tab = target.clone();

		dragging_tab.css({
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
		}, Tabbar.mousemove);

		$(document).on('mouseup', {
			'target': target,
			'dragging_tab': dragging_tab
		}, Tabbar.mouseup);

		MC.canvas.volume.close();

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
			'mousemove': Tabbar.mousemove,
			'mouseup': Tabbar.mouseup
		});
		//modify by kenshin
		Tabbar.open(event.data.target.attr('id').replace('tab-bar-', ''), event.target.title, event);
	},

	add: function (tab_id, tab_name)
	{
		$('#tab-bar ul').append(
			MC.template.tab.item({
				'tab_id': tab_id,
				'tab_name': tab_name
			})
		);
		Tabbar.open(tab_id, tab_name);

		Tabbar.resize($('#tab-bar').width());

		$('#tab-bar').trigger('NEW_TAB', tab_id);
		return tab_id;
	},

	open: function (tab_id, tab_name, event)
	{
		var tab_bar = $('#tab-bar'),
			tab_item = $('#tab-bar-' + tab_id),
			original_tab = $('#tab-bar').find('.active')[0],
			original_tab_id = null;

		//add by kenshin
		if ( !original_tab && event ) {
			$( tab_bar ).find( 'ul' ).append( event.data.target );
			original_tab = $( '#tab-bar').find( '.active' )[0];
			tab_item     = $( '#tab-bar-' + tab_id );
		}

		if (!tab_item[0])
		{
			Tabbar.add(tab_id, tab_name);
			return;
		}

		if (original_tab)
		{
			original_tab_id = original_tab.id.replace('tab-bar-', '');
		}

		$('#tab-bar li').removeClass('active');
		tab_item.addClass('active');

		$('#tab-bar').trigger('OPEN_TAB', [original_tab_id, tab_id]);

		return tab_id;
	},

	close: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = $(event.target).parent(),
			tab_id = target.attr('id').replace('tab-bar-', '');

		target.remove();
		Tabbar.open($('#tab-bar li:last').attr('id').replace('tab-bar-', ''));

		$('#tab-bar').trigger('CLOSE_TAB', tab_id);

		return false;
	},

	resize: function (tabbar_width)
	{
		var tabs = $('#tab-bar li'),
			tabs_link = $('#tab-bar li a.tab-bar-truncate'),
			tab_item_width = (tabbar_width - (tabs.length * 5)) / tabs.length;

		tab_item_width = tab_item_width > 180 ? 180 : tab_item_width;
		tabs.css('width', tab_item_width);
		tabs_link.css('width', tab_item_width - 20);
	}
};

$(document).ready(function ()
{
	$('#tab-bar')
		.on('mousedown', '.close-tab', Tabbar.close)
		.on('mousedown', 'li', Tabbar.mousedown);

	$(window).resize(function ()
	{
		Tabbar.resize($('#tab-bar').width());
	});
});