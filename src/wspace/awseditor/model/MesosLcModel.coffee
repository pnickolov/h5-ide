
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

    initialize : ( attr, option )->
      LcModel.prototype.initialize.apply @, arguments

      if option and option.createByUser
        @assignMesosSg()


    setMesosState             : MesosSlaveModel.prototype.setMesosState
    getMesosState             : MesosSlaveModel.prototype.getMesosState
    getDefaultMesosAttributes : MesosSlaveModel.prototype.getDefaultMesosAttributes
    setMesosAttributes        : MesosSlaveModel.prototype.setMesosAttributes
    _getMesosAttributes       : MesosSlaveModel.prototype._getMesosAttributes
    getMesosAttributes        : MesosSlaveModel.prototype.getMesosAttributes
    getMesosAppAttributes     : MesosSlaveModel.prototype.getMesosAppAttributes
    assignMesosSg             : MesosSlaveModel.prototype.assignMesosSg

    isRemovable : -> error : lang.CANVAS.ERR_DEL_LC

  }, {

    handleTypes: constant.RESTYPE.MESOSLC

  }

  Model.prototype.classId = LcModel.prototype.classId

  Model
