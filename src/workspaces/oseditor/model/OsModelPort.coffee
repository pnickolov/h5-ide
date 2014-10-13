
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPORT
    newNameTmpl : "port-"


    defaults: ()->
      ip : ""
      macAddress : ""
      deviceIndex: 0

    initialize : ( attributes, option ) ->

      if option.createByUser
        Design.modelClassForType(constant.RESTYPE.OSSG).attachDefaultSG(@)
        @assignIP()

    assignIP : () ->

      parent = @parent()
      if @isEmbedded()
        parent = @owner().parent()
      availableIP = Model.getAvailableIP(parent)
      @set('ip', availableIP) if availableIP

    onParentChanged : (oldParent) ->

      if oldParent
        @assignIP() if not @isEmbedded()

    owner : ()-> @connectionTargets("OsPortUsage")[0]
    isAttached : ()-> !!@owner()

    isVisual : ()-> !@isEmbedded()
    isEmbedded : ()->
      if not @parent() then return true
      @owner() and @owner().embedPort() is @

    setFloatingIp : ( hasFip )->
      oldUsage = @connections("OsFloatIpUsage")[0]
      if not hasFip
        if oldUsage then oldUsage.remove()
      else
        if not oldUsage
          Usage = Design.modelClassForType("OsFloatIpUsage")
          new Usage( this )
      (if @isEmbedded() then @owner() else @).trigger 'change:fip'
      return

    getFloatingIp : ()-> @connectionTargets("OsFloatIpUsage")[0]

    serialize : ()->

      if @isEmbedded()
        subnet = @owner().parent()
      else
        subnet = @parent()

      # generate device index
      that = @
      deviceIndex = 0
      if @owner() and not @isEmbedded()
        ports = @owner().connectionTargets("OsPortUsage")
        _.each ports, (port, idx) ->
          if that is port
            deviceIndex = idx
          null

      {
        layout : @generateLayout()
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id   : @get("appId")
            name : @get("name")

            mac_address     : @get("macAddress")
            security_groups : @connectionTargets("OsSgAsso").map ( sg )-> sg.createRef("id")
            network_id      : subnet.parent().createRef("id")
            device_id       : if @owner() then @owner().createRef("id") else ""
            device_index    : deviceIndex
            fixed_ips       : [{
              subnet_id  : subnet.createRef("id")
              ip_address : @get("ip")
            }]
      }

    setIp: (ip)->
      @set "ip", ip

  }, {

    handleTypes  : constant.RESTYPE.OSPORT

    deserialize : ( data, layout_data, resolve )->
      port = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        parent : resolve( MC.extractID( data.resource.fixed_ips[0].subnet_id) )

        ip : data.resource.fixed_ips[0].ip_address
        macAddress : data.resource.mac_address

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      SgAsso = Design.modelClassForType( "OsSgAsso" )
      for sg in data.resource.security_groups
        new SgAsso( port, resolve( MC.extractID( sg ) ) )

      return

    getAvailableIP : (subnetModel) ->

        subnetCIDR = subnetModel.get('cidr')

        # get ip filter list
        filterList = []
        allPortModels = Design.modelClassForType(constant.RESTYPE.OSPORT).allObjects()
        allListenerModels = Design.modelClassForType(constant.RESTYPE.OSLISTENER).allObjects()

        models = allPortModels.concat(allListenerModels)

        _.each models, (model) ->

            if model.isEmbedded and model.isEmbedded()
                currentSubnetModel = model.owner().parent()
            else
                currentSubnetModel = model.parent()
            if currentSubnetModel is subnetModel
                filterList.push(model.get('ip'))
            null

        # get available ip
        availableIPAry = Design.modelClassForType(constant.RESTYPE.ENI).getAvailableIPInCIDR(subnetCIDR, filterList, 0, [0, 1, 2])
        if availableIPAry and availableIPAry[availableIPAry.length - 1]
            ipObj = availableIPAry[availableIPAry.length - 1]
            return ipObj.ip if ipObj.available

        return null

  }

  Model
