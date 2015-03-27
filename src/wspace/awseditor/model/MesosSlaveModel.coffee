
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

      attributes = attr or @getDefaultMesosAttributes()

      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER).allObjects()
      masterMap = {}
      _.each masterModels, (master) ->
        ipRef = '@{' + master.id + '.PrivateIpAddress}'
        masterMap[ipRef] = master.get('name')
      @set('state', [{
        id: @get('name'),
        module: 'linux.mesos.slave',
        parameter: {
          masters_addresses: masterMap,
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

      return {
        'az': @parent().parent().get('name')
        'subnet': @parent().get('name')
        'subnet-position': 'public'
      }

    setMesosAttributes : (attrs) ->

      defaultAttrs = @getDefaultMesosAttributes()
      @setMesosState(_.extend(attrs or {}, defaultAttrs))

    getMesosAttributes : () ->

      readonlyKey = _.keys(@getDefaultMesosAttributes())
      state = @getMesosState()
      attrs = state?.parameter?.attributes
      if attrs
        return _.map attrs, (value, key) ->
          return {
            key: key
            value: value
            readonly: (key in readonlyKey)
          }
      return []

  }, {

    handleTypes : constant.RESTYPE.MESOSSLAVE

    deserialize : ( data, layout_data, resolve )->


  }

  Model.prototype.classId = InstanceModel.prototype.classId

  Model
