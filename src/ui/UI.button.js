/*
#**********************************************************
#* Filename: UI.button
#* Creator: Angel
#* Description: UI.button
#* Date: 20130704
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var button = {
	loadingText: function (event)
	{
		var target = $(this),
			tag = this.tagName.toLowerCase(),
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
	$(document.body).on('click', '.btn[data-loading-text]', button.loadingText);
});