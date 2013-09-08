/*
#**********************************************************
#* Filename: UI.editablelabel
#* Creator: Cinde
#* Description: UI.editablelabel
#* Date: 20130614
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var editablelabel = {
    create: function(event)
    {
        var div_element = $(this);

        div_element.off('click');
        div_element.html('<input type="text" value="' + div_element.html() + '" />');
        div_element.find('input').first().focus().on('blur', editablelabel.finish);
    },

    finish: function(event)
    {
        var me = $(this),
            cur_text = this.value,
            div_element = me.parent();

        me.remove();
        div_element.html(cur_text);
        div_element.trigger("EDIT_UPDATE");
        div_element.on('click', editablelabel.create);
    }
};

$(document).ready(function ()
{
    $('.editable-label').on('click', editablelabel.create);
});