
define [
  "CanvasView"
  "constant"
  "i18n!/nls/lang.js"
  "Design"
], ( CanvasView, constant, lang, Design )->

  isPointInRect = ( point, rect )->
    rect.x1 <= point.x and rect.y1 <= point.y and rect.x2 >= point.x and rect.y2 >= point.y

  CanvasView.extend {

    recreateStructure : ()->
      @svg.clear().add([
        @svg.group().classes("layer_group")
        @svg.group().classes("layer_line")
        @svg.group().classes("layer_node")
      ])
      return

    errorMessageForDrop : ( type )->
      switch type
        when constant.RESTYPE.VOL       then return lang.CANVAS.WARN_NOTMATCH_VOLUME
        when constant.RESTYPE.SUBNET    then return lang.CANVAS.WARN_NOTMATCH_SUBNET
        when constant.RESTYPE.INSTANCE  then return lang.CANVAS.WARN_NOTMATCH_INSTANCE_SUBNET
        when constant.RESTYPE.ENI       then return lang.CANVAS.WARN_NOTMATCH_ENI
        when constant.RESTYPE.RT        then return lang.CANVAS.WARN_NOTMATCH_RTB
        when constant.RESTYPE.ELB       then return lang.CANVAS.WARN_NOTMATCH_ELB
        when constant.RESTYPE.CGW       then return lang.CANVAS.WARN_NOTMATCH_CGW
        when constant.RESTYPE.ASG       then return lang.CANVAS.WARN_NOTMATCH_ASG
        when constant.RESTYPE.IGW       then return lang.CANVAS.WARN_NOTMATCH_IGW
        when constant.RESTYPE.VGW       then return lang.CANVAS.WARN_NOTMATCH_VGW
        when constant.RESTYPE.DBSBG      then return lang.CANVAS.WARN_NOTMATCH_SGP_VPC
        when constant.RESTYPE.DBINSTANCE then return lang.CANVAS.WARN_NOTMATCH_DBINSTANCE_SGP

    isReadOnly : ()-> @design.modeIsApp()
  }

