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

    init: function () {
        $(document)
            .on('click', '.search-bar .icon-search', searchbar.show)
            .on('click', '.search-bar .icon-cancel', searchbar.hide)
            .on('keyup', '.search-bar input', searchbar.change);
    },

    show: function (event) {
        var me = $(this),
            cur_bar = me.parent(),
            cur_input = cur_bar.find('input'),
            cur_cancel = cur_bar.find('.icon-cancel'),
            // total_width = me.outerWidth() + cur_input.outerWidth() + cur_cancel.outerWidth() - 14;
            total_width = 246; // Resource Panel width

        cur_bar.animate({
            width: total_width + 'px'
        }, {
            duration: 100,

            complete: function () {
                $(this).addClass('open');
                cur_input.focus();
                cur_bar.trigger("SEARCHBAR_SHOW");
            }
        });

        return false;
    },

    hide: function (event) {
        var me = $(this),
            cur_bar = me.parent(),
            cur_input = cur_bar.find('input'),
            cur_search = cur_bar.find('.icon-search'),
            sub_width = cur_search.outerWidth();

        cur_bar.animate({
            width: sub_width + 'px'
        }, {
            duration: 100,

            complete: function () {
                $(this).removeClass('open');
                cur_input.val('');
                cur_bar.trigger("SEARCHBAR_HIDE");
            }
        });

        return false;
    },

    change: function (event) {
        var me = $(this),
            cur_value = me.val();

        me.trigger("SEARCHBAR_CHANGE", [cur_value]);

        return false;
    }
};

$(document).ready(function () {
    searchbar.init();
});