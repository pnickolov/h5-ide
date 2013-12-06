
define [ "./Design", "./CanvasManager", "./ResourceModel" ], ( Design, CanvasManager, ResourceModel )->

  ###
    -------------------------------
     ComplexResModel is the base class to implement a Resource that have relationship with other resources. Any visual resources should inherit from ComplexResModel
    -------------------------------

    ++ Object Method ++

    connect : ( ConnectionModel ) -> [FORCE]
        description : connect is called when a connection is created, subclass should override it to do its own logic.


    draw : ( isNewlyCreated : Boolean ) ->
        description : if the user defines this method, it will be called after object is created. And the framework might call this method at an approprieate time.
        If the method is defined, it means it's a visual resource

    isRemovable   : ()->
        description : When user press delete key in canvas, canvas will ask if the object can be removed. If isRemovable returns a string, it will treat it as a warning, if the string starts with '!', it is a infomation for not allowing the user to delete

    isConnectable : ( targetComp, selfPort, targetPort )->
        description : When user wants to connect a target. This method will be called

  ###

  ComplexResModel = ResourceModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 0
      height   : 0
      __parent : null

    type : "Framework_CR"

    initialize : ()->

      if @draw and Design.instance().shouldDraw()
        @draw true
      null

    isRemovable   : ()-> true
    isConnectable : ( targetComp, selfPort, targetPort )-> false

    remove : ()->
      console.debug "ComplexResModel.remove, Removing Connections"

      # Remove connection
      connections = this.attributes.__connections
      this.attributes.__connections = []
      for c in connections
        c.remove()
      null

    connect : ( connection )->
      console.debug "ComplexResModel.connet"

      connections = @get "__connections"

      if not connections
        connections = []

      connections.push connection
      @set "__connections", connections
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
          Canvon.rectangle(10, 6, 7 , 5).attr({
            'id'    : @id + '_sg-color-label1'
            'class' : 'node-sg-color-border tooltip'
          }),
          Canvon.rectangle(20, 6, 7 , 5).attr({
            'id'    : @id + '_sg-color-label2'
            'class' : 'node-sg-color-border tooltip'
          }),
          Canvon.rectangle(30, 6, 7 , 5).attr({
            'id'    : @id + '_sg-color-label3'
            'class' : 'node-sg-color-border tooltip'
          }),
          Canvon.rectangle(40, 6, 7 , 5).attr({
            'id'    : @id + '_sg-color-label4'
            'class' : 'node-sg-color-border tooltip'
          }),
          Canvon.rectangle(50, 6, 7 , 5).attr({
            'id'    : @id + '_sg-color-label5'
            'class' : 'node-sg-color-border tooltip'
          })
        ).attr({
          'id'        : @id + '_node-sg-color-group'
          'class'     : 'node-sg-color-group'
          'transform' : 'translate(8, 62)'
        })

        node.append( sggroup )
        CanvasManager.updateSGLabel( @id, sggroup )

      node

    ###
     ReadOnly Infomation
    ###
    connections : ()-> this.get("__connections") || []
    parent      : ()-> this.get("__parent")
    x           : ()-> this.get("x")
    y           : ()-> this.get("y")
    width       : ()-> this.get("width")
    height      : ()-> this.get("height")

  }

  ComplexResModel

