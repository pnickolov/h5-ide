/*
#**********************************************************
#* Filename : UI.multiinputbox
#* Creator  : Morris
#* Desc     : Multiple Input Box
#* Date     : 20130715
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

// 1. Component is identified by class ".multi-input"
// 2. Options are set via data-*, possible options are :
//    data-max-row : number

var multiinputbox;
(function(){
   multiinputbox = {
    init : function( baseParent ) {
      $( baseParent )
        .on("click", ".multi-input .icon-add", add)
        .on("click", ".multi-input .icon-del", del);
    },
    update : function( target ) {
      var $wrapper = $( target );
      var max = parseInt($wrapper.attr("data-max-row"));
      $wrapper.toggleClass("max", max && max <= $wrapper.children().length );
    }
  };

  function add () {
    var $wrapper = $(this).closest(".multi-input");
    var tmpl     = $wrapper.data("row-tmpl");

    // Get first row's html as template
    if ( !tmpl ) {
      var $clone = $("<p>").append($wrapper.children().eq(0).clone());
      $clone.find("input").removeAttr("value");
      tmpl = $clone.html();
      $wrapper.data("row-tmpl", tmpl);
    }

    $wrapper.append(tmpl).trigger("ADD_ROW");

    var max = parseInt($wrapper.attr("data-max-row"));
    if ( max && max <= $wrapper.children().length ) {
      $wrapper.addClass("max");
    }

    return false;
  }

  function del () {
    var $t       = $(this);
    var $wrapper = $t.closest(".multi-input").removeClass("max");

    var $target  = $t.closest(".multi-ipt-row");
    var value    = $target.find("input").val();
    var event    = $.Event( "BEFORE_REMOVE_ROW", { value : value } )

    $wrapper.trigger( event )
    if ( event.isDefaultPrevented() )
      return

    $target.remove();
    $wrapper.trigger("REMOVE_ROW", value );

    return false;
  }
})();

$(function(){ multiinputbox.init( document.body ); });
