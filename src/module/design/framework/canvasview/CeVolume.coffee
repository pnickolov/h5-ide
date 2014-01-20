
define [ "./CanvasElement", "constant", "CanvasManager", "event" ], ( CanvasElement, constant, CanvasManager, ide_event )->

  ChildElement = ( component )->
    if _.isString( component )
      @id = component
      @nodeType = "node"
      @model = {
        type : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
        id   : component
      }
    else
      CanvasElement.apply( this, arguments )
    null


  CanvasElement.extend( ChildElement, constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume )
  ChildElementProto = ChildElement.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.remove = ()->
    # # #
    # Quick Hack for supporting AppEdit
    # Ask the component if it supports AppEdit Mode
    #
    if Design.instance().modeIsAppEdit()
      if @model.get("owner") and @model.get("owner").type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        notification "error", "This operation is not supported yet."
        return false
    #
    # #
    # # #
    ChildElement.super.remove.call this


  ChildElementProto.select = ( subId )->
    ide_event.trigger ide_event.OPEN_PROPERTY, @model.type, subId or @model.id
    MC.canvas.volume.select( @model.id )
    true

  null
