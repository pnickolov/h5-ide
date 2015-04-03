
define [
  "CanvasView"
  "constant"
  "i18n!/nls/lang.js"
  "../template/TplOpsEditor"
  "Design"
], ( CanvasView, constant, lang, TplOpsEditor, Design )->

  isPointInRect = ( point, rect )->
    rect.x1 <= point.x and rect.y1 <= point.y and rect.x2 >= point.x and rect.y2 >= point.y

  CanvasView.extend {

    initialize : ()->
      CanvasView.prototype.initialize.apply this, arguments
      @$el.addClass("marathon").toggleClass("empty", !@hasItems()).append TplOpsEditor.canvas.placeholder()

    hasItems : ()-> @items().length > 1 # There would be at least one item which stands for the SVG element.

    recreateStructure : ()->
      @svg.clear().add([
        @svg.group().classes("layer_group")
        @svg.group().classes("layer_line")
        @svg.group().classes("layer_node")
      ])
      return

    appendGroup  : ( svgEl )->
      el = @__appendSvg(svgEl, ".layer_group")
      self = @
      setTimeout (()-> self.sortGroup()), 0
      el

    sortGroup : ()->
      # Make sure parent groups are before child groups
      groups = _.chain( @items() )
        .filter((i)-> i.type is constant.RESTYPE.MRTHGROUP)
        .sortBy((i)-> i.parentCount())
        .map((i)-> i.$el[0])
        .value()

      parent    = $(@svg.node).children(".layer_group")[0]
      childrens = $(parent).children().splice(0)

      needToUpdate = false
      for g, idx in childrens
        if groups[idx] isnt g
          needToUpdate = true
          break

      if not needToUpdate then return

      for ch in childrens
        parent.removeChild(ch)

      for g, idx in groups
        parent.appendChild( g )
      return

    fixConnection : ( coord, initiator, target )->
    highLightItems : ()->

    appendNode   : ( svgEl )-> @__appendSvg(svgEl, ".layer_node")
    appendline   : ( svgEl )-> @__appendSvg(svgEl, ".layer_line")

    addItem : ()->
      @$el.removeClass("empty")
      CanvasView.prototype.addItem.apply this, arguments

    removeItem : ()->
      CanvasView.prototype.removeItem.apply this, arguments
      @$el.toggleClass("empty", !@hasItems())

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

