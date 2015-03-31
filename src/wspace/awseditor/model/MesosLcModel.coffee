
define [ "./LcModel", "./MesosSlaveModel", "Design", "constant", "./VolumeModel", 'i18n!/nls/lang.js', 'CloudResources' ], ( LcModel, MesosSlaveModel, Design, constant, VolumeModel, lang, CloudResources )->

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

      # Set Auto assgin public ip value true
      publicIp: true

    constructor: ( attributes, options ) ->
      LcModel.call @, attributes, _.extend( {}, options, createBySubClass: true )
      Model = Design.modelClassForType(constant.RESTYPE.INSTANCE)
      @setMesosState() if not Model.isMesosSlave(attributes)

    setMesosState             : MesosSlaveModel.prototype.setMesosState
    getMesosState             : MesosSlaveModel.prototype.getMesosState
    getDefaultMesosAttributes : MesosSlaveModel.prototype.getDefaultMesosAttributes
    setMesosAttributes        : MesosSlaveModel.prototype.setMesosAttributes
    _getMesosAttributes       : MesosSlaveModel.prototype._getMesosAttributes
    getMesosAttributes        : MesosSlaveModel.prototype.getMesosAttributes
    getMesosAppAttributes     : MesosSlaveModel.prototype.getMesosAppAttributes

  }, {

    handleTypes: constant.RESTYPE.MESOSLC

  }

  Model.prototype.classId = LcModel.prototype.classId

  Model
