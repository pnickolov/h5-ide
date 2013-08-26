/*
#**********************************************************
#* Filename : UI.zeroclipboard
#* Creator  : Kenshin
#* Desc     : Clip with ZeroClipBoard
#* Date     : 20130824
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/

(function() {
  'use strict';

  define( [ 'zeroclipboard', 'UI.notification' ],  function ( ZeroClipboard ) {

    var zeroclipboard, clip;

    zeroclipboard = {

      init : function () {
        clip = new ZeroClipboard( $( '<div></div>' ) , { moviePath: 'vender/zeroclipboard/ZeroClipboard.swf' });
        //
        clip.setHandCursor( true );
        //
        clip.on( 'complete',   complete  );
        clip.on( 'mousedown',  mousedown );
      },

      copy : function( element ) {
        //
        if ( clip == undefined ) zeroclipboard.init();
        //
        clip.glue( element );
      }

    };

    function complete( client, args ) {
      notification( 'info', clip.htmlBridge.title + ' is copied to clipboard' );
    }

    function mousedown( client ) {
      if ( clip.htmlBridge.title == 'jsondata' ) {
        clip.setText( JSON.stringify( MC.canvas_data ));
      }
    }

    return zeroclipboard;

  });

})();
