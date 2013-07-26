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
    var id = clip.htmlBridge.title;
    element.trigger( 'COPY_TO_CLIP_COMPLETE', [ id, args.text.length ] );
   }

  function mousedown( client ) {
    clip.setText( JSON.stringify(MC.canvas_data ) );
  }

})();