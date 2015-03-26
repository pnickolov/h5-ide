
define [ "./LcModel", "./InstanceModel", "Design", "constant", "./VolumeModel", 'i18n!/nls/lang.js', 'CloudResources' ], ( LcModel, InstanceModel, Design, constant, VolumeModel, lang, CloudResources )->

  emptyArray = []

  Model = LcModel.extend {

    type        : constant.RESTYPE.LC
    subType     : constant.RESTYPE.MESOSLC
    newNameTmpl : "slave-lc-"

    defaults : ()->
      imageId      : ""
      ebsOptimized : false
      instanceType : "m1.small"
      monitoring   : false
      userData     : ""
      publicIp     : false
      state        : null

      # RootDevice
      rdSize : 0
      rdIops : ""
      rdType : 'gp2'

      attributes: {}

    constructor: ( attributes, options ) ->
      LcModel.call @, attributes, _.extend( {}, options, createBySubClass: true )

    setMesosState : () ->

      masterModels = Design.modelClassForType(constant.RESTYPE.MESOSMASTER)
      masterMap = {}
      _.each masterModels, (master) ->
        ipRef = '@{' + master.id + '.PrivateIpAddress}'
        masterMap[ipRef] = @get('name')
      @set('state', {
        id: @get('name'),
        module: 'linux.mesos.slave',
        parameter: {
          masters_addresses: masterMap,
          attributes: {},
          slave_ip: '@{self.PrivateIpAddress}'
        }
      })

  }, {

    handleTypes: constant.RESTYPE.MESOSLC

  }

  Model.prototype.classId = LcModel.prototype.classId

  Model
