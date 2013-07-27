/*
#**********************************************************
#* Filename: MC.template.js
#* Creator: Angel
#* Description: The file to storage HTML templates
#* Date: 20130724
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

var MC = MC || {},
	TEMPLATE_LOCATION = './ui/common/MC.template.html';

$.get(TEMPLATE_LOCATION, function (data)
{
	var data = data.split(/\<!-- (.*) --\>/ig),
		template = {},
		i = 1,
		l = data.length,
		space_label,
		space,
		label_length;

	for (; i < l; i += 2)
	{
		space = template;
		space_labels = data[ i ].split('.');
		label_length = space_labels.length - 1;

		$.each(space_labels, function (index, value)
		{
			if (!space[ value ])
			{
				space[ value ] = {};
			}

			if (label_length === index)
			{
				space[ value ] = Handlebars.compile(data[ i + 1 ].trim());
			}
			else
			{
				space = space[ value ];
			}
		});
	}

	MC.template = template;
});