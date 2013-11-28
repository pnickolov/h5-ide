
define [ "./ResourceModel" ], ( ResourceModel )->

  ###
    -------------------------------
     ConnectionModel is the base class to implment a connection between two resources
    -------------------------------

    ++ Object Method ++

    port1()
    port2()
      description : returns the name of the port, port1() is always than port2()

    port1Comp()
    port2Comp()
      description : returns the component of each port

    getTarget : ( ctype )
      description : returns a component of a specific type

    remove()
      description : remove the connection from two resources.
  ###

  ConnectionModel = ResourceModel.extend {

    ctype : "Framework_CN"

    constructor : ( p1Comp, p1Name, p2Comp, p2Name ) ->

      # Compare port, and switch them if necessary.
      # So that port1 < port2
      if p1Name <= p2Name
        attr =
          __port1     : p1Name
          __port1Comp : p1Comp

          __port2     : p2Name
          __port2Comp : p2Comp
      else
        attr =
          __port1     : p2Name
          __port1Comp : p2Comp

          __port2     : p1Name
          __port2Comp : p1Comp

      # Call super (Backbone.Model) constructor
      this.constructor.__super__.constructor.call(this, attr)

    port1     : ()-> this.get("__port1")
    port2     : ()-> this.get("__port2")
    port1Comp : ()-> this.get("__port1Comp")
    port2Comp : ()-> this.get("__port2Comp")

    getTarget : ( ctype )->
      if this.attributes.__port1Comp.ctype is ctype
        return this.attributes.__port1Comp

      if this.attributes.__port2Comp.ctype is ctype
        return this.attributes.__port2Comp

      null

    remove : ()->

      # Directly remove the connection without triggering anything.
      c = @port1Comp().attributes.__connections
      ci = c.indexOf this
      if ci != -1
        c.splice( ci, 1 )

      c = @port2Comp().attributes.__connections
      ci = c.indexOf this
      if ci != -1
        c.splice( ci, 1 )

      null
  }

