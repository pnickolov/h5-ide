/*
#**********************************************************
#* Filename: UI.fixedaccordion
#* Creator: Cinde
#* Description: UI.fixedaccordion
#* Date: 20130625
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var fixedaccordion = {
    min_height: 100,

    resize: function (event)
    {
        $('.fixedaccordion').each(function(){
            var me = $(this),
                panel = me.parent(),
                sub = me.data("sub") ?  me.data("sub") : 0,
                total_height = panel.height() - sub,
                groups = me.find('.fixedaccordion-head'),
                expanded_body = me.find('.expanded .accordion-body'),
                head_height = groups.first().outerHeight(),
                heads_count = groups.length,
                expanded_height = total_height - heads_count * head_height,
                expanded_height = expanded_height > fixedaccordion.min_height ?
                    expanded_height :
                    fixedaccordion.min_height;

            $(expanded_body).outerHeight(expanded_height);
            me.data('bodyHeight', expanded_height);
        });
    },

    show: function (event)
    {
        var fixedaccordion_head = $(this),
            fixedaccordion = fixedaccordion_head.parents('.fixedaccordion').first(),
            fixedaccordion_group = fixedaccordion_head.parent(),
            fixedaccordion_body = fixedaccordion_group.find('.accordion-body'),
            expanded_group = fixedaccordion_group.parent().find('.expanded'),
            expanded_body = expanded_group.find('.accordion-body'),
            is_expanded = fixedaccordion_group.hasClass('expanded');

        if (!is_expanded)
        {
            $(fixedaccordion_body).outerHeight(fixedaccordion.data('bodyHeight'));

            fixedaccordion_body.slideDown(200, function ()
            {
                fixedaccordion_group.addClass('expanded');
            });
            expanded_body.slideUp(200, function ()
            {
                expanded_group.removeClass('expanded');
            });
        }
    }
};

$(document).ready(function ()
{
    $(document).on('click', '.fixedaccordion-head', fixedaccordion.show);
    $(window).on('resize', fixedaccordion.resize);
});