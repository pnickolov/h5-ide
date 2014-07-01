
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeSgAsso"
    ### env:dev:end ###
    type : "SgAsso"

    initialize : ( options )->
      # Listen to Sg's name change, so that we could update the label tooltip
      @listenTo @model.getTarget( constant.RESTYPE.SG ), "change:name", @render

      CanvasElement.prototype.initialize.call this, options
      return

    remove : ()-> @render()

    # Update the svg element
    render : ( force )->
      if @canvas.initializing and not force then return

      m = @model
      resource = m.getOtherTarget( constant.RESTYPE.SG )
      res_node = @canvas.getItem( resource.id )

      if not res_node then return

      sgs = m.sortedSgList()
      if sgs.length > 5 then sgs.length = 5

      childrens = res_node.$el.children(".node-sg-color-group").children( ":first-child" )
      i = 0
      while i < 5
        sg = sgs[i]
        if sg
          CanvasManager.update( childrens, sg.color, "color" )
          CanvasManager.update( childrens, sg.get("name"), "tooltip" )
        else
          CanvasManager.update( childrens, "none", "color" )
          CanvasManager.update( childrens, "", "tooltip" )

        ++i
        childrens = childrens.next()
      return

  }, {
    render : ( canvas )->
      updateMap = {}
      for asso in canvas.design.componentsOfType( "SgAsso" )
        updateMap[ asso.getOtherTarget( constant.RESTYPE.SG ).id ] = asso.id

      for resId, assoId of updateMap
        canvas.getItem( assoId ).render( true )

      return
  }
