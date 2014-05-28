
define [ "constant", "../ResourceModel", "Design"  ], ( constant, ResourceModel, Design )->

  Model = ResourceModel.extend {
    type : constant.RESTYPE.DHCP

    defaults : ()->
      dhcpOptionId: ""

    isNone     : ()-> @attributes.dhcpOptionId is "none"
    isDefault  : ()-> @attributes.dhcpOptionId is "default"
    isCustom   : ()-> not @isNone() and not @isDefault()

    setNone    : ()-> @set "dhcpOptionId", "none"
    setDefault : ()-> @set "dhcpOptionId", "default"
    setDhcp    : (val)-> @set "dhcpOptionId", val
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
          DhcpOptionsId        : if @newId then @toJSON().dhcpOptionsId else appId
          VpcId                : vpc.createRef( "VpcId" )

      { component : component }

  }, {

    handleTypes : constant.RESTYPE.DHCP

    deserialize : ( data, layout_data )->
      attr = {}
      attr.id    = data.uid
      attr.appId = data.resource.DhcpOptionsId
      new Model( attr )
      null
  }

  Model
