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
    content = findError( target )
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

    timer[ id ] = setInterval(function ()
      {
        if (content.closest('html').length === 0)
        {
          purge( content.attr('id') );
        }
      }, 200);

  }
};

var timer = {};
var firstTimer = {};
var isEnter = false;
var enterUid;

// Internal Helper

var findError = function( $target ) {
  return $target.next('.parsley-error-list');
}

var getEid = function ( target ) {
  $target = target instanceof $ ? target : $( target );
  return findError( $target ).attr( 'id' )
}

var getUid = function ( event ) {
  var id;
  if ( event === Object( event ) ) {
    id = getEid( event.currentTarget );
  } else {
    id = event
  }
  return $( '#' + id ).data( 'uid' );
}

var removeInterval = function ( id ) {
  if ( id ) {
    clearInterval( timer[ id ] );
  } else {
    for ( var id in timer ) {
      clearInterval( timer[ id ] );
    }
  }
}

var enter = function ( event ) {
  enterUid = getUid( event );
  errortip.call( this, event );
}

var leave = function ( event ) {
  enterUid = false;
  purge.call( this, event );
}

// Public Methods

var first = function( target ) {
  errortip.call(target)
  id = getEid( target )
  firstTimer[ id ] = setTimeout(function() {
    purge({currentTarget: target});
  }, 2000);
}

var purge = function ( event )
{
  var id, uid, force = false;
  if ( event ){
    var errorPrefix = 'errortip-';
    if ( event === Object( event ) ) {
      id = findError( $( event.currentTarget ) ).attr( 'id' );
    }
    else {
      force = true;
      id = event;
    }

    uid = getUid( id );
    setTimeout( function() {
      if ( enterUid !== uid  || force ) {
        $( '#' + errorPrefix + id ).remove();
      }
    }, 100);

  } else {
    $('.errortip_box').remove();
  }

  firstTimer[ id ] && clearInterval( firstTimer[ id ] )
  removeInterval( id )

};

errortip.first = first;
errortip.purge = purge;

// Bind Global Events[ mouseenter, mouseleave ]
$(document).ready(function ()
{
  $(document.body).on('mouseenter', '.parsley-error', enter);
  $(document.body).on('mouseleave', '.parsley-error', leave);
});

