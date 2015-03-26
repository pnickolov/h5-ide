
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

    type : constant.RESTYPE.MESOSLC
    newNameTmpl : "slave-lc-"

  }, {

    handleTypes: constant.RESTYPE.MESOSLC

  }

  Model

