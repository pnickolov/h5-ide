
define [ "constant", "../ResourceModel", "Design"  ], ( constant, ResourceModel, Design )->

  Model = ResourceModel.extend {
    type : constant.RESTYPE.DHCP

    defaults : ()->
      dhcpOptionsId: ""

    isAuto     : ()-> @attributes.dhcpOptionsId is ""
    isDefault  : ()-> @attributes.dhcpOptionsId is "default"
    isCustom   : ()-> not (@attributes.dhcpOptionsId is '' or @attributes.dhcpOptionsId is 'default')

    setNone    : ()-> @set "dhcpOptionsId", ""
    setDefault : ()-> @set "dhcpOptionsId", "default"
    setDhcp    : (val)->
        if @get('dhcpOptionsId') isnt val
            @set "dhcpOptionsId", val
    set : ()->
      if @design().modeIsAppEdit() and not @__newIdForAppEdit
        @__newIdForAppEdit = @design().guid()

      Backbone.Model.prototype.set.apply this, arguments

    createRef : ( refName, isResourceNS, id )->
      if not id
        id = @__newIdForAppEdit or @id

      ResourceModel.prototype.createRef.call this, refName, isResourceNS, id

    serialize : ()->

      if not @isCustom()
        return
      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()

      if @__newIdForAppEdit
        id = @__newIdForAppEdit
        appId = ""
      else
        id = @id
        appId = @get("appId")
      component =
        name : "DhcpOption"
        type : @type
        uid  : id
        resource :
          DhcpOptionsId        : @toJSON().dhcpOptionsId

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
