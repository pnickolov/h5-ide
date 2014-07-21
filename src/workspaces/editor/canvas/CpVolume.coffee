
define [ "./CanvasPopup", "./TplPopup", "event", "constant" ], ( CanvasPopup, TplPopup, ide_event, constant )->

  CanvasPopup.extend {

    events :
      "click li" : "showProperty"

    closeOnBlur : true

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
      @$el.find(".selected").removeClass("selected")
      ide_event.trigger ide_event.OPEN_PROPERTY, constant.RESTYPE.VOL, $( evt.currentTarget ).addClass("selected").attr("data-id")

      false

  }
