
define [ "./CanvasPopup", "./TplPopup", "event", "constant" ], ( CanvasPopup, TplPopup, ide_event, constant )->

  CanvasPopup.extend {

    type       : "InstancePopup" # Only one popup of each type allowed.
    attachType : "overlay" # "float" || "overlay"
    className  : "canvas-pp instance"

    events :
      "click .instance-pph-close" : "remove"

    content : ()->
      data =
        name  : @host.get("name")
        items : []

      TplPopup.instance data

    clickVolume : ( evt )->
      $vol = $( evt.currentTarget )
      volId = $vol.attr("data-id")
      @canvas.selectVolume( volId )

      if @selected
        $( @selected ).removeClass("selected")

      @selected = evt.currentTarget

      ide_event.trigger ide_event.OPEN_PROPERTY, constant.RESTYPE.VOL, $vol.addClass("selected").attr("data-id")

      if evt.which is 1
        $vol.dnd( evt, {
          dropTargets  : @canvas.$el
          dataTransfer : { id : volId }
          eventPrefix  : "addVol_"
        })

      false
  }
