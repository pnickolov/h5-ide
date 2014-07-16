
define [ "Design", "./ResourceModel", "constant" ], ( Design, ResourceModel, constant )->

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
        @set '__parent', null
        attributes.__parent.addChild( this )
      null

    setName : ( name )->
      if @get("name") is name
        return

      @set "name", name
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
          @attributes.__connections = connections
          @trigger "change:__connections", @, connections
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

    draw : ()-> console.warn "ComplexResModel.draw() is deprecated", @

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
      p = this
      while p
        if p.type is constant.RESTYPE.SUBNET
          break
        p = p.parent()

      return if p then p.createRef( "SubnetId" ) else ""

    getVpcRef : ()->
      p = this
      while p
        if p.type is constant.RESTYPE.VPC
          break
        p = p.parent()

      if not p
        VpcModel = Design.modelClassForType( constant.RESTYPE.VPC )
        p = VpcModel.theVPC()

      return if p then p.createRef( "VpcId" ) else ""

    generateLayout : ()->
      layout =
        coordinate : [ @x(), @y() ]
        uid        : @id

      if @parent()
        layout.groupUId = @parent().id

      layout

    parent : ()-> @get( '__parent' ) or null
    x      : ()-> @get( 'x' ) or 0
    y      : ()-> @get( 'y' ) or 0
    width  : ()-> @get( 'width' ) or 0
    height : ()-> @get( 'height' ) or 0

  }

  ComplexResModel

