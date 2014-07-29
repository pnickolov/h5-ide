
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js", "./CanvasView", "component/dbsbgroup/DbSubnetGPopup" ], ( CanvasElement, constant, CanvasManager, lang, CanvasView, DbSubnetGPopup )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeSubnetGroup"
    ### env:dev:end ###
    type : constant.RESTYPE.DBSBG

    parentType  : [ constant.RESTYPE.VPC ]
    defaultSize : [ 19, 19 ]

    hover : ()->
      for subnet in @model.connectionTargets("SubnetgAsso")
        item = @canvas.getItem( subnet.id )
        if item
          CanvasManager.addClass item.$el, "highlight"
      false

    hoverOut : ()->
      for subnet in @model.connectionTargets("SubnetgAsso")
        item = @canvas.getItem( subnet.id )
        if item
          CanvasManager.removeClass item.$el, "highlight"
      false

    listenModelEvents : ()->
      @listenTo @model, "change:connections", @render
      return

    # Creates a svg element
    create : ()->
      svg = @canvas.svg

      svgEl = @canvas.appendSubnet( @createGroup() )
      svgEl.add([
        svg.image(MC.IMG_URL + "/ide/icon/sbg-info.png", 12, 12).move(4, 4).classes("tooltip")
      ])
      $( svgEl.node ).children(".group-label").attr({
        x : "18"
        y : "14"
      })
      m = @model
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      # Move the group to right place
      m = @model
      @$el.children("text").text m.get('name')
      @$el[0].instance.move m.x() * CanvasView.GRID_WIDTH, m.y() * CanvasView.GRID_WIDTH

      # Tooltip
      tt = []
      for sb in m.connectionTargets("SubnetgAsso")
        tt.push(sb.get("name"))

      CanvasManager.update @$el.children(".tooltip"), tt.join(", ") || "No subnet is assigned to this subnet group yet", "tooltip"
      return

    doDestroyModel : ()->
      # Disable hover effect before the model is removed.
      @hoverOut()
      CanvasElement.prototype.doDestroyModel.apply this, arguments

  }, {

    createResource : ( type, attr, option )->
      if not attr.parent then return
      model = CanvasElement.createResource( constant.RESTYPE.DBSBG, attr, option )
      new DbSubnetGPopup({model:model})
      return
  }
