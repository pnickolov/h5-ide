
define [ "./InstanceModel", "Design", "constant", "i18n!/nls/lang.js", 'CloudResources' ], ( InstanceModel, Design, constant, lang, CloudResources )->

  emptyArray = []

  Model = InstanceModel.extend {

    type        : constant.RESTYPE.INSTANCE
    subType     : constant.RESTYPE.MESOSSLAVE
    newNameTmpl : "slave-"

    defaults : ()->
      #servergroup
      count  : 1

      imageId      : ''
      tenancy      : 'default'
      ebsOptimized : false
      instanceType : "m1.small"
      monitoring   : false
      userData     : ""

      volumeList : []

      # RootDevice
      rdSize : 0
      rdIops : 0
      rdType : 'gp2'

      cachedAmi : null

      state : null

    constructor: ( attributes, options ) ->
      InstanceModel.call @, attributes, _.extend( {}, options, createBySubClass: true )
      @setMesosState() if not InstanceModel.isMesosSlave(attributes)

    initialize: ( attr, option ) ->
      InstanceModel.prototype.initialize.apply @, arguments

      if option.createByUser or option.cloneSource
        # Set auto assgin public ip
        @getEmbedEni().set("assoPublicIp", true)

    setMesosState : (attr) ->

      attributes = attr or @_getMesosAttributes() or @getDefaultMesosAttributes()

      delete attributes['az'] if attributes['az']

      attributes = _.map attributes, (value, key) ->
        return {
          key: key,
          value: value
        }

      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER).allObjects()

      masterMapAry = []
      masterIds = []
      _.each masterModels, (master) ->
        if master.isMesosMaster()
          ipRef = '@{' + master.id + '.PrivateIpAddress}'
          masterMapAry.push({
            key: ipRef,
            value: master.get('name')
          })
          masterIds.push(master.id)
      masterIds = masterIds.sort()
      serverId = String(masterIds.indexOf(@id) + 1)

      masterMapAry = _.sortBy masterMapAry, (masterMap) ->
        uid = MC.extractID(masterMap.key)
        return masterIds.indexOf(uid)

      mesosState = [{
        id: @get('name'),
        module: 'linux.mesos.slave',
        parameter: {
          masters_addresses: masterMapAry,
          attributes: attributes,
          slave_ip: '@{self.PrivateIpAddress}'
        }
      }]
      states = @get('state') or []
      states = _.filter states, (state) ->
        return false if state.module in ['linux.mesos.master', 'linux.mesos.slave']
        return true
      @set('state', states.concat(mesosState))

    getMesosState : () ->

      states = @get('state')
      if states and states[0] and states[0].module is 'linux.mesos.slave'
        return states[0]
      return null

    getDefaultMesosAttributes : () ->

      if @type is constant.RESTYPE.LC
        asgAry = @connectionTargets("LcUsage")
        azs = []
        asgs = []
        _.each asgAry, (asg) ->
          asgs.push(asg.get('name'))
          azName = _.map asg.getExpandAzs(), (az) ->
            az.get('name')
          azs = azs.concat(azName)
        return {
          'az': azs.join('|')
          'asg': asgs.join(',')
        }
      else
        return {
          'az': @parent().parent().get('name')
          'subnet': @parent().get('name')
          'subnet-position': if @parent().isPublic() then 'public' else 'private'
        }

    setMesosAttributes : (attrs) ->

      defaultAttrs = @getDefaultMesosAttributes()
      @setMesosState(_.extend(attrs or {}, defaultAttrs))

    _getMesosAttributes : () ->

      state = @getMesosState()
      attrs = state?.parameter?.attributes
      attrs = [] if not (_.isArray(attrs) and attrs.length)
      attrMap = {}
      _.each attrs, (attr) ->
        attrMap[attr.key] = attr.value
      defaultAttrs = @getDefaultMesosAttributes()
      return _.extend(attrMap, defaultAttrs)

    getMesosAttributes : () ->
      defaultKeys = _.keys(@getDefaultMesosAttributes())
      attrs       = @_getMesosAttributes()
      keys        = _.keys attrs
      customKeys  = _.difference keys, defaultKeys
      customKeys.unshift attrs
      _.pick.apply null, customKeys

    getMesosAppAttributes: ( appId = @get 'appId' ) ->
      allInstance = CloudResources(Design.instance().credentialId(), constant.RESTYPE.INSTANCE, Design.instance().region())
      thisAppDataModel = allInstance?.get(appId)
      privateIp = thisAppDataModel?.get('networkInterfaceSet')?[ 0 ]?.privateIpAddress

      @design().opsModel().getMesosData().getSlave( privateIp )

  }, {

    handleTypes : constant.RESTYPE.MESOSSLAVE

    deserialize : ( data, layout_data, resolve )->


  }

  Model.prototype.classId = InstanceModel.prototype.classId

  Model
