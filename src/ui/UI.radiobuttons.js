/*
#**********************************************************
#* Filename: UI.radiobuttons
#* Creator: Cinde
#* Description: UI.radiobuttons
#* Date: 20130629
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var radiobuttons = {

    init: function () {
        $(document).on('click', '.radiobuttons button', radiobuttons.click);
    },

    click: function (event) {
        var me = $(this),
            btns = me.parent(),
            is_active = me.hasClass('active'),
            pre_active = btns.find('.active'),
            cur_value = me.data('radio');

        if (cur_value == undefined) {
            cur_value = me.text();
        }

        if (!is_active) {
            if (pre_active.length > 0) {
                pre_active.removeClass('active');
            }
            me.addClass('active');

            me.trigger("RADIOBTNS_CLICK", [cur_value]);
        }

        return false;
    },

    data: function (dom) {
        var pre_active = dom.find('.active');

        if (pre_active.length > 0) {
            cur_value = pre_active.data('radio');

            if (cur_value == undefined) {
                cur_value = pre_active.text();
            }

            return cur_value;
        } else {
            return '';
        }
    }
};

$(document).ready(function () {
    radiobuttons.init();
});