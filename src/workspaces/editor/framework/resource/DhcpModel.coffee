
define [ "constant", "../ResourceModel", "Design"  ], ( constant, ResourceModel, Design )->

  Model = ResourceModel.extend {
    type       : constant.RESTYPE.DHCP

    defaults   : ()->
      appId: ""

    isAuto     : ()-> @attributes.appId is ""
    isDefault  : ()-> @attributes.appId is "default"
    isCustom   : ()-> not (@attributes.appId is '' or @attributes.appId is 'default')

    setNone    : ()-> @set "appId", ""
    setDefault : ()-> @set "appId", "default"
    setDhcp    : (val)->
        if @get('appId') isnt val
            @set "appId", val
    set : ()->

      Backbone.Model.prototype.set.apply this, arguments

    createRef : ( refName, isResourceNS, id )->
      if not id
        id = @id

      ResourceModel.prototype.createRef.call this, refName, isResourceNS, id

    serialize : ()->
#      if not @isCustom()
       return

#      id = @id
#      component =
#        name : "DhcpOption"
#        type : @type
#        uid  : id
#        resource :
#          DhcpOptionsId : @get "appId"
#
#      { component : component }

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
