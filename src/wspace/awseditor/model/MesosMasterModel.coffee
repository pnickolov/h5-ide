
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
      masterIds = []
      _.each masterModels, (master) ->
        if master.isMesosMaster()
          ipRef = '@{' + master.id + '.PrivateIpAddress}'
          masterMapAry.push({
            key: ipRef,
            value: master.get('name')
          })
          masterIds.push(master.get('name'))
      masterIds = masterIds.sort()
      serverId = String(masterIds.indexOf(@get('name')))
      mesosState = [{
        id: "state-" + @get('name'),
        module: 'linux.mesos.master',
        parameter: {
          cluster_name: stackName,
          master_ip: '@{self.PrivateIpAddress}',
          server_id: serverId,
          masters_addresses: masterMapAry,
          hostname: @get('name'),
          framework: if marathon then ['marathon'] else []
        }
      }]
      states = @get('state') or []
      states = _.filter states, (state) ->
        return false if state.module in ['linux.mesos.master', 'linux.mesos.slave']
        return true
      @set('state', states.concat(mesosState))

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

      design = Design.instance()
      eniData = design.componentsOfType(constant.RESTYPE.ENI)
      targetEni = _.find eniData, (eni)->
        _.some eni.getIpArray(), (ipObj)->
          ipObj.ip is ip

      if not targetEni
        vpcId = design.componentsOfType(constant.RESTYPE.VPC)[0].get("appId")
        instanceData = CloudResources(design.credentialId(), constant.RESTYPE.INSTANCE, design.region())
        targetInstance = _.find instanceData.where({"vpcId": vpcId}), (instance)->
          instance.get("privateIpAddress") is ip

        if not targetInstance then return null
        asgResList = CloudResources( design.credentialId(), constant.RESTYPE.ASG, design.region())

        targetAsgId = _.find asgResList.toJSON(), (asg)->
          _.some asg.Instances, (instance)->
            instance.InstanceId is targetInstance.get("instanceId")
        .id

        targetAsg = _.find design.componentsOfType(constant.RESTYPE.ASG), (asg)->
          asg.get("appId") is targetAsgId
        return targetAsg.getLc()

      else
        targetInstance = targetEni.attachedInstance()
        return targetInstance

  }

  Model.prototype.classId = InstanceModel.prototype.classId

  Model
