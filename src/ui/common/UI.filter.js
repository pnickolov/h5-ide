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
    update: function (dom, valueset) {
        if (!valueset || ((!valueset.type) && valueset.value == '')) {
            dom.trigger("FILTER_RESET");
            dom.find('.item').each(function () {
                $(this).removeClass('hide');
            });
        } else {
            dom.trigger("FILTER_SET");
            dom.find('.item').each(function () {
                var is_match = true,
                    target_id = $(this).data('id'),
                    dom = $(this);

                if (valueset.value) {
                    if (target_id.toLowerCase().indexOf(valueset.value.toLowerCase()) < 0) {
                        is_match = false;
                    }
                }

                if (valueset.type && is_match) {
                    var type_result = true,
                        type_set = valueset.type;

                    $.each(type_set, function (key, value) {
                        if (type_set.hasOwnProperty(key)) {
                            var target_value = dom.data(key);

                            if (!target_value && value) {
                                type_result = false;
                            } else if (value && String(target_value).toLowerCase() != String(value).toLowerCase()) {
                                type_result = false;
                            }
                        }
                    });

                    is_match = type_result;
                }
                $(this).toggleClass('hide', !is_match);
            });
        }
    }
};