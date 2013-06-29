/*
#**********************************************************
#* Filename: UI.selectbox
#* Creator: Cinde
#* Description: UI.selectbox
#* Date: 20130627
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var selectbox = {

    init: function ()
    {
        $('.selectbox').each(function()
        {
            var cur_options = $($(this).find('.selected a')[0]),
                cur_value = cur_options.html();

            $($(this).find('.cur-value')[0]).html(cur_value);
        });

        $(document).on('click', '.selectbox li a', selectbox.click);
    },

    click: function (event)
    {
        var cur_li = $(this).parent(),
            cur_value = $(this).html(),
            cur_id = $(this).data('id') ? $(this).data('id') : '',
            pre_selected = $(cur_li.siblings('.selected')[0]),
            parent_dom = $(this).parents('.selectbox'),
            label = $(cur_li.parents().find('.cur-value')[0]);

        pre_selected.removeClass('selected');
        cur_li.addClass('selected');
        label.html(cur_value);

        parent_dom.trigger("OPTION_CHANGE",[ cur_id ]);

        return false;
    }
};

$(document).ready(function ()
{
    selectbox.init();
});