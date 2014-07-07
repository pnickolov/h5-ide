
define [ "./ResourceModel", "Design" ], ( ResourceModel, Design )->

  ###
    -------------------------------
     ConnectionModel is the base class to implment a connection between two resources
    -------------------------------

    ++ Object Method ++

    setDestroyAfterInit()
      description : calling this method will cause the line to be removed after initialize()

    port1()
    port2()
      description : returns the name of the port, port1() is always smaller than port2()

    port1Comp()
    port2Comp()
      description : returns the component of each port

    getTarget : ( type )
      description : returns a component of a specific type

    getOtherTarget : ( theType )
      description : returns a component that its type is not of theType

    connectsTo : ( id )
      description : returns true if this connection connects to resource of id

    remove( option )
      description : remove the connection from two resources. Optional parameter `option` will be passed.
      `option.reason` will provided when the connection is removed due to one of its target is being removed.



    ++ Class Attributes ++

    type :
      description : A string to identify the Class

    portDefs :
      description : Ports defination for a visual line

    oneToMany :
      description : A type string.
      When C ( connection ) between A ( TYPEA ) and B ( TYPEB ) is created. If oneToMany is TYPEA, then previous B <=> TYPEA connection will be removed.



    ++ Class Method ++

    isConnectable( comp1, comp2 )
      description : This method is used to determine if user can create a line between two resources.
  ###
  ConnectionModel = ResourceModel.extend {

    node_line : true
    type      : "Framework_CN"

    constructor : ( p1Comp, p2Comp, attr, option ) ->

      ### env:dev ###
      console.assert( p1Comp and p2Comp and p1Comp.isTypeof( "Framework_R") and p2Comp.isTypeof( "Framework_R" ), "Invalid components when creating an connection : ", [ p1Comp, p2Comp ] )
      ### env:dev:end ###

      if not p1Comp or not p2Comp
        console.warn( "Connection of #{@type} is not created, because invalid targets :", [ p1Comp, p2Comp ] )
        return

      ###
      # We must allow self-reference connection to be created.
      # Because SgModel would need that.
      ###

      if not option or option.detectDuplicate isnt false
        # Detect if we have already created the same connection between p1Comp, p2Comp
        cns = Design.modelClassForType( @type ).allObjects()
        cn = Design.modelClassForType( @type ).findExisting( p1Comp, p2Comp )
        if cn
          console.info "Found existing connection #{@type} of ", [p1Comp, p2Comp]

          # If the user creates a connection with some additonal parameters,
          # then we would like to assign these parameters to the found connection.
          if attr then cn.set attr
          return cn

      # Assign components to the connection.
      if not @assignCompsToPorts( p1Comp, p2Comp )
        console.error "Trying to connect components while the connection does not support them : ", [ p1Comp, p2Comp ]
        return


      # Call super constructor
      ResourceModel.call(this, attr, option)


      # The line wants to destroy itslef after init
      if @__destroyAfterInit
        @remove( this )
        this.id = ""
        return this


      @__port1Comp.connect_base this
      if @__port1Comp isnt @__port2Comp
        @__port2Comp.connect_base this


      # If oneToMany is defined. Then one of the component of this connection should be
      # checked.
      if @oneToMany
        console.assert( @oneToMany is @port1Comp().type or @oneToMany is @port2Comp().type, "Invalid oneToMany parameter" )
        comp = @getOtherTarget( @oneToMany )
        for cn in comp.connections( @type )
          if cn isnt this
            cn.remove( this )

      this

    setDestroyAfterInit : ()->
      @__destroyAfterInit = true
      null

    assignCompsToPorts : ( p1Comp, p2Comp )->
      if @portDefs

        for def in @portDefs
          if def.port1.type is p1Comp.type and def.port2.type is p2Comp.type
            @__portDef   = def
            @__port1Comp = p1Comp
            @__port2Comp = p2Comp
            break
          else if def.port1.type is p2Comp.type and def.port2.type is p1Comp.type
            @__portDef   = def
            @__port1Comp = p2Comp
            @__port2Comp = p1Comp
            break

        return !!@__portDef

      else
        # If there's no portDefs, we directly assign the parameter to this
        @__port1Comp = p1Comp
        @__port2Comp = p2Comp

      return true

    port : ( id, attr )->
      if not @__portDef then return ""

      if @__port1Comp is id or @__port1Comp.id is id
        return @__portDef.port1[ attr ]

      if @__port2Comp is id or @__port2Comp.id is id
        return @__portDef.port2[ attr ]

      return ""

    port1 : ( attr )->
      if @__portDef then @__portDef.port1[ attr ] else ""
    port2 : ( attr )->
      if @__portDef then @__portDef.port2[ attr ] else ""

    connectsTo : ( id )->
      ( @__port1Comp && @__port1Comp.id is id ) or ( @__port2Comp && @__port2Comp.id is id )

    port1Comp : ()-> @__port1Comp
    port2Comp : ()-> @__port2Comp

    getOtherTarget : ( type )->
      if not _.isString type
        if @__port1Comp is type
          return @__port2Comp
        else
          return @__port1Comp

      else
        if @__port1Comp.type is type
          return @__port2Comp
        else
          return @__port1Comp

    getTarget : ( type )->
      if @__port1Comp.type is type
        return @__port1Comp

      if @__port2Comp.type is type
        return @__port2Comp

      null

    remove : ( option )->

      console.assert (not (@__port1Comp.isRemoved() and @__port2Comp.isRemoved())), "Both ports are already removed when connection is removing", this

      # When an connection is removed because of a resource's removal, that resource.isRemoved() will be true. In that case, that resource.disconnect will not be called.
      p1Exist = not @__port1Comp.isRemoved()
      p2Exist = not @__port2Comp.isRemoved()

      # Update both resource's connection array first.
      if p1Exist then @__port1Comp.attach_connection( @, true )
      if p2Exist then @__port2Comp.attach_connection( @, true )

      if p1Exist then @__port1Comp.disconnect_base( @, option )
      if p2Exist then @__port2Comp.disconnect_base( @, option )


      # Try removing line element in SVG, if the line is visual
      v = @__view
      if v then v.detach()

      ResourceModel.prototype.remove.call this
      null

    serialize : ()->
      # Most of the connection don't have to implement serialize()
      null

    isVisual : ()-> !!@portDefs

    draw : ()-> console.warn "ConnectionModel.draw() is deprecated", @

  }, {

    findExisting : ( p1Comp, p2Comp )->
      for cn in @allObjects()
        if cn.port1Comp() is p1Comp and cn.port2Comp() is p2Comp and not cn.isRemoved()
          return cn
        if cn.port2Comp() is p1Comp and cn.port1Comp() is p2Comp and not cn.isRemoved()
          return cn
      null

    extend : ( protoProps, staticProps )->

      tags = []

      if protoProps.portDefs
        if not _.isArray( protoProps.portDefs )
          protoProps.portDefs = [ protoProps.portDefs ]

        # Ensure port1 is always smaller than port2
        for def in protoProps.portDefs
          if def.port1.name > def.port2.name
            tmp = def.port1
            def.port1 = def.port2
            def.port2 = tmp

          tags.push def.port1.name + ">" + def.port2.name

        if not protoProps.type then protoProps.type = tags[0]

      child = ResourceModel.extend.call( this, protoProps, staticProps )

      for t in tags
        Design.registerModelClass t, child

      Design.registerModelClass protoProps.type, child

      child.__isLineClass = true

      child

    isConnectable : ( comp1, comp2 )-> true

    connectionData : ( type, portName )->
      allLinePortMap = {}

      for LineModel in Design.lineModelClasses()
        if not LineModel.prototype.portDefs then continue

        for def in LineModel.prototype.portDefs
          if def.port1.type is type
            p = def.port1; op = def.port2
          else if def.port2.type is type
            p = def.port2; op = def.port1
          else
            continue

          if not portName or portName is p.name
            arr = allLinePortMap[ op.type ] || (allLinePortMap[ op.type ] = [])
            arr.push op.name

      allLinePortMap
  }

  ConnectionModel

