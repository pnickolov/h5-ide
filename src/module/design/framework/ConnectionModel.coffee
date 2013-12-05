
define [ "./ResourceModel", "./Design" ], ( ResourceModel, Design )->

  ###
    -------------------------------
     ConnectionModel is the base class to implment a connection between two resources
    -------------------------------

    ++ Object Method ++

    port1()
    port2()
      description : returns the name of the port, port1() is always smaller than port2()

    port1Comp()
    port2Comp()
      description : returns the component of each port

    getTarget : ( type )
      description : returns a component of a specific type

    remove()
      description : remove the connection from two resources.
  ###

  ConnectionModel = ResourceModel.extend {

    isConnection : ()->
      true

    type : "Framework_CN"

    constructor : ( p1Comp, p2Comp ) ->

      for def in @portDefs
        if def.port1.type is p1Comp.type and def.port2.type is p2Comp.type
          @__port1     = def.port1.name
          @__port1Comp = p1Comp
          @__port2     = def.port2.name
          @__port2Comp = p2Comp
          break
        else if def.port1.type is p2Comp.type and def.port2.type is p1Comp.type
          @__port1     = def.port1.name
          @__port1Comp = p2Comp
          @__port2     = def.port2.name
          @__port2Comp = p1Comp
          break


      console.assert( @__port1, "Cannot create connection!" )


      # Call super (Backbone.Model) constructor
      ResourceModel.constructor.call(this)

      @__port1Comp.connect this
      @__port2Comp.connect this

    port1     : ()-> @__port1
    port2     : ()-> @__port2
    port1Comp : ()-> @__port1Comp
    port2Comp : ()-> @__port2Comp

    getTarget : ( type )->
      if @__port1Comp.type is type
        return @__port1Comp

      if @__port2Comp.type is type
        return @__port2Comp

      null

    remove : ()->

      # Directly remove the connection without triggering anything.
      c = @__port1Comp.attributes.__connections
      ci = c.indexOf this
      if ci != -1
        c.splice( ci, 1 )

      c = @__port2Comp.attributes.__connections
      ci = c.indexOf this
      if ci != -1
        c.splice( ci, 1 )

      null
  }, {
    extend : ( protoProps, staticProps )->

      if protoProps.portDefs and not _.isArray( protoProps.portDefs )
        protoProps.portDefs = [ protoProps.portDefs ]

      tags = []

      # Ensure port1 is always smaller than port2
      for def in protoProps.portDefs
        if def.port1.name > def.port2.name
          tmp = def.port1
          def.port1 = def.port2
          def.port2 = tmp

        tags.push def.port1.name + ">" + def.port2.name

      if not protoProps.type
        protoProps.type = tags[0]

      child = ResourceModel.extend.call( this, protoProps, staticProps )

      for t in tags
        Design.registerModelClass t, child

      child
  }

  ConnectionModel

