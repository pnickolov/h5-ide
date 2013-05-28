/*
#**********************************************************
#* Filename: UI.table
#* Creator: Angel
#* Description: UI.table
#* Date: 20130528
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var table = {};

table.edit = function (event)
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
};

table.update = function (event)
{
	var target = event.target;

	$(target).parent().text(target.value);
}

$(document).ready(function ()
{
	$(document).on('click', '.table td.editable', table.edit);
	$(document).on('blur', '.table-input', table.update);
});