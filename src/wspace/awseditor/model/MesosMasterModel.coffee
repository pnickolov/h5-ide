
define [ "./InstanceModel", "Design", "constant", "i18n!/nls/lang.js", 'CloudResources' ], ( InstanceModel, Design, constant, lang, CloudResources )->

  emptyArray = []

  Model = InstanceModel.extend {

    type        : constant.RESTYPE.INSTANCE
    subType     : constant.RESTYPE.MESOSMASTER
    newNameTmpl : "master-"

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
      @setMesosState() if not InstanceModel.isMesosMaster(attributes)

    initialize: ( attr, option ) ->
      InstanceModel.prototype.initialize.apply @, arguments

      if option.createByUser or option.cloneSource
        # Set auto assgin public ip
        @getEmbedEni().set("assoPublicIp", true)

    setMesosState : (marathon) ->

      Model.getMasterIPs()
      marathon = @_getMarathon() if marathon is undefined
      stackName = Design.instance().get('name')
      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER).allObjects()
      masterMapAry = []
      _.each masterModels, (master) ->
        if master.isMesosMaster()
          ipRef = '@{' + master.id + '.PrivateIpAddress}'
          masterMapAry.push({
            key: ipRef,
            value: master.get('name')
          })
      mesosState = [{
        id: @get('name'),
        module: 'linux.mesos.master',
        parameter: {
          cluster_name: stackName,
          master_ip: '@{self.PrivateIpAddress}',
          server_id: @get('name'),
          masters_addresses: masterMapAry,
          hostname: @get('name'),
          framework: if marathon then ['marathon'] else []
        }
      }]
      states = @get('state') or []
      states = _.filter states, (state) ->
        return false if state.module in ['linux.mesos.master', 'linux.mesos.slave']
        return true
      @set('state', mesosState.concat(states))

    getMesosState : () ->

      states = @get('state')
      if states and states[0] and states[0].module is 'linux.mesos.master'
        return states[0]
      return null

    # must invoke Model.setMarathon
    _setMarathon : (flag) ->

      @setMesosState(flag)

    # must invoke Model.getMarathon
    _getMarathon : () ->

      state = @getMesosState()
      framework = state?.parameter?.framework or []
      if 'marathon' in framework
        return true
      return false

  }, {

    handleTypes : constant.RESTYPE.MESOSMASTER

    deserialize : ( data, layout_data, resolve )->

    setMarathon : (flag) ->

      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER).allObjects()
      _.each masterModels, (master) ->
        master._setMarathon(flag) if master.isMesosMaster()

    getMarathon : () ->

      haveMarathon = true
      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER).allObjects()
      _.each masterModels, (master) ->
        if master.isMesosMaster()
          if not master._getMarathon()
            haveMarathon = false
        null
      return haveMarathon

    getMasterIPs : () ->

      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER).allObjects()
      _.each masterModels, (master) ->
        master
      return []

  }

  Model.prototype.classId = InstanceModel.prototype.classId

  Model
