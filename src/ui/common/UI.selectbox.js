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
                cur_value = cur_options.html(),
                label = me.find('.cur-value');
            if(label) {
                label.html(cur_value);
            }
        });
    },

    show: function(event) {
        $(this).parent().toggleClass('open');
        $(this).parent().find('.selected').focus().addClass('focused');
        return false;
    },

    keydown: function(event) {
        if(!/(38|40|27)/.test(event.which))
            return

        event.preventDefault();
        event.stopPropagation();

        var me = $(this),
            list_items = me.find('li'),
            key_code = event.which,
            pre_focused = me.find('.focused'),
            update_selected,
            index,
            update_value;

        index = list_items.index(list_items.filter('li.focused'));

        if(key_code == 40) {
            index = index < list_items.length - 1 ? index + 1 : 0;
        } else if (key_code == 38) {
            index = index > 1 ? index - 1 : list_items.length - 1;
        } else if(key_code == 27) {
            index = 0;
        }

        pre_focused.removeClass('focused');
        list_items.eq(index).addClass('focused').focus();
    },

    select: function (event) {
        var me = $(this),
            cur_li = me.parent(),
            box = me.parents('.selectbox').first(),
            cur_value = me.html(),
            cur_id = me.data('id') ? me.data('id') : '',
            pre_selected = cur_li.siblings('.selected'),
            parent_dom = me.parents('.selectbox').first(),
            remove_after_click = cur_li.hasClass('remove-after-click'),
            label = parent_dom.find('.cur-value');

        pre_selected.removeClass('selected').removeClass('focused');
        cur_li.addClass('selected').addClass('focused');
        
        if(label) {
            label.html(cur_value);
        }

        if(remove_after_click) {
            cur_li.remove();
        }

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
            if(cur_value) {
                cur_value.html(cur_text);
            }
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

    $(document)
        .on('click', '.selectbox .dropdown-toggle', selectbox.show)
        .on('click', '.selectbox .editableoption', selectbox.add)
        .on('click', '.selectbox .editableoption .btn', selectbox.edit)
        .on('click', '.selectbox .dropdown-menu a', selectbox.select)
        .on('keydown', '.open .dropdown-menu', selectbox.keydown);
});