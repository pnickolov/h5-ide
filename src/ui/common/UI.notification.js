/*
#**********************************************************
#* Filename: UI.notification
#* Creator: Cinde
#* Description: UI.notification
#* Date: 20130607
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var notification = function (type, template, auto_close)
{
    var NOTIFICATION_TYPES = ["error", "warning", "info"];

    if ($.inArray(type, NOTIFICATION_TYPES) >= 0) {
        var notification_wrap = $('#notification_wrap'),
            should_stay = type === "error" || auto_close;

        if (!notification_wrap[0]) {
            $(document.body).append('<div id="notification_wrap"></div>');
            notification_wrap = $('#notification_wrap');
            notification_wrap.on('click', '.notification_close', function(event) {
                $(this).parent().slideUp('fast', function() {
                    $(this).remove();
                });
            });
        }

        notification_wrap.append(
            MC.template.notification.item( {
                'type': type,
                'template': template,
                'should_stay': should_stay
            })
        );

        if (!should_stay) {
            var item_dom = notification_wrap.find('.notification_item').eq(-1);
            notification.out($(item_dom));
        }
    }
};

notification.out = function (target_dom)
{
    setTimeout(function() {
        target_dom.slideUp("fast", function() {
            target_dom.remove();
        })
    } ,2000);
};