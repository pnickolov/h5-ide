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

(function(){
    var NOTIFICATION_TYPES = {
        "error"   : true,
        "warning" : true,
        "info"    : true
    };
    window.notification = function ( type, template, auto_close ) {
        if ( !NOTIFICATION_TYPES[ type ] )
            return;

        var notification_wrap = $('#notification_wrap');
        if ( notification_wrap.length == 0 ) {

            var close = function () {
                $(this)
                    .closest(".notification_item")
                    .addClass("closing")
                    .slideUp('fast', function () {
                        $(this).remove();
                    });
            }
            notification_wrap =
                $('<div id="notification_wrap"></div>')
                    .appendTo( $(document.body) )
                    .on('click', ".notification_close", close)
                    .on('CLOSE_ITEM', ".notification_item", close);
        }

        var item_temp = MC.template.notification.item({
            'type': type,
            'template': template,
            'should_stay': auto_close
        });

        var item_dom = $(item_temp).appendTo( notification_wrap );

        if ( !auto_close ) {
            timeout_close( item_dom, type === "error", template.length );
        }

        // Try to remove old duplicated notification when there're more than 3
        var items = notification_wrap.children(":not(.closing)");
        var item_count = items.length - 1;
        if ( item_count >= 3 ) {
            for ( var i = 0; i < item_count; ++ i ) {
                var item = items.eq( i )
                if ( item.children("span").text() === template ) {
                    // Find duplicated one, remove it.
                    to = item.trigger("CLOSE_ITEM").data( "close_to" )
                    if ( to ) { clearTimeout( to ); }
                    break;
                }
            }
        }
    };

    var timeout_close = function (target_dom, is_error, text_length) {
        stay_time = text_length * 80;
        if (is_error) {
            stay_time = stay_time + 2000
        }
        var to = setTimeout(function () { target_dom.trigger('CLOSE_ITEM'); }, stay_time);
        target_dom.data( "close_to", to );
    };
})();
