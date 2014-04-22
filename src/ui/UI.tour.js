/*
#**********************************************************
#* Filename: UI.tour
#* Creator: Song
#* Description: UI.tour
#* Date: 20140415
# **********************************************************
# (c) Copyright 2014 Madeiracloud  All Rights Reserved
# **********************************************************
*/

define(['jquery'], function($) {

	$.fn.showTour = function(options) {
		$target = $(this);
		$tourBox = $(
			'<div class="user-tour">\
				<span class="user-tour-title">This is title</span>\
				<div class="user-tour-pointer"></div>\
				<div class="user-tour-pointer animation"></div>\
			</div>').appendTo('body');

		$tourPointer = $tourBox.children('.user-tour-pointer');

		var tourPos = {};
		var tourPointerPos = {};

		targetOffset = $target.offset();
		targetWidth = $target.innerWidth();
		targetHeight = $target.innerHeight();

		tourWidth = $tourBox.width();
		tourHeight = $tourBox.height();

		if (targetOffset.left + targetWidth + tourWidth - document.documentElement.scrollLeft > window.innerWidth) {
			tourPos.left = targetOffset.left - tourWidth - 15;
			tourPointerPos['margin-left'] = tourWidth + 5;
		} else {
			tourPos.left = targetOffset.left + targetWidth + 15;
			tourPointerPos['margin-left'] = -15;
		}

		tourPos.top = targetOffset.top - ((tourHeight - targetHeight) / 2);
		tourPointerPos['margin-top'] = tourHeight / 2 - 5;

		$tourPointer.css(tourPointerPos);
		$tourBox.css(tourPos).show();
	};
});
