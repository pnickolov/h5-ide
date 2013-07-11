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
        duration: 500,
        specialEasing: {
            width: 'linear'
        }
    });

    return this;
};

secondarypanel.open = function (event)
{
    var target = $(this),
        target_template = target.data('secondarypanel-template'),
        target_data = target.data('secondarypanel-data'),
        parent = target.parents('.first-panel').first(),
        stopSecondaryPanel = $(event.target).hasClass('prevent-secondary');

    if(stopSecondaryPanel) {
        target.trigger("PREVENT_SECONDARY", $(event.target));
        return false;
    }

    if (target_template && target_data)
    {
        secondarypanel(
            MC.template[ target_template ]( target_data ),
            parent
        );
        target.trigger('secondary-panel-shown', target_data);

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

    panel_wrap
        .animate({
            right: -sub_width
        }, {
            duration: 500,
            specialEasing: {
              width: 'linear'
            },
        complete: function() {
            $(this).trigger('closed').remove();
        }
        })

    return false;
};

$(document).ready(function ()
{
    $(document.body).on('click', '.secondary-panel', secondarypanel.open);
    $(document.body).on('click', '.back', secondarypanel.close);
});