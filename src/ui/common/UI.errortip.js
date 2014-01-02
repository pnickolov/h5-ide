/*
#**********************************************************
#* Filename: UI.errortip
#* Creator: Tim
#* Description: UI.errortip
#* Date: 20130817
# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
*/
var errortip = function (event)
{
  var target = $(this),
    content = errortip.findError( target )
    , target_offset
    , width
    , height
    , target_width
    , target_height
    , tipId

  if (content.length)
  {
    id = content.attr('id');
    tipId = 'errortip-' + id;
    originTip = $('#' + tipId);

    if ( originTip.length ) {
      // if error message is changed, update the errortip and display it.
      if ( originTip.html() != content.html() ) {
        originTip.html( content.html() )
        originTip.show();
      }
      return;
    }

    errortip_box = content.clone();
    errortip_box
      .addClass('errortip_box')
      .attr('id', tipId)
      .css('z-index', content.css('z-index'))
      .appendTo(document.body);

    target_offset = target.offset();
    target_width = target.innerWidth();
    target_height = target.innerHeight();

    //width = errortip_box.width();
    //height = errortip_box.height();


    errortip_box.css({
      'left': target_offset.left,
      'top': target_offset.top + target_height + height - document.body.scrollTop + 45 > window.innerHeight ?
        target_offset.top - height - 15 + 5 :
        target_offset.top + target_height + 5,
      width: target_width - 8 - 2,

    }).show();

    errortip.timer[ id ] = setInterval(function ()
      {
        if (content.closest('html').length === 0)
        {
          errortip.clear( content.attr('id') );
        }
      }, 200);

  }
};

errortip.timer = {};
errortip.firstTimer = {};
errortip.isEnter = false;

errortip.findError = function( $target ) {
  return $target.next('.parsley-error-list');
}

errortip.getEid = function ( target ) {
  $target = target instanceof $ ? target : $( target );
  return errortip.findError( $target ).attr( 'id' )
}

errortip.getUid = function ( event ) {
  var id;
  if ( event === Object( event ) ) {
    id = errortip.getEid( event.currentTarget );
  } else {
    id = event
  }
  return $( '#' + id ).data( 'uid' );
}

errortip.first = function( target ) {
  errortip.call(target)
  id = errortip.getEid( target )
  errortip.firstTimer[ id ] = setTimeout(function() {
    errortip.clear({currentTarget: target});
  }, 2000);
}

errortip.clear = function ( event )
{
  var id, uid, force = false;
  if ( event ){
    var errorPrefix = 'errortip-';
    if ( event === Object( event ) ) {
      id = errortip.findError( $( event.currentTarget ) ).attr( 'id' );
    }
    else {
      force = true;
      id = event;
    }

    uid = errortip.getUid( id );
    setTimeout( function() {
      if ( errortip.enterUid !== uid  || force ) {
        $( '#' + errorPrefix + id ).remove();
      }
    }, 100);

  } else {
    $('.errortip_box').remove();
  }

  errortip.firstTimer[ id ] && clearInterval( errortip.firstTimer[ id ] )
  errortip.removeInterval( id )

};

errortip.removeInterval = function ( id ) {
  if ( id ) {
    clearInterval( errortip.timer[ id ] );
  } else {
    for ( var id in errortip.timer ) {
      clearInterval( errortip.timer[ id ] );
    }
  }
}

errortip.enter = function ( event ) {
  errortip.enterUid = errortip.getUid( event );
  errortip.call( this, event );
}

errortip.leave = function ( event ) {
  errortip.enterUid = false;
  errortip.clear.call( this, event );
}

$(document).ready(function ()
{
  $(document.body).on('mouseenter', '.parsley-error', errortip.enter);
  $(document.body).on('mouseleave', '.parsley-error', errortip.leave);
});

