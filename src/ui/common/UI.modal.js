/*
#**********************************************************
#* Filename: UI.modal
#* Creator: Angel
#* Description: UI.modal
#* Date: 20130620
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var modal = function (template, dismiss, callback)
{
	var modal_wrap = $('#modal-wrap');

	if (!modal_wrap[0])
	{
		$(document.body).append('<div id="modal-wrap"></div>');
		modal_wrap = $('#modal-wrap');
	}

	modal_wrap.html('<div id="modal-box">' + template + '</div>');

	$('#modal-box').children(':first').show();

	modal.position();

	if (dismiss === true)
	{
		$(document).on('click', modal.dismiss);
	}

	$(window).on('resize', modal.position);
	$(document)
		.on('click', '.modal-close', modal.close)
		.on('mousedown', '.modal-header', modal.drag.mousedown);

	if (callback)
	{
		callback();
	}
};

modal.open = function (event)
{
	var target = $(this),
		target_template = target.data('modal-template'),
		target_data = target.data('modal-data');

	if (target_template && target_data)
	{
		modal(
			MC.template[ target_template ]( target_data ),
			target.data('modal-dismiss')
		);
		target.trigger('modal-shown');

		$('#modal-wrap').one('closed', function ()
		{
			target.trigger('modal-closed');
		});
	}
};

modal.dismiss = function (event)
{
	if (event.target.id === 'modal-wrap')
	{
		modal.close();
		$(document).off('click', modal.dismiss);
	}
};

modal.close = function ()
{
	$(window).off('resize', modal.position);

	$(document)
		.off('click', '.modal-close', modal.close)
		.off('mousedown', '.modal-header', modal.drag.mousedown);

	$('#modal-wrap')
		.trigger('closed')
		.remove();
};

modal.drag = {
	mousedown: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		var target = $('#modal-box'),
			target_position = target.position();

		$(document).on({
			'mousemove': modal.drag.mousemove,
			'mouseup': modal.drag.mouseup
		}, {
			'target': target,
			'left': event.pageX - target_position.left,
			'top': event.pageY - target_position.top
		});
	},

	mousemove: function (event)
	{
		event.preventDefault();
		event.stopPropagation();

		event.data.target.css({
			'top': event.pageY - event.data.top,
			'left': event.pageX - event.data.left
		});

		return false;
	},

	mouseup: function (event)
	{
		var target = event.data.target,
			position = target.position(),
			height = target.height(),
			width = target.width(),
			prop = {};

		if (position.top < 0)
		{
			prop['top'] = 10;
		}

		if (position.left < 0)
		{
			prop['left'] = 10;
		}

		if (position.top > window.innerHeight - height)
		{
			prop['top'] = window.innerHeight - height - 10;
		}

		if (position.left > window.innerWidth - width)
		{
			prop['left'] = window.innerWidth - width - 25;
		}

		if (!$.isEmptyObject(prop))
		{
			target.animate(prop, 300);
		}

		$(document).off({
			'mousemove': modal.drag.mousemove,
			'mouseup': modal.drag.mouseup
		});
	}
};

modal.position = function ()
{
	var modal_box = $('#modal-box');

	modal_box.css({
		'top': (window.innerHeight - modal_box.height()) / 2,
		'left': (window.innerWidth - modal_box.width()) / 2
	});
};

$(document).ready(function ()
{
	$(document).on('click', '.modal', modal.open);
});