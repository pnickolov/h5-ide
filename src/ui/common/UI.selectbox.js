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

    init: function () {
        $('.selectbox').each(function () {
            var me = $(this),
                cur_options = me.find('.selected a'),
                cur_value = cur_options.html();

            me.find('.cur-value').html(cur_value);
        });

        $(document)
            .on('click', '.selectbox .dropdown-toggle', selectbox.show)
            .on('click', '.selectbox .editableoption', selectbox.add)
            .on('click', '.selectbox .editableoption .btn', selectbox.edit)
            .on('click', '.selectbox .dropdown-menu a', selectbox.select);
    },

    show: function(event) {
        $(this).parent().toggleClass('open');
        return false;
    },

    select: function (event) {
        var me = $(this),
            cur_li = me.parent(),
            box = me.parents('.selectbox').first(),
            is_editable = cur_li.hasClass('editableoption'),
            cur_value = me.html(),
            cur_id = me.data('id') ? me.data('id') : '',
            pre_selected = cur_li.siblings('.selected'),
            parent_dom = me.parents('.selectbox').first(),
            label = parent_dom.find('.cur-value');

        pre_selected.removeClass('selected');
        cur_li.addClass('selected');
        label.html(cur_value);

        parent_dom.trigger("OPTION_CHANGE", [cur_id]);

        box.removeClass('open');

        return false;
    },

    add: function (event) {
        var me = $(this),
            label = me.find('.label'),
            edit = me.find('.edit');

        label.hide();
        edit.show();
        edit.find('input').focus();

        return false;
    },

    edit: function (event) {
        var me = $(this),
            editableoption = me.parents('.editableoption').first(),
            selectbox = me.parents('.selectbox').first(),
            cur_text = selectbox.find('input').val(),
            label = editableoption.find('.label'),
            edit = editableoption.find('.edit'),
            input = edit.find('input'),
            cur_value = selectbox.find('.cur-value'),
            dropdown_menu = selectbox.find('.dropdown-menu'),
            pre_selected = dropdown_menu.find('.selected');

        if (!cur_text || cur_text.length == 0) {
            selectbox.trigger("EDIT_EMPTY");
        } else {
            input.val('');
            label.show();
            edit.hide();
            pre_selected.removeClass('selected');
            cur_value.html(cur_text);
            dropdown_menu.append('<li class="selected" tabindex="-1"><a data-id="'+ cur_text + '" href="#">'+ cur_text + '</a></li>');

            me.trigger("EDIT_UPDATE", [cur_text]);

            selectbox
                .trigger("OPTION_CHANGE", [cur_text])
                .removeClass('open');
        }
    }
};

$(document).ready(function () {
    selectbox.init();
});