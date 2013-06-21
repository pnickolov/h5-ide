/*
#**********************************************************
#* Filename: UI.tablist
#* Creator: Cinde
#* Description: UI.tablist
#* Date: 20130620
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var tab = {
    update: function(event)
    {
        event.preventDefault();

        var target = $(this).attr('href'),
            previous_tag = $($(this).parent().parent().find('> .active')),
            previous_target = previous_tag.children('a').attr('href');

        $(previous_target).removeClass('active');
        $(target).addClass('active');
        previous_tag.removeClass('active');
        $(this).parent().addClass('active');
    }
};

$(document).ready(function ()
{
    $(document).on('click', '.tab a', tab.update);
});