
define [ "./LcModel", "./InstanceModel", "Design", "constant", "./VolumeModel", 'i18n!/nls/lang.js', 'CloudResources' ], ( LcModel, InstanceModel, Design, constant, VolumeModel, lang, CloudResources )->

  emptyArray = []

  Model = LcModel.extend {

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

    type : constant.RESTYPE.MESOSLC
    newNameTmpl : "slave-lc-"

  }, {

    handleTypes: constant.RESTYPE.MESOSLC

  }

  Model
