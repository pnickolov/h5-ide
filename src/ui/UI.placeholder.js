/*
#**********************************************************
#* Filename: UI.placeholder
#* Creator: Angel
#* Description: UI.placeholder
#* Date: 20130812
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

$(document).ready(function ()
{
	$(document.body).on('focus blur keyup', '.placeholder-input .input', function (event)
	{
		var target = $(this);

		if (target.val() !== '')
		{
			target.parent().addClass('placeholder-hasContent');
		}
		else
		{
			target.parent().removeClass('placeholder-hasContent');
		}
	});
});