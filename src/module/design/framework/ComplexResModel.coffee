
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
      __x      : 0
      __y      : 0
      __w      : 0
      __h      : 0
      __parent : null

    ctype : "Framework_CR"

    initialize : ()->
      console.debug "ComplexResModel.initialize, trying to draw the item"

      if @draw
        @draw true
      null

    remove : ()->
      console.debug "ComplexResModel.remove, Removing Connections"

      # Remove connection
      for connection in this.attributes.__connections
        connection.disconnect()
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
    x           : ()-> this.get("__x")
    y           : ()-> this.get("__y")
    width       : ()-> this.get("__w")
    height      : ()-> this.get("__h")

  }

  ComplexResModel

