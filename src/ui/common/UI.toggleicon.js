/*
#**********************************************************
#* Filename: UI.toggleicon
#* Creator: Cinde
#* Description: UI.toggleicon
#* Date: 20130627
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var toggleicon = {
    init: function () {
        $(document).on('click', '.toggle-icon', toggleicon.click);
    },

    click: function (event) {
        var me = $(this),
            toggle_class = me.data('toggleclass'),
            is_active = me.hasClass(toggle_class),
            toggle_text = me.data('toggletext'),
            toggle_active_text = me.data('toggleactive'),
            cur_id = me.data('id') ? me.data('id') : '';

        me.toggleClass(toggle_class).data('tooltip', is_active ? toggle_text : toggle_active_text);
        $('#tooltip_box').text(is_active ? toggle_text : toggle_active_text);

        me.trigger("TOGGLE_ICON", [cur_id]);

        return false;
    }
};

$(document).ready(function () {
    toggleicon.init();
});