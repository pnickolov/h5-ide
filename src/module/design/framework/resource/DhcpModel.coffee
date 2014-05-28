
define [ "constant", "../ResourceModel", "Design"  ], ( constant, ResourceModel, Design )->

  Model = ResourceModel.extend {
    type : constant.RESTYPE.DHCP

    defaults : ()->
      dhcpOptionsId: ""

    isNone     : ()-> @attributes.dhcpOptionsId is "none"
    isDefault  : ()-> @attributes.dhcpOptionsId is "default"
    isCustom   : ()-> not (@attributes.dhcpOptionsId is 'none' or @attributes.dhcpOptionsId is 'default')

    setNone    : ()-> @set "dhcpOptionsId", "none"
    setDefault : ()-> @set "dhcpOptionsId", "default"
    setDhcp    : (val)->
        if @get('dhcpOptionsId') isnt val
            @newId = @design().guid()
            @set "dhcpOptionsId", val
    set : ()->
      if Array::slice.call(arguments)[1] is true
          @newId = @design().guid()
      if @design().modeIsAppEdit() and not @__newIdForAppEdit
        @__newIdForAppEdit = @design().guid()

      Backbone.Model.prototype.set.apply this, arguments

    createRef : ( refName, isResourceNS, id )->
      if not id
        id = @__newIdForAppEdit or @newId or @id

      ResourceModel.prototype.createRef.call this, refName, isResourceNS, id

    serialize : ()->

      if not @isCustom()
        return
      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()

      if @__newIdForAppEdit
        id = @__newIdForAppEdit
        appId = ""
      else if @newId
          id = @newId
          appId = @get('appId')
      else
        id = @id
        appId = @get("appId")
      component =
        name : "DhcpOption"
        type : @type
        uid  : id
        resource :
          DhcpOptionsId        : @toJSON().dhcpOptionsId
          VpcId                : vpc.createRef( "VpcId" )

      { component : component }

  }, {

    handleTypes : constant.RESTYPE.DHCP
    deserialize : ( data, layout_data )->
      attr = {}
      attr.dhcpOptionsId = data.resource.DhcpOptionsId
      attr.id    = data.uid
      attr.appId = data.resource.DhcpOptionsId
      new Model( attr )
      null
  }

  Model
