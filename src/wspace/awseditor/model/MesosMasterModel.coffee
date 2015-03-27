
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
      Model = Design.modelClassForType(constant.RESTYPE.INSTANCE)
      @setMesosState() if not Model.isMesosMaster(attributes)

    setMesosState : (marathon) ->

      marathon = @getMarathon() if marathon is undefined
      stackName = Design.instance().get('name')
      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER).allObjects()
      masterMap = {}
      _.each masterModels, (master) ->
        ipRef = '@{' + master.id + '.PrivateIpAddress}'
        masterMap[master.get('name')] = ipRef
      @set('state', [{
        id: @get('name'),
        module: 'linux.mesos.master',
        parameter: {
          cluster_name: stackName,
          server_id: @get('name'),
          masters_addresses: masterMap,
          hostname: @get('name'),
          framework: if marathon then ['marathon'] else []
        }
      }])

    getMesosState : () ->

      states = @get('state')
      if states and states[0] and states[0].module is 'linux.mesos.master'
        return states[0]
      return null

    setMarathon : (flag) ->

      @setMesosState(flag)

    getMarathon : () ->

      state = @getMesosState()
      if 'marathon' in (state?.parameter?.framework)
        return true
      return false

  }, {

    handleTypes : constant.RESTYPE.MESOSMASTER

    deserialize : ( data, layout_data, resolve )->

  }

  Model.prototype.classId = InstanceModel.prototype.classId

  Model
