
define [ "Design", "CanvasManager", "./ResourceModel" ], ( Design, CanvasManager, ResourceModel )->

  emptyArr = []

  ###
    -------------------------------
     ComplexResModel is the base class to implement a Resource that have relationship with other resources. Any visual resources should inherit from ComplexResModel
    -------------------------------

    ++ Object Method ++

    connect : ( ConnectionModel ) -> [FORCE]
        description : connect is called when a connection is created, subclass should override it to do its own logic.

    disconnect : ( ConnectionModel )-> [FORCE]
        description : disconnect is called when a connection is removed, subclass should override it to do its own logic.


    draw : ( isNewlyCreated : Boolean ) ->
        description : if the user defines this method, it will be called after object is created. And the framework might call this method at an approprieate time.
        If the method is defined, it means it's a visual resource

    isRemovable   : ()->
        description : When user press delete key in canvas, canvas will ask if the object can be removed. If isRemovable returns a string, it will treat it as a warning, if the string starts with '!', it is a infomation for not allowing the user to delete

    isConnectable : ( targetComp, selfPort, targetPort )->
        description : When user wants to connect a target. This method will be called

    connections : ( typeString )->
        description : returns an array of connections. Can be filter by typeString

    connectionTargets : ( typeString )->
        description : The same as connections, except the array holds targets connceted to this.

  ###

  ComplexResModel = ResourceModel.extend {

    ###
    defaults :
      x        : 0
      y        : 0
      width    : 0
      height   : 0
      __parent : null
    ###

    type : "Framework_CR"

    constructor : ( attributes, options )->

      if attributes and attributes.parent
        p = attributes.parent
        delete attributes.parent

      ResourceModel.call this, attributes, options

      if p
        p.addChild( this )
      null

    initialize : ()->

      if @draw and Design.instance().shouldDraw()
        @draw true
      null

    isConnectable : ( targetComp, selfPort, targetPort )-> false

    setName : ( name )->
      if @get("name") is name
        return

      @set "name", name

      if @draw then @draw()
      null

    remove : ()->
      # Remove connection
      connections = this.attributes.__connections
      if connections
        console.debug "ComplexResModel.remove, Removing Connections"
        for c in connections
          c.remove( { reason : this } )

      # Remove element in SVG
      if @draw
        CanvasManager.remove( document.getElementById( @id ) )
      null

    connect_base : ( connection )->
      connections = @get "__connections"

      if not connections
        connections = []

      if connections.indexOf( connection ) == -1
        connections.push connection
        @set "__connections", connections

      if @connect
        @connect( connection )
      null

    disconnect_base : ( connection )->
      connections = @get "__connections"
      # Directly remove the connection without triggering anything changed.
      # But I'm not sure if this will affect undo/redo

      console.assert( connections, "Disconnecting a resource, when the resource doesn't connect to anything." )

      if connections.indexOf(connection) is -1 then return

      connections.splice( connections.indexOf( connection ), 1 )

      if @disconnect
        @disconnect( connection )
      null


    createNode : ( option )->
      # A helper function to create a SVG Element to represent a group
      x      = @x()
      y      = @y()
      width  = @width()  * MC.canvas.GRID_WIDTH
      height = @height() * MC.canvas.GRID_HEIGHT

      node = Canvon.group().append(

        Canvon.rectangle(0, 0, width, height).attr({
          'class' : 'node-background'
          'rx'    : 5
          'ry'    : 5
        }),

        Canvon.image( MC.IMG_URL + option.image, option.imageX, option.imageY, option.imageW, option.imageH )

      ).attr({
        'id'         : @id
        'class'      : 'dragable node ' + @type.replace(/\./g, "-")
        'data-type'  : 'node'
        'data-class' : @type
      })

      if option.labelBg
        node.append(
          Canvon.rectangle(2, 76, 86, 13).attr({
            'class' : 'node-label-name-bg'
            'rx'    : 3
            'ry'    : 3
          })
        )

      if option.label
        node.append(
          Canvon.text( width / 2, height - 4, MC.canvasName( option.label ) ).attr({
            'class' : 'node-label' + if option.labelBg then ' node-label-name' else ''
          })
        )

      if option.sg
        sggroup = Canvon.group().append(
          Canvon.rectangle(10, 6, 7 , 5).attr({'class' : 'node-sg-color-border tooltip'}),
          Canvon.rectangle(20, 6, 7 , 5).attr({'class' : 'node-sg-color-border tooltip'}),
          Canvon.rectangle(30, 6, 7 , 5).attr({'class' : 'node-sg-color-border tooltip'}),
          Canvon.rectangle(40, 6, 7 , 5).attr({'class' : 'node-sg-color-border tooltip'}),
          Canvon.rectangle(50, 6, 7 , 5).attr({'class' : 'node-sg-color-border tooltip'})
        ).attr({
          'class'     : 'node-sg-color-group'
          'transform' : 'translate(8, 62)'
        })

        node.append( sggroup )

      node

    ###
     ReadOnly Infomation
    ###
    connections : ( type )->
      cnns = this.get("__connections")

      if cnns and _.isString type
        cnns = _.filter cnns, ( cn )-> cn.type is type

      cnns || emptyArr

    connectionTargets : ( connectionType )->
      targets = []
      cnns    = this.get("__connections")

      if cnns
        for cnn in cnns
          if not connectionType or cnn.type is connectionType
            targets.push( cnn.getOtherTarget( @ ) )

      targets

    parent : ()-> @attributes.__parent || null
    x      : ()-> @attributes.x || 0
    y      : ()-> @attributes.y || 0
    width  : ()-> @attributes.width || 0
    height : ()-> @attributes.height || 0

  }, {
    extend : ( protoProps, staticProps )->

      # Force to check if the design should be draw before drawing is done.
      if protoProps.draw
        protoProps.draw = (()->
          draw = protoProps.draw
          ()->
            if Design.instance().shouldDraw()
              draw.apply @, arguments
        )()

      ResourceModel.extend.call this, protoProps, staticProps
  }

  ComplexResModel

