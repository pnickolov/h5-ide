
define [ "./CanvasPopup", "./TplPopup", "event", "constant" ], ( CanvasPopup, TplPopup, ide_event, constant )->

  CanvasPopup.extend {

    type : "VolumePopup" # Only one popup of each type allowed.
    events :
      "click li" : "showProperty"

    closeOnBlur : true

    initialize : ()->
      CanvasPopup.prototype.initialize.apply this, arguments

      if @host
        @listenTo @host, "change:volumeList", @render
      return

    content : ()->
      data = []
      for volume in @models || []
        data.push {
          id       : volume.get("id")
          name     : volume.get("name")
          size     : volume.get("volumeSize")
          snapshot : volume.get("snapshotId")
        }

      TplPopup.volume data

    showProperty : ( evt )->
      $vol = $( evt.currentTarget )
      @canvas.selectVolume( $vol.attr("data-id") )

      if @selected
        $( @selected ).removeClass("selected")

      @selected = evt.currentTarget

      ide_event.trigger ide_event.OPEN_PROPERTY, constant.RESTYPE.VOL, $vol.addClass("selected").attr("data-id")
      false
  }
