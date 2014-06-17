
define [ "constant", "../ConnectionModel", "i18n!nls/lang.js" ], ( constant, ConnectionModel, lang )->

  ConnectionModel.extend
    # offset of asg
    offset:
      x: 2
      y: 3

    type : "Lc_Asso"

    ceType: "Lc_Asso"

    node_line: false

    oneToMany : constant.RESTYPE.LC

    defaults:
      x        : 0
      y        : 0
      width    : 9
      height   : 9

    isVisual : () -> true

    isRemovable: ->
      if @connections.length is 1
        lcName = @getLc().get('name')
        asgName = @getAsg().get('name')
        return sprintf lang.ide.CVS_CFM_DEL_LC lcName, asgName, asgName, lcName

    remove: () ->
      if @connections.length is 1
        @getLc().remove()

      ConnectionModel.remove.call this


    initialize: ( attr, option ) ->
      # Draw before create SgAsso
      @draw(true)

    x: ()-> @getAsg().x() + @offset.x || 0
    y: ()-> @getAsg().y() + @offset.y || 0

    width: ()-> @attributes.width || 0
    height: ()-> @attributes.height || 0

    getLc: -> @getTarget(constant.RESTYPE.LC)
    getAsg: -> @getTarget(constant.RESTYPE.ASG)

    connections: ->
      @getLc().connections()


