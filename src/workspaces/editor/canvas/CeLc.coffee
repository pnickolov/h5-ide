
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

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

    initialize : ( options )->
      @listenTo @model, "change:__connections", @render
      CanvasElement.prototype.initialize.call this, options
      return

    iconUrl : ()->
      ami = @model.getAmi() || @model.get("cachedAmi")

      if not ami
        "ide/ami/ami-not-available.png"
      else
        "ide/ami/#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"

    pos : ( el )->
      p = CanvasElement.prototype.pos.call this, el
      p.x += 2
      p.y += 3
      p

    ensureLcView : ()->
      lcParentMap = {}
      for asg in @model.connectionTargets("LcUsage")
        lcParentMap[ asg.id ] = asg
        for expanded in asg.get("expandedList")
          lcParentMap[ expanded.id ] = expanded

      for subview in @$el.slice(0)
        parentCid = $(subview.parent).attr("data-id")
        parentItem = @canvas.getItem( parentCid )
        if not parentItem
          @remvoeView( subview )

        parentModel = parentItem.model
        if not lcParentMap[ parentItem.model.id ]
          @remvoeView( subview )
        else
          delete lcParentMap[ parentItem.model.id ]

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
          labelBg : isOriginalAsg
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
            svg.image( "", 29, 24 ).move(21, 46).classes('volume-image')
            # Volume Label
            svg.plain( "" ).move(36, 58).classes('volume-number')
          ])

        @addView( svgEl )
        @canvas.getItem( uid ).$el.children(":last-child").before( svgEl.node )

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

  }, {
    render : ( canvas )->
      for lc in canvas.design.componentsOfType( constant.RESTYPE.LC )
        canvas.getItem( lc.id ).render( true )
  }
