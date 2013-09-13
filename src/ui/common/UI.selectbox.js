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
/* In-coporate the toggle-dropdown functions from bootstrap-dropdown */

var selectbox = {
    init : function () {
        $(".selectbox").each(function () {
            var $this = $(this);
            var $selected = $this.find(".selected");

            // If there's no item selected, select the first one.
            if ( $selected.length == 0 ) {
                $selected = $this.find(".item:first-child").addClass("selected");
            }

            $this.find(".selection").html( $selected.html() );
        });
    }
};

(function(){

    function toggle ( event ) {

        var $selectbox = $( event.currentTarget ).closest(".selectbox");

        if ( $selectbox.hasClass('open') ) {
            $selectbox.removeClass('open');
            return false;
        }

        // Close other opened dropdown
        $(".selectbox.open").removeClass('open');

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
        var $prev = $this.siblings(".selected").removeClass('selected');

        // Set the value to select and close dropdown
        var $selectbox = $this.closest(".selectbox").removeClass('open');

        var $selection = $selectbox.find(".selection").html( $this.html() );

        var evt = $.Event("OPTION_CHANGE")

        $selectbox.trigger( evt, $this.attr('data-id') );

        if ( evt.isDefaultPrevented() ) {
            // Revert
            $this.removeClass("selected");
            $prev.addClass("selected");
            $selection.html( $prev.html() );
        }

        return false;
    }

    function keydown ( event ) {

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

    function edit () {
        $(this).hide().siblings(".edit").show();
        return false;
    }

    function submit ( event ) {
        var $edit      = $( event.currentTarget ).closest(".edit");
        var $selectbox = $edit.closest(".selectbox");
        var $input     = $edit.find(".input");
        var newValue   = $input.val();

        if ( !newValue || newValue.length == 0 ) {
            $selectbox.trigger("EDIT_UPDATE", "");
            return;
        }

        // Reset Editor
        $input.val("");
        $edit.hide().siblings(".editbtn").show();

        event = $.Event("EDIT_UPDATE");
        $selectbox.trigger(event, newValue);
        if ( event.isDefaultPrevented() )
            return

        // Add Entry to Dropdown List
        $selectbox.find(".selection").html( newValue );
        var $lastSelection = $selectbox.find(".dropdown")
                                       .find(".selected").removeClass("selected");
        $lastSelection.parent().append('<li class="item selected" data-id="' + newValue + '">' + newValue + '</li>');

        $selectbox.trigger("EDIT_FINISHED")
                  .trigger("OPTION_CHANGE", newValue)
                  .removeClass("open");
    }

    $(function(){
        selectbox.init();
        $(document.body)
            .on('click',   ".selectbox .editor .editbtn", edit)
            .on('click',   ".selectbox .editor .btn",     submit)
            .on('click',   ".selectbox .editor",          function(e){ e.stopPropagation(); })
            .on('click',   ".selectbox .selection",       toggle)
            .on('click',   ".selectbox .dropdown .item",  select)
            .on('keydown', ".selectbox.open .dropdown",   keydown)

            /* Below are functions that's in bootstrap-dropdown */
            .on('click',   ".js-toggle-dropdown",        toggleDropdown)
    });



    /* Functions took from bootstrap-dropdown, it simple toggles "open" class */
    var dropDownBound = false;
    function toggleDropdown ( event ) {

        var $target = $( event.currentTarget );

        if ( $target.is('.disabled, :disabled') ) return;

        var $dropdown = $target.attr( "data-target" );
        if ( $dropdown ) {
            $dropdown = $( $dropdown );
        }
        if ( !$dropdown ) {
            $dropdown = $target.parent();
        }
        var opened    = $dropdown.hasClass("open");

        if ( opened ) {
            $dropdown.removeClass("open");
            $target.trigger("DROPDOWN_CLOSE");
        } else {

            if ( $target.attr("data-toggle") != "self-only") {
                // Bind click event to close popup
                // Close other dropdown and fires event
                if ( !dropDownBound ) {
                    closeDropdown();
                    dropDownBound = true;
                    $( document.body ).one("click", closeDropdown);
                } else {
                    closeDropdown();
                }
            }

            $dropdown.addClass("open");
            $target.trigger("DROPDOWN_OPEN");
        }

        return false;
    }

    function closeDropdown() {
        var $dropdownBtn = $(".js-toggle-dropdown");
        $dropdownBtn.each(function(){
            var $this = $(this);

            if ($this.attr("data-toggle") == "self-only")
                return;

            var $dropdown = $this.attr( "data-target" );
            if ( $dropdown ) {
                $dropdown = $( $dropdown );
            }
            if ( !$dropdown ) {
                $dropdown = $this.parent();
            }
            if ( $dropdown.hasClass("open") ) {
                $dropdown.removeClass("open");
                $this.trigger("DROPDOWN_CLOSE");
            }
        });
        dropDownBound = false;
    }

})();
