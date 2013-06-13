/*
#**********************************************************
#* Filename: UI.table
#* Creator: Angel
#* Description: UI.table
#* Date: 20130611
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var table = {
	edit: function (event)
	{
		if (event.target.tagName.toLowerCase() === 'input')
		{
			return false;
		}
		else
		{
			var row = $(this),
				row_height = row.css('height'),
				input = row.html('<input class="table-input" type="text" value="' + row.text() + '"/>').children(':first');

			$(input).css({
				'color': row.css('color'),
				'font-size': row.css('font-size')
			}).focus();
		}
	},

	update: function (event)
	{
		var target = event.target;

		$(target).parent().text(target.value);
	},

	sort: function (event)
	{
		var target = $(this),
			index = target.index() + 1,
			thead = target.parent().parent(),
			tbody = thead.parent().find('tbody'),
			rows = tbody.find('tr'),
			order = target.hasClass('desc-sort') ? 'DESC' : 'ASC';
			stack = [];

		thead.find('.active').removeClass('active');
		target.addClass('active');

		rows.map(function ()
		{
			stack.push({
				'item': this,
				'value': $(this).find('td:nth-child(' + index + ')').text().toLowerCase()
			});
		});

		if (order === 'DESC')
		{
			stack.sort(function (a, b)
			{
				if (!isNaN(parseInt(a.value)))
				{
					return a.value - b.value;
				}

				if (typeof a.value === 'string')
				{
					return a.value.localeCompare(b.value);
				}
			});
			target.removeClass('desc-sort');
		}
		else
		{
			stack.sort(function (a, b)
			{
				if (!isNaN(parseInt(a.value)))
				{
					return b.value - a.value;
				}

				if (typeof a.value === 'string')
				{
					return b.value.localeCompare(a.value);
				}
			});
			target.addClass('desc-sort');
		}

		tbody.empty();
		$.each(stack, function (i, row)
		{
			tbody.append(row.item);
		});
	}
};

$(document).ready(function ()
{
	$(document)
		.on('click', '.table td.editable', table.edit)
		.on('click', '.table .sortable', table.sort)
		.on('blur', '.table-input', table.update);
});