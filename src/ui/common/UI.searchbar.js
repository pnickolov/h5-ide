/*
#**********************************************************
#* Filename: UI.searchbar
#* Creator: Cinde
#* Description: UI.searchbar
#* Date: 20130627
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var searchbar = {

    init: function ()
    {
        $(document).on('click', '.search-bar .icon-search', searchbar.show);
        $(document).on('click', '.search-bar .icon-cancel', searchbar.hide);
        $(document).on('keyup', '.search-bar input', searchbar.change);
    },

    show: function (event)
    {
        var cur_bar = $(this).parent(),
            cur_input = $(cur_bar.find('input')[0]),
            cur_cancel = $(cur_bar.find('.icon-cancel')[0]),
            total_width = $(this).outerWidth() + cur_input.outerWidth() + cur_cancel.outerWidth() + 10;

        cur_bar.animate({
            width: total_width + 'px'
          }, {
            duration: 1000,

            complete: function() {
                $(this).addClass('open');
                cur_input.focus();
                cur_bar.trigger("SEARCHBAR_SHOW");
            }
        });

        return false;
    },

    hide: function (event)
    {
        var cur_bar = $(this).parent(),
            cur_search = $(cur_bar.find('.icon-search')[0]),
            sub_width = cur_search.outerWidth();

        cur_bar.animate({
            width: sub_width + 'px'
          }, {
            duration: 1000,

            complete: function() {
                $(this).removeClass('open');
                cur_bar.trigger("SEARCHBAR_HIDE");
            }
        });

        return false;
    },

    change: function (event)
    {
        var cur_value = $(this).val();

        $(this).parent().trigger("SEARCHBAR_CHANGE", [cur_value]);

        return false;
    }
};

$(document).ready(function ()
{
    searchbar.init();
});