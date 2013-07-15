/*
#**********************************************************
#* Filename: UI.secondarypanel
#* Creator: Cinde
#* Description: UI.secondarypanel
#* Date: 20130709
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var secondarypanel = function (template, parent_dom)
{
    var panel_wrap = $('#secondary-panel-wrap'),
        parent = parent_dom,
        total_width = parent.width();

    if (!panel_wrap[0])
    {
        parent.append('<div id="secondary-panel-wrap"></div>');
        panel_wrap = $('#secondary-panel-wrap');
    }

    panel_wrap.html(template).height(parent.height()).show();
    panel_wrap.width(total_width);
    panel_wrap.css("right",-total_width);

    panel_wrap.animate({
        right: 0
      }, {
        duration: 200,
        specialEasing: {
            width: 'linear'
        },
        complete: function() {
            $('.property-details').hide();
        }
    });

    return this;
};

secondarypanel.open = function (dom, template)
{
    var target = dom,
        parent = target.parents('.first-panel').first();

    if (template)
    {
        secondarypanel(
            template,
            parent
        );
        target.trigger('secondary-panel-shown');

        $('#secondary-panel-wrap').one('closed', function ()
        {
            target.trigger('secondary-panel-closed');
        });
    }
    return false;
};

secondarypanel.close = function ()
{
    var panel_wrap = $('#secondary-panel-wrap'),
        sub_width = panel_wrap.width();

    $(document.body)
        .off('click', '.back', secondarypanel.close);

    $('.property-details').show();

    panel_wrap
        .animate({
            right: -sub_width
        }, {
            duration: 200,
            specialEasing: {
              width: 'linear'
            },
        complete: function() {
            $(this).trigger('closed').remove();
        }
        });

    return false;
};

$(document).ready(function ()
{
    //$(document.body).on('click', '.secondary-panel', secondarypanel.open);
    $(document.body).on('click', '.back', secondarypanel.close);
});