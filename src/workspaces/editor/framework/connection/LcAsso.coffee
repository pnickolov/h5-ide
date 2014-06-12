
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  ConnectionModel.extend
    # offset of asg
    offset:
      x: 2
      y: 3

    type : "Lc_Asso"

    ceType: "Lc_Asso"

    oneToMany : constant.RESTYPE.ASG

    defaults:
      x        : 0
      y        : 0
      width    : 9
      height   : 9

    isVisual : () -> true

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

