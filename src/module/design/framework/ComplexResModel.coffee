
define [ "./Design", "./ResourceModel" ], ( Design, ResourceModel )->

  ###
    -------------------------------
     ComplexResModel is the base class to implement a Resource that have relationship with other resources. Any visual resources should inherit from ComplexResModel
    -------------------------------

    ++ Object Method ++

    connect : ( ConnectionModel ) -> [FORCE]
        description : connect is called when a connection is created, subclass should override it to do its own logic.


    draw : ( isNewlyCreated : Boolean ) ->
        description : if the user defines this method, it will be called after object is created. And the framework might call this method at an approprieate time.

  ###

  ComplexResModel = ResourceModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 0
      height   : 0
      __parent : null

    ctype : "Framework_CR"

    initialize : ()->

      if @draw and Design.instance().shouldDraw()
        console.debug "ComplexResModel.initialize, trying to draw the item"
        @draw true
      null

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

