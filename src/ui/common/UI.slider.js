/*
#**********************************************************
#* Filename: UI.slider
#* Creator: Song
#* Description: UI.slider
#* Date: 20130715
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

var slider = {

	value: 0,

	sliderMousedown: false,

	init: function() {
		//plugin
		(function($){
			$.fn.extend({
				setSliderValue: function(value) {
					var that = $(this);
					slider.value = value;
					that.data('value', value);
					var controllElem = that.find('.slider-controll');
					var sliderWidth = that.width();
					var step = sliderWidth / 8;
					var lastPos = (slider.value - 2) * step + 10;

					controllElem.css({
						left: lastPos + 'px'
					});
				}
			})
		})(jQuery); 
	},

	mousedown: function(event) {
		event.preventDefault();
		slider.sliderMousedown = true;
		$(this).css('background-color', '#fff');

		$(document).on('mousemove', {
			sliderElem: $(this).parent('.slider')
		}, slider.mousemove);

		$(document).on('mouseup', {
			sliderElem: $(this).parent('.slider')
		}, slider.mouseup);
	},

	mousemove: function(event) {
		event.preventDefault();
		if(slider.sliderMousedown) {
			var that = event.data.sliderElem,
				leftWidth = that.offset().left,
				currentPos = event.clientX - leftWidth,
				sliderWidth = that.width(),
				step = sliderWidth / 8,
				beyond = currentPos <= (sliderWidth + step),
				reduce = currentPos % step;

			if(currentPos < 0) {
				return true;
			}

			var controllElem = that.find('.slider-controll');

			if(reduce > step / 2){
				reduce = 0;
			}

			if(reduce && beyond){
				var lastPos = event.clientX - leftWidth + 10 - reduce;
				slider.value = 2 + (lastPos - 10) / step;
				controllElem.css({
					left: lastPos + 'px'
				});
			}
		}
	},

	mouseup: function(event) {
		event.preventDefault();
		slider.sliderMousedown = false;
		var that = event.data.sliderElem;
		that.find('.slider-controll').css('background-color', '#aaa');
		that.data('value', slider.value);
		that.trigger('SLIDER_CHANGE', slider.value);
		$(document).off({
			'mousemove': slider.mousemove,
			'mouseup': slider.mouseup
		});
	}
};

$(function() {

	slider.init();
	$(document).on('mousedown', '.slider-controll', slider.mousedown);
});