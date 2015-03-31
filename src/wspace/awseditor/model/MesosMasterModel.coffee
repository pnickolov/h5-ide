
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

        # Set Framework
        @setMarathon Model.getMarathon()

    setMesosState : (marathon = Model.getMarathon()) ->

      ipMap = Model.getMasterIPs()
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
    setMarathon : (flag) ->

      @setMesosState(flag)

    # must invoke Model.getMarathon
    getMarathon : () ->

      state = @getMesosState()
      framework = state?.parameter?.framework or []
      if 'marathon' in framework
        return true
      return false

  }, {

    handleTypes : constant.RESTYPE.MESOSMASTER

    deserialize : ( data, layout_data, resolve )->

    setMarathon : (flag) ->
      @each masterModels, (master) -> master.setMarathon(flag) if master.isMesosMaster()

    getMarathon : () ->
      @some (master) -> master.isMesosMaster() and master.getMarathon()

    getMasterIPs : () ->
      mode = Design.instance().mode()
      return {} if mode is 'stack'
      eniData = CloudResources(Design.instance().credentialId(), constant.RESTYPE.ENI, Design.instance().region())
      ipMap = {}
      @each (master) ->
        if master.isMesosMaster()
          eniId = master.getEmbedEni().get('appId')
          eni = eniData.get(eniId)
          if eni
            privateIp = eni.get('privateIpAddress')
            publicIp = eni.get('association')?.publicIp
            if privateIp and publicIp
              ipMap[privateIp] = publicIp
        null
      return ipMap

    getCompByIp: (ip)->
      if Design.instance().mode() is "stack"
        return null

      eniData = Design.instance().componentsOfType(constant.RESTYPE.ENI)
      targetEni = _.find eniData, (eni)->
        _.some eni.getIpArray(), (ipObj)->
          ipObj.ip is ip

      if not targetEni then return null
      targetInstance = targetEni.attachedInstance()
      targetInstance

  }

  Model.prototype.classId = InstanceModel.prototype.classId

  Model
