
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

      framework: ['marathon']

    constructor: ( attributes, options ) ->
      InstanceModel.call @, attributes, _.extend( {}, options, createBySubClass: true )

    setMesosState : () ->

      stackName = Design.instance().get('name')
      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER)
      masterMap = {}
      _.each masterModels, (master) ->
        ipRef = '@{' + master.id + '.PrivateIpAddress}'
        masterMap[ipRef] = @get('name')
      @set('state', {
        id: @get('name'),
        module: 'linux.mesos.master',
        parameter: {
          cluster_name: stackName,
          server_id: @get('name'),
          masters_addresses: masterMap,
          hostname: @get('name'),
          framework: @get('framework')
        }
      })

  }, {

    handleTypes : constant.RESTYPE.MESOSMASTER

    deserialize : ( data, layout_data, resolve )->

  }

  Model
