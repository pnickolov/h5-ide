/*
#**********************************************************
#* Filename : UI.zeroclipboard
#* Creator  : Kenshin
#* Desc     : Clip with ZeroClipBoard
#* Date     : 20130720
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

var zeroclipboard, clip, element;

(function() {
  "use strict";
   zeroclipboard = {
    init : function( el, ZeroClipboard ) {
      //
      element = $( '#'+ el );
      //
      clip = new ZeroClipboard( element , { moviePath: "vender/zeroclipboard/ZeroClipboard.swf" });
      //
      clip.on( 'complete', complete );
      clip.on( 'mousedown',  mousedown );
    }
  };

  function complete( client, args ) {
    if( notification )
      notification("info", clip.htmlBridge.title + " is copied to clipboard");
   }

  function mousedown( client ) {
    if ( clip.htmlBridge.title == "jsondata" ) {
      clip.setText( JSON.stringify(MC.canvas_data ) );
    }
  }

})();
