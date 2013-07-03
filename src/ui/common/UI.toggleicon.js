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
    addfav_text: 'Add to Favorite',
    faved_text: 'Remove from Favorite',
    faved_class: 'faved',

    init: function () {
        $(document).on('click', '.toggle-fav', toggleicon.click);
    },

    click: function (event) {
        var me = $(this),
            is_faved = me.hasClass(toggleicon.faved_class),
            cur_id = me.data('id') ? me.data('id') : '';

        me.toggleClass(toggleicon.faved_class).data('tooltip', is_faved ? toggleicon.addfav_text : toggleicon.faved_text);
        $('#tooltip_box').text(is_faved ? toggleicon.addfav_text : toggleicon.faved_text);

        me.trigger("TOGGLE_FAV", [cur_id]);

        return false;
    }
};

$(document).ready(function () {
    toggleicon.init();
});