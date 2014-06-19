
define [ "i18n!nls/lang.js", "./CanvasElement", "constant", "CanvasManager", "event" ], ( lang, CanvasElement, constant, CanvasManager, ide_event )->

  CeVolume = ( component )->
    if _.isString( component )
      @id = component
      @nodeType = "node"
      @type = constant.RESTYPE.VOL
    else
      CanvasElement.apply( this, arguments )
    null


  CanvasElement.extend( CeVolume, constant.RESTYPE.VOL )
  ChildElementProto = CeVolume.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.remove = ()->
    # # #
    # Quick Hack for supporting AppEdit
    # Ask the component if it supports AppEdit Mode
    #
    if @model.design().modeIsAppEdit()
      if (@model.get("owner") || {}).type is constant.RESTYPE.LC
        notification "error", lang.ide.NOTIFY_MSG_WARN_OPERATE_NOT_SUPPORT_YET
        return false
    #
    # #
    # # #
    CeVolume.super.remove.call this


  ChildElementProto.select = ( subId )->
    ide_event.trigger ide_event.OPEN_PROPERTY, @type, subId or @id
    MC.canvas.volume.select( @id )
    true

  null
