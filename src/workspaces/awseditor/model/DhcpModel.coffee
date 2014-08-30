
define [ "constant", "ResourceModel", "Design"  ], ( constant, ResourceModel, Design )->

  Model = ResourceModel.extend {
    type       : constant.RESTYPE.DHCP

    defaults   : ()->
      appId: ""

    isAuto     : ()-> @attributes.appId is ""
    isDefault  : ()-> @attributes.appId is "default"
    isCustom   : ()-> not (@attributes.appId is '' or @attributes.appId is 'default')
    getDhcp    : ()-> @get('appId')
    setAuto    : ()-> @set 'appId', ""
    setDefault : ()-> @set "appId", "default"
    setDhcp    : (val)->
        if @get('appId') isnt val
            @set "appId", val
    serialize : ()->
       return

  }, {

    handleTypes : constant.RESTYPE.DHCP
    deserialize : ( data )->
      attr = {}
      attr.id    = data.uid
      attr.appId = data.resource.DhcpOptionsId
      new Model( attr )
      null
  }

  Model
