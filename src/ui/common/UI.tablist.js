/*
#**********************************************************
#* Filename: UI.tablist
#* Creator: Cinde
#* Description: UI.tablist
#* Date: 20130620
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
/* A modified version to reduce redundant html code by Morris */
var tab = {
    update : function ( event ) {
        var $target = $( event.currentTarget );
        if ( $target.hasClass("active") )
            return false;

        var $previous_selected = 
                $target.addClass("active")
                       .siblings(".active").removeClass("active");

        $($previous_selected.attr("data-tab-target")).removeClass("active");
        $($target.attr("data-tab-target")).addClass("active");

        return false;
    }
};
$(function(){
    $(document.body).on('click', '.tab [data-tab-target]', tab.update );
});
