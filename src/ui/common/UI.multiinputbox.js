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
    }
  };

  function add () {
    var $wrapper = $(this).closest(".multi-input").removeClass("single-row");
    var tmpl     = $wrapper.data("row-tmpl");

    // Get first row's html as template
    if ( !tmpl ) {
      tmpl = $("<p>").append($wrapper.children().eq(0).clone()).html();
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

    $t.parent().remove();
    $wrapper.trigger("REMOVE_ROW");

    if ( $wrapper.children().length == 1 ) {
      $wrapper.addClass("single-row");
    }
    return false;
  }
})();

$(function(){ multiinputbox.init( document.body ); });
