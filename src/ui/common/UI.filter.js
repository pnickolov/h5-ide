/*
#**********************************************************
#* Filename: UI.filter
#* Creator: Cinde
#* Description: UI.filter
#* Date: 20130627
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var filter = {
    update: function (dom, value)
    {
        dom.find('.item').each(function()
        {
            var cur_val = $(this).data('id');

            if(!value) {
                filter.reset(dom);
            } else {
                if(cur_val.indexOf(value) >= 0)
                {
                    $(this).removeClass('hide');
                } else {
                    $(this).addClass('hide');
                }
            }
        });
    },

    reset: function (dom)
    {
        dom.find('.item').each(function()
        {
            $(this).removeClass('hide');
        });
    }
};