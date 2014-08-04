
define [ "./CanvasView", "constant", "i18n!/nls/lang.js", "./CpVolume", "./CanvasManager", "Design" ], ( CanvasView, constant, lang, VolumePopup, CanvasManager, Design )->

  isPointInRect = ( point, rect )->
    rect.x1 <= point.x and rect.y1 <= point.y and rect.x2 >= point.x and rect.y2 >= point.y

  AwsCanvasView = CanvasView.extend {

    events : ()->
      $.extend {
        "addVol_dragover"  : "__addVolDragOver"
        "addVol_dragleave" : "__addVolDragLeave"
        "addVol_drop"      : "__addVolDrop"

      }, CanvasView.prototype.events

    recreateStructure : ()->
      @svg.clear().add([
        @svg.group().classes("layer_vpc")
        @svg.group().classes("layer_az")
        @svg.group().classes("layer_subnet")
        @svg.group().classes("layer_line")
        @svg.group().classes("layer_asg")
        @svg.group().classes("layer_sgline")
        @svg.group().classes("layer_node")
      ])
      return

    appendVpc    : ( svgEl )-> @__appendSvg(svgEl, ".layer_vpc")
    appendAz     : ( svgEl )-> @__appendSvg(svgEl, ".layer_az")
    appendSubnet : ( svgEl )-> @__appendSvg(svgEl, ".layer_subnet")
    appendAsg    : ( svgEl )-> @__appendSvg(svgEl, ".layer_asg")
    appendSgline : ( svgEl )-> @__appendSvg(svgEl, ".layer_sgline")

    fixConnection : ( coord, initiator, target )->
      if target.type is constant.RESTYPE.ELB and ( initiator.type is constant.RESTYPE.INSTANCE or initiator.type is constant.RESTYPE.LC )
        if coord.x < target.pos().x + target.size().width / 2
          toPort = "elb-sg-out"
        else
          toPort = "elb-sg-in"

      else if target.type is constant.RESTYPE.ASG or target.type is "ExpandedAsg"
        target = target.getLc()
        if target then target = @getItem( target.id )

      {
        toPort : toPort
        target : target
      }

    errorMessageForDrop : ( type )->
      switch type
        when constant.RESTYPE.VOL       then return lang.ide.CVS_MSG_WARN_NOTMATCH_VOLUME
        when constant.RESTYPE.SUBNET    then return lang.ide.CVS_MSG_WARN_NOTMATCH_SUBNET
        when constant.RESTYPE.INSTANCE  then return lang.ide.CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET
        when constant.RESTYPE.ENI       then return lang.ide.CVS_MSG_WARN_NOTMATCH_ENI
        when constant.RESTYPE.RT        then return lang.ide.CVS_MSG_WARN_NOTMATCH_RTB
        when constant.RESTYPE.ELB       then return lang.ide.CVS_MSG_WARN_NOTMATCH_ELB
        when constant.RESTYPE.CGW       then return lang.ide.CVS_MSG_WARN_NOTMATCH_CGW
        when constant.RESTYPE.ASG       then return lang.ide.CVS_MSG_WARN_NOTMATCH_ASG
        when constant.RESTYPE.IGW       then return lang.ide.CVS_MSG_WARN_NOTMATCH_IGW
        when constant.RESTYPE.VGW       then return lang.ide.CVS_MSG_WARN_NOTMATCH_VGW
        when constant.RESTYPE.DBSBG      then return lang.ide.CVS_MSG_WARN_NOTMATCH_SGP_VPC
        when constant.RESTYPE.DBINSTANCE then return lang.ide.CVS_MSG_WARN_NOTMATCH_DBINSTANCE_SGP

    selectVolume : ( volumeId )->
      @deselectItem( true )
      @__selectedVolume = volumeId
      false

    isReadOnly : ()-> @design.modeIsApp()

    delSelectedItem : ()->
      if @isReadOnly() then return false

      if @__selectedVolume
        s = @__selectedVolume
        @__selectedVolume = null
        @design.component( s ).remove()
        nextVol = $( ".canvas-pp .popup-volume" ).children().eq(0)
        if nextVol.length
          nextVol.trigger("mousedown")
        else
          @deselectItem()
        return

      CanvasView.prototype.delSelectedItem.apply this, arguments

    __addVolDragOver : ( evt, data )->
      @__scrollOnDrag( data )

      if not data.volDropTargets
        data.hoverItem = null

        RTP     = constant.RESTYPE
        targets = @design.componentsOfType( RTP.INSTANCE ).concat( @design.componentsOfType(RTP.LC) )

        data.volDropTargets = dropzones = []

        for tgt in targets
          tgt = @getItem( tgt.id )

          for el in tgt.$el
            r = tgt.rect( el )
            r.tgt = tgt
            r.el  = el
            dropzones.push r

      if not data.effect
        data.effect = true
        for tgt in data.volDropTargets || []
          CanvasManager.addClass tgt.tgt.$el, "droppable"

      pos = @__localToCanvasCoor(data.pageX - data.zoneDimension.x1, data.pageY - data.zoneDimension.y1)

      hoverItem = null
      for tgt in data.volDropTargets
        if isPointInRect( pos, tgt )
          hoverItem = tgt
          break

      if hoverItem isnt data.hoverItem
        if data.popup then data.popup.remove()

        data.hoverItem = hoverItem
        if hoverItem
          model = hoverItem.tgt.model
          data.popup = new VolumePopup {
            attachment : hoverItem.el
            host       : model
            models     : model.get("volumeList")
            canvas     : @
          }

      return

    __addVolDragLeave : ( evt, data )->
      @__clearDragScroll()

      for tgt in data.volDropTargets || []
        CanvasManager.removeClass tgt.tgt.$el, "droppable"

      data.effect = false

      if data.popup then data.popup.remove()
      return

    __addVolDrop : ( evt, data )->
      if not data.hoverItem then return

      attr = data.dataTransfer || {}

      owner = data.hoverItem.tgt.model

      if attr.id
        # Moving volume
        volume = @design.component( attr.id )
        doable = volume.isReparentable( owner )
        if _.isString( doable )
          return notification "error", doable
        else if doable
          volume.attachTo( owner )
          @selectItem( data.hoverItem.el )
        return

      # Avoid adding volume for existing LC.
      if owner.type is constant.RESTYPE.LC and owner.get("appId")
        notification "error", lang.ide.NOTIFY_MSG_WARN_OPERATE_NOT_SUPPORT_YET
        return

      attr.owner = owner
      if _.isString( attr.encrypted )
        attr.encrypted = attr.encrypted is 'true'

      VolumeModel = Design.modelClassForType( constant.RESTYPE.VOL )
      v = new VolumeModel( attr )

      new VolumePopup {
        attachment    : data.hoverItem.el
        host          : owner
        models        : owner.get("volumeList")
        canvas        : @
        selectAtBegin : v
      }
      return
  }

  AwsCanvasView
