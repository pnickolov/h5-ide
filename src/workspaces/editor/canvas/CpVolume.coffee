
define [ "./CanvasPopup", "./TplPopup", "event", "constant" ], ( CanvasPopup, TplPopup, ide_event, constant )->

  CanvasPopup.extend {

    type : "VolumePopup" # Only one popup of each type allowed.
    events :
      "mousedown li" : "clickVolume"

    closeOnBlur : true

    initialize : ()->
      CanvasPopup.prototype.initialize.apply this, arguments

      if @host
        @listenTo @host, "change:volumeList", @render
      return

    content : ()->
      if @models[0] and @models[0].get
        data = []
        for volume in @models || []
          data.push {
            id       : volume.get("id")
            name     : volume.get("name")
            size     : volume.get("volumeSize")
            snapshot : volume.get("snapshotId")
          }
      else
        data = @models

      TplPopup.volume data

    clickVolume : ( evt )->
      $vol = $( evt.currentTarget ).addClass("selected")
      volId = $vol.attr("data-id")
      @canvas.selectVolume( volId )

      if @selected
        $( @selected ).removeClass("selected")

      @selected = evt.currentTarget

      ide_event.trigger ide_event.OPEN_PROPERTY, constant.RESTYPE.VOL, volId

      if evt.which is 1
        $vol.dnd( evt, {
          dropTargets  : @canvas.$el
          dataTransfer : { id : volId }
          eventPrefix  : "addVol_"
        })

      false
  }
