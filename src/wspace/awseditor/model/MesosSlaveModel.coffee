
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
      Model = Design.modelClassForType(constant.RESTYPE.INSTANCE)
      @setMesosState() if not Model.isMesosSlave(attributes)

    setMesosState : (attr) ->

      attributes = attr or @_getMesosAttributes() or @getDefaultMesosAttributes()

      attributes = _.map attributes, (value, key) ->
        return {
          key: key,
          value: value
        }

      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER).allObjects()
      masterMapAry = []
      _.each masterModels, (master) ->
        if master.isMesosMaster()
          ipRef = '@{' + master.id + '.PrivateIpAddress}'
          masterMapAry.push({
            key: ipRef,
            value: master.get('name')
          })
      @set('state', [{
        id: @get('name'),
        module: 'linux.mesos.slave',
        parameter: {
          masters_addresses: masterMapAry,
          attributes: attributes,
          slave_ip: '@{self.PrivateIpAddress}'
        }
      }])

    getMesosState : () ->

      states = @get('state')
      if states and states[0] and states[0].module is 'linux.mesos.slave'
        return states[0]
      return null

    getDefaultMesosAttributes : () ->

      if @type is constant.RESTYPE.LC
        asgAry = @connectionTargets("LcUsage")
        azs = []
        _.each asgAry, (asg) ->
          azName = _.map asg.getExpandAzs(), (az) ->
            az.get('name')
          azs = azs.concat(azName)
        return {
          'az': azs.join('|')
        }
      else
        return {
          'az': @parent().parent().get('name')
          'subnet': @parent().get('name')
          'subnet-position': 'public'
        }

    setMesosAttributes : (attrs) ->

      defaultAttrs = @getDefaultMesosAttributes()
      @setMesosState(_.extend(attrs or {}, defaultAttrs))

    _getMesosAttributes : () ->

      state = @getMesosState()
      attrs = state?.parameter?.attributes
      if attrs
        attrMap = {}
        _.each attrs, (attr) ->
          attrMap[attr.key] = attr.value
        return attrMap
      {}

    getMesosAttributes : () ->
      defaultKeys = _.keys(@getDefaultMesosAttributes())
      attrs       = @_getMesosAttributes()
      keys        = _.keys attrs
      customKeys  = _.difference keys, defaultKeys

      customKeys.unshift attrs

      _.pick.apply null, customKeys

  }, {

    handleTypes : constant.RESTYPE.MESOSSLAVE

    deserialize : ( data, layout_data, resolve )->


  }

  Model.prototype.classId = InstanceModel.prototype.classId

  Model
