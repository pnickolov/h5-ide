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

/* A modified version to reduce redundant html code by Morris */

// var selectbox = {

//     add: function (event) {
//         var me = $(this),
//             label = me.find('.label'),
//             edit = me.find('.edit');

//         label.hide();
//         edit.show();
//         edit.find('input').focus();

//         return false;
//     },

//     edit: function (event) {
//         var me = $(this),
//             editableoption = me.parents('.editableoption').first(),
//             selectbox = me.parents('.selectbox').first(),
//             cur_text = selectbox.find('input').val(),
//             label = editableoption.find('.label'),
//             edit = editableoption.find('.edit'),
//             input = edit.find('input'),
//             cur_value = selectbox.find('.cur-value'),
//             dropdown_menu = selectbox.find('.dropdown-menu'),
//             pre_selected = dropdown_menu.find('.selected');

//         if (!cur_text || cur_text.length == 0) {
//             selectbox.trigger("EDIT_EMPTY");
//         } else {
//             input.val('');
//             label.show();
//             edit.hide();
//             pre_selected.removeClass('selected');
//             if(cur_value) {
//                 cur_value.html(cur_text);
//             }
//             dropdown_menu.append('<li class="selected" tabindex="-1"><a data-id="'+ cur_text + '" href="#">'+ cur_text + '</a></li>');

//             me.trigger("EDIT_UPDATE", [cur_text]);

//             selectbox
//                 .trigger("OPTION_CHANGE", [cur_text])
//                 .removeClass('open');
//         }
//     }
// };

var selectbox = {
    init : function () {
        $(".selectbox").each(function () {
            var $this = $(this);
            $this.find(".selection").html( $this.find(".selected").html () );
        });
    }
};

(function(){

    function toggle ( event ) {

        // TODO : OPTION_SHOW event is now bound to the selectbox

        var $selectbox = $( event.currentTarget ).closest(".selectbox");

        if ( $selectbox.hasClass('open') ) {
            $selectbox.removeClass('open');
            return false;
        }
        
        var $dropdown  = $selectbox.addClass('open')
                                   .find(".dropdown");

        $dropdown.find(".focused")
                 .removeClass('focused');

        $dropdown.find(".selected")
                 .focus().addClass('focused');


        // Close dropdown during next click.
        $(document.body).one('click', function( event ){
            $selectbox.removeClass('open');
        });

        $selectbox.trigger("OPTION_SHOW");
        return false;

    }

    function select ( event ) {

        // Update Selected Item
        var $this = $( event.currentTarget ).addClass('selected');
        $this.siblings(".selected").removeClass('selected');

        // Set the value to select and close dropdown
        var $selectbox = $this.closest(".selectbox").removeClass('open');
        $selectbox.find(".selection").html( $this.html() );

        // TODO : OPTION_CHANGE's parameter no long is array.
        $selectbox.trigger( "OPTION_CHANGE", $this.attr('data-id') );

        return false;
    }

    function keydown ( event ) {

        if ( !window.dddddd ) {
            window.dddddd = 1;
        } else {
            ++window.dddddd;window
        }

        if( !/(38|40|13|27)/.test(event.which) )
            return;

        var $dropdown = $( event.currentTarget );

        if ( event.which == 27 ) {
            // Esc
            $dropdown.closest(".selectbox").removeClass('open');
            return false;
        }

        if ( event.which == 13 ) {
            // Enter
            if ( !$dropdown.hasClass('selected') ) {
                event.currentTarget = $dropdown.find(".focused");
                select( event );
            }

            return false;
        }

        var $options  = $dropdown.children();
        var index     = $options.filter(".focused").removeClass('focused').index();

        if ( event.which == 40 ) {
            index = index < $options.length - 1 ? index + 1 : 0;
        } else {
            index = index > 1 ? index - 1 : $options.length - 1;
        }

        $options.eq( index ).addClass('focused').focus();

        return false;
    }


    function add () {

    }

    function edit () {

    }

    $(function(){
        selectbox.init();
        $(document.body)
            .on('click',   ".selectbox",                 false)
            .on('click',   ".selectbox .selection",      toggle)
            .on('click',   ".selectbox .dropdown .item", select)
            .on('click',   ".selectbox .editor",         add)
            .on('click',   ".selectbox .editor .btn",    edit)
            .on('keydown', ".selectbox.open .dropdown",  keydown);
    });

})();
