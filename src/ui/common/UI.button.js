/*
#**********************************************************
#* Filename: UI.button
#* Creator: Angel
#* Description: UI.button 
# **********************************************************
# (c)Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var button = {
	loadingText: function (event)
	{
		var target = $(event.target),
			tag = target[0].tagName.toLowerCase(),
			loading_text = target.data('loading-text'),
			original_text = tag === 'input' ? target.val() : target.text();

		target.prop("disabled", true).text(loading_text).val(loading_text);

		setTimeout(function ()
		{
			target.prop("disabled", false).text(original_text).val(original_text);
		}, 3000);
	}
};

$(document).ready(function ()
{
	$(document).on('click', '.btn[data-loading-text]', button.loadingText);
});