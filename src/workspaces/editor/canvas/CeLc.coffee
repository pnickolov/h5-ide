
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js", "./CpVolume" ], ( CanvasElement, constant, CanvasManager, lang, VolumePopup )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeLc"
    ### env:dev:end ###
    type : constant.RESTYPE.LC

    portPosMap : {
      "launchconfig-sg-left"  : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "launchconfig-sg-right" : [ 80, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }
    portDirMap : {
      "launchconfig-sg" : "horizontal"
    }

    defaultSize : [9,9]

    events :
      "mousedown .volume-image" : "showVolume"
      "click .volume-image"     : ()-> false

    listenModelEvents : ()->
      @listenTo @model, "change:connections", @render
      @listenTo @model, "change:volumeList", @render
      @listenTo @model, "change:imageId", @render
      return

    iconUrl : ()->
      ami = @model.getAmi() || @model.get("cachedAmi")

      if not ami
        "ide/ami/ami-not-available.png"
      else
        "ide/ami/#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"

    pos : ( el )->
      if el
        parentItem = @canvas.getItem( el.parentNode.getAttribute("data-id") )
      else
        console.warn "Accessing LC' position without svg element"
        parentItem = parentItem = @canvas.getItem( @model.connectionTargets("LcUsage")[0].id )

      if parentItem
        p = parentItem.pos()
        p.x += 2
        p.y += 3
        p
      else
        { x : 0, y : 0 }

    isTopLevel : ()-> false

    ensureLcView : ()->
      elementChanged = false

      lcParentMap = {}
      for asg in @model.connectionTargets("LcUsage")
        lcParentMap[ asg.id ] = asg
        for expanded in asg.get("expandedList")
          lcParentMap[ expanded.id ] = expanded

      views = []
      views.push(subview) for subview in @$el

      for subview in views
        parentCid = $(subview.parentNode).attr("data-id")
        parentItem = @canvas.getItem( parentCid )
        if not parentItem
          @removeView( subview )
          elementChanged = true
        else
          parentModel = parentItem.model
          if not lcParentMap[ parentModel.id ]
            @removeView( subview )
            elementChanged = true
          else
            delete lcParentMap[ parentModel.id ]

      svg = @canvas.svg
      for uid, parentModel of lcParentMap
        isOriginalAsg = parentModel.type isnt "ExpandedAsg"
        svgEl = @createNode({
          image   : "ide/icon/instance-canvas.png"
          imageX  : 15
          imageY  : 11
          imageW  : 61
          imageH  : 62
          label   : true
          labelBg : true
          sg      : isOriginalAsg
        }).add([
          # Ami Icon
          svg.image( MC.IMG_URL + @iconUrl(), 39, 27 ).move(30, 15).classes("ami-image")

          svg.use("port_diamond").move( 10, 20 ).attr({
            'class'        : 'port port-blue tooltip'
            'data-name'    : 'launchconfig-sg'
            'data-alias'   : 'launchconfig-sg-left'
            'data-tooltip' : lang.ide.PORT_TIP_D
          })
          svg.use("port_diamond").move( 80, 20 ).attr({
            'class'        : 'port port-blue tooltip'
            'data-name'    : 'launchconfig-sg'
            'data-alias'   : 'launchconfig-sg-right'
            'data-tooltip' : lang.ide.PORT_TIP_D
          })
        ]).classes("canvasel fixed AWS-AutoScaling-LaunchConfiguration").move( 20, 30 )

        if isOriginalAsg
          svgEl.add([
            # Volume Image
            svg.image( "", 29, 24 ).move(31, 46).classes('volume-image')
            # Volume Label
            svg.plain( "" ).move(45, 58).classes('volume-number')
          ])

        @addView( svgEl )
        @canvas.getItem( uid ).$el.children(":last-child").before( svgEl.node )
        elementChanged = true

      if elementChanged then @updateConnections()

      return

    # Update the svg element
    render : ( force )->
      if @canvas.initializing and not force then return

      @ensureLcView()
      m = @model
      # Update label
      CanvasManager.update @$el.children(".node-label"), m.get("name")
      # Update Image
      CanvasManager.update @$el.children(".ami-image"), @iconUrl(), "href"
      # Update Volume
      volumeCount = if m.get("volumeList") then m.get("volumeList").length else 0
      if volumeCount > 0
        volumeImage = 'ide/icon/instance-volume-attached-normal.png'
      else
        volumeImage = 'ide/icon/instance-volume-not-attached.png'
      CanvasManager.update @$el.children(".volume-image"), volumeImage, "href"
      CanvasManager.update @$el.children(".volume-number"), volumeCount


    destroy : ( selectedDomElement )->
      if @model.connections("LcUsage").length > 1
        # Just need to delete lc usage
        parentItem = @canvas.getItem( selectedDomElement.parentNode.getAttribute("data-id") )
        if not parentItem then return
        LcUsage = Design.modelClassForType("LcUsage")

        parentModel = parentItem.model
        if parentModel.type is "ExpandedAsg"
          parentModel = parentModel.get("originalAsg")
        (new LcUsage(parentModel, @model)).remove()
        return

      CanvasElement.prototype.destroy.apply this, arguments

    doDestroyModel : ()-> @model.connections("LcUsage")[0]?.remove()

    showVolume : ( evt )->
      if @volPopup then return false
      self = @

      @volPopup = new VolumePopup {
        attachment : $( evt.currentTarget ).closest("g")[0]
        host       : @model
        models     : @model.get("volumeList")
        canvas     : @canvas
        onRemove   : ()-> _.defer ()-> self.volPopup = null; return
      }
      false

  }, {
    render : ( canvas )->
      for lc in canvas.design.componentsOfType( constant.RESTYPE.LC )
        canvas.getItem( lc.id ).render( true )

    createResource : ( t, attr, option )->
      if not attr.parent then return
      if attr.parent.getLc() then return

      asg = attr.parent
      delete attr.parent

      lcModel = CanvasElement.createResource( @type, attr, option )
      asg.setLc( lcModel )
      lcModel
  }
