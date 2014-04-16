
define [ "Design", "CanvasManager", "./ResourceModel", "constant", "./canvasview/CanvasElement" ], ( Design, CanvasManager, ResourceModel, constant, CanvasElement )->

  emptyArr = []

  ###
    -------------------------------
     ComplexResModel is the base class to implement a Resource that have relationship with other resources. Any visual resources should inherit from ComplexResModel
    -------------------------------

    ++ Object Method ++

    connect : ( ConnectionModel ) -> [FORCE]
        description : connect is called when a connection is created, subclass should override it to do its own logic.

    disconnect : ( ConnectionModel, reason )->
        description : disconnect is called when a connection is removed, subclass should override it to do its own logic. `reason` if not null, it will point to an model, which is the cause to remove the connection.


    draw : ( isNewlyCreated : Boolean ) ->
        description : if the user defines this method, it will be called after object is created. And the framework might call this method at an approprieate time.
        If the method is defined, it means it's a visual resource

    isRemovable   : ()->
        description : When user press delete key in canvas, canvas will ask if the object can be removed. If isRemovable returns a string, it will treat it as a warning, if the string starts with '!', it is a infomation for not allowing the user to delete

    connections : ( typeString )->
        description : returns an array of connections. Can be filter by typeString

    connectionTargets : ( typeString )->
        description : The same as connections, except the array holds targets connceted to this.

    onParentChanged : ()->
        description : If this method is defined, it will be called after the Model's parent is changed.

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

      # Need to assign parent to attribute first,
      # Because initialize() might need it.
      if attributes and attributes.parent
        attributes.__parent = attributes.parent
        delete attributes.parent

      ResourceModel.call this, attributes, options

      if attributes and attributes.__parent
        # Reset __parent here, so that addChild() can succeed
        @attributes.__parent = null
        attributes.__parent.addChild( this )
      null

    initialize : ()->

      if @draw and Design.instance().shouldDraw()
        @draw true
      null

    setName : ( name )->
      if @get("name") is name
        return

      @set "name", name

      if @draw then @draw()
      null

    remove : ()->
      # Mark as removed first, so that connection knows why they're being removed.
      @markAsRemoved()

      cns = @attributes.__connections

      if cns
        # The connections is not modified during the removal of the resource.
        l = cns.length
        while l
          # Removing connection of this Resource might cause other connections of this
          # resource get removed. So, we always check if the connection is not empty.
          # In some case, removing a connection will result in adding new connection to
          # this resource, meaning the connections.length will increase.
          --l
          cns[l].remove()

      # Remove element in SVG
      v = @getCanvasView()
      if v then v.detach()

      @markAsRemoved( false )
      ResourceModel.prototype.remove.call this
      null

    attach_connection : ( cn, detach )->
      # Use this method to modify connection array
      # This method might be used by ConnectionModel before connect_base/disconnect_base
      # is called
      connections = @get("__connections") or []
      idx = connections.indexOf( cn )
      if detach
        if idx isnt -1
          connections.splice idx, 1
      else
        if idx is -1
          connections.push cn
          @set "__connections", connections

      null

    connect_base : ( connection )->
      ###
      connect_base.call(this) # This is used to suppress the warning in ResourceModel.extend.
      ###
      @attach_connection( connection )
      if @connect then @connect( connection )
      null

    disconnect_base : ( connection, reason )->
      ###
      disconnect_base.call(this) # This is used to suppress the warning in ResourceModel.extend.
      ###

      # Directly remove the connection without triggering anything changed.
      # But I'm not sure if this will affect undo/redo
      @attach_connection( connection, true )
      if @disconnect then @disconnect( connection, reason )
      null

    isVisual : ()-> true

    getCanvasView : ()->
      if @__view is undefined and @isVisual()
        @__view = CanvasElement.createView( @type, @ )
        ### env:dev ###
        if not @__view
          console.warn "isVisual() is true, but cannot find corresponding canvasView for ComplexResModel : #{@type}"
        ### env:dev:end ###

      @__view

    draw : ( isCreate )->
      if not @isVisual() or not Design.instance().shouldDraw() then return
      v = @getCanvasView()
      if v
        args = arguments
        args[ 0 ] = args[ 0 ] is true

        # A quick fix to suppress draw() call if the element doesn't already
        # create the svg node.
        # This should probably be refactored in the future, along with the
        # canvas rendering logics.
        if isCreate then v.nodeCreated = true
        if not isCreate and not v.nodeCreated then return

        v.draw.apply v, args
      null

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


    # ## ###########
    # AWS Related Logics
    # ## ###########
    getSubnetRef : ()->
      if Design.instance().typeIsClassic()
        return ""

      if Design.instance().typeIsDefaultVpc()
        p = this
        while p
          if p.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
            break
          p = p.parent()

        if p
          defautSubnet = MC.data.account_attribute[ Design.instance().region() ].default_subnet[ p.get("name") ]
          if defautSubnet
            return defautSubnet.subnetId || ""

        return ""

      p = this
      while p
        if p.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
          break
        p = p.parent()

      return if p then p.createRef( "SubnetId" ) else ""

    getVpcRef : ()->
      if Design.instance().typeIsClassic()
        return ""

      if Design.instance().typeIsDefaultVpc()
        p = this
        while p
          if p.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
            break
          p = p.parent()

        if p
          defautSubnet = MC.data.account_attribute[ Design.instance().region() ].default_subnet[ p.get("name") ]
          if defautSubnet
            return defautSubnet.vpcId || ""

        else
          for uid, obj of MC.data.account_attribute[ Design.instance().region() ].default_subnet
            if obj.vpcId then return obj.vpcId

        return ""

      p = this
      while p
        if p.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
          break
        p = p.parent()

      if not p
        VpcModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC )
        p = VpcModel.theVPC()

      return if p then p.createRef( "VpcId" ) else ""

    generateLayout : ()->
      layout =
        coordinate : [ @x(), @y() ]
        uid        : @id

      if @parent()
        layout.groupUId = @parent().id

      layout

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

