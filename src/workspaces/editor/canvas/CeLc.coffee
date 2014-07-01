
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

    iconUrl : ()->
      ami = @model.getAmi() || @model.get("cachedAmi")

      if not ami
        "ide/ami/ami-not-available.png"
      else
        "ide/ami/#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"

    # Creates a svg element
    create : ()->
      @ensureLcView()

    ensureLcView : ()->
      lcParentMap = {}

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

          svg.use("port_diamond").attr({
            'class'        : 'port port-blue tooltip'
            'data-name'    : 'instance-sg'
            'data-alias'   : 'instance-sg-left'
            'data-tooltip' : lang.ide.PORT_TIP_D
          })
          svg.use("port_diamond").attr({
            'class'        : 'port port-blue tooltip'
            'data-name'    : 'instance-sg'
            'data-alias'   : 'instance-sg-right'
            'data-tooltip' : lang.ide.PORT_TIP_D
          })
        ]).classes("AWS-AutoScaling-LaunchConfiguration")

        if isOriginalAsg
          svgEl.add([
            # Volume Image
            svg.image( "", 29, 24 ).move(21, 46).classes('volume-image')
            # Volume Label
            svg.text( "" ).move(36, 58).classes('volume-number')
          ])

        @addView( svgEl )

      return

    # Update the svg element
    render : ()->
      m = @model
      # Update label
      CanvasManager.update @$el.children(".node-label"), m.get("name")

      # Update Image
      CanvasManager.update @$el.children(".ami-image"), @iconUrl(), "href"

  }
