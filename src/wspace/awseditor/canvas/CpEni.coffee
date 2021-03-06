
define [ "./CpInstance", "./TplPopup", "constant" ], ( InstancePopup, TplPopup, constant )->

  InstancePopup.extend {
    content : ()->
      TplPopup.eni {
        name  : @host.get("name")
        items : @models || []
      }

    selectItem : ( evt )->
      @canvas.deselectItem( true )

      @$el.find(".selected").removeClass("selected")

      @canvas.triggerSelected constant.RESTYPE.ENI, $( evt.currentTarget ).addClass("selected").attr("data-id")
      false
  }
