
define ["jquery"], ( $ )->

  cloneElement = ( data )->
    if data.noShadow
      return $()
    else
      $("<div id='DndItem'></div>")
        .appendTo( document.body )
        .html( data.source.html() )
        .attr("class", data.source.attr("class").replace("bubble", "").replace("tooltip", "") )

  emptyFunction = ()->

  defaultOptions = {
    clone        : cloneElement
    eventPrefix  : ""
    minDistance  : 4
    lockToCenter : true
    noShadow     : false
    # dropTargets  : $()
    # dataTransfer : {}

    onDragStart : emptyFunction
    onDrag      : emptyFunction
    onDragEnd   : emptyFunction
  }

  $.fn.dnd = ( mouseDownEvent, options )->

    console.assert( options.dropTargets )
    console.assert( options.dataTransfer )

    options = $.extend({
      source : this
      startX : mouseDownEvent.pageX
      startY : mouseDownEvent.pageY
    }, defaultOptions, options)

    $( document ).on({
      "mousemove.uidnd" : detectDrag
      "mousedown.uidnd" : cancelDnd  # Any other user mouse event will cause the drop to be canceld.
      "mouseup.uidnd"   : cancelDnd  # Any other user mouse event will cause the drop to be canceld.
      "urlroute.uidnd"  : cancelDnd
    }, options )
    return this

  cancelDnd = ( evt )->
    $( document ).off(".uidnd")

    data = evt.data

    ###
    # If we need to style the drag shadow, we can temporary comment out this line.
    ###
    if data.shadow then data.shadow.remove()

    if data.hoverZone
      data.hoverZone.removeClass("dragOver").triggerHandler "#{data.eventPrefix}dragleave", data
    return

  detectDrag = ( evt )->
    data = evt.data

    if Math.pow(evt.pageX - data.startX, 2) + Math.pow(evt.pageY - data.startY, 2) >= 4
      $( document )
        .off("mousemove.uidnd")
        .on({
          "mousemove.uidnd" : onMouseMove
          "mouseup.uidnd"   : onMouseUp
        }, data)
      startDrag( data, evt )

    false

  startDrag = ( data, evt )->
    data.onDragStart( data )
    data.shadow = shadow = data.clone( data )

    if data.lockToCenter
      data.offsetX = shadow.outerWidth()  / 2
      data.offsetY = shadow.outerHeight() / 2
    else
      offset = data.source.offset()
      data.offsetX = data.startX - offset.left
      data.offsetY = data.startY - offset.top

    shadow.css({
      left : evt.pageX - data.offsetX
      top  : evt.pageY - data.offsetY
    })

    data.dropZones = _.map data.dropTargets, ( tgt )->
      $tgt   = $(tgt)
      offset = $tgt.offset()
      {
        x1 : offset.left
        y1 : offset.top
        x2 : offset.left + $tgt.outerWidth()
        y2 : offset.top  + $tgt.outerHeight()
      }
    return

  onMouseMove = ( evt )->
    data = evt.data

    data.pageX = evt.pageX
    data.pageY = evt.pageY

    for dz, idx in data.dropZones
      if dz.x1 <= evt.pageX <= dz.x2 and dz.y1 <= evt.pageY <= dz.y2
        newZone = data.dropTargets.eq( idx )
        data.zoneDimension = dz
        break

    hoverZone = data.hoverZone
    if hoverZone and newZone and newZone[0] is hoverZone[0]
      newZone.triggerHandler "#{data.eventPrefix}dragover", data
    else
      if hoverZone
        hoverZone.removeClass("dragOver").triggerHandler "#{data.eventPrefix}dragleave", data
      if newZone
        newZone.addClass("dragOver").triggerHandler "#{data.eventPrefix}dragenter", data

      data.shadow.toggleClass("dragOver", !!newZone)
      data.hoverZone = newZone

    data.shadow.css({
      left : evt.pageX - data.offsetX
      top  : evt.pageY - data.offsetY
    })

    data.onDrag( evt )
    false

  onMouseUp = ( evt )->
    data = evt.data

    cancelDnd( evt )

    data.pageX = evt.pageX
    data.pageY = evt.pageY
    data.onDragEnd( evt )

    if data.hoverZone
      data.hoverZone.triggerHandler "#{data.eventPrefix}drop", data

    return

  null
