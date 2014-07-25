
define [ "./CpInstance", "./TplPopup", "event", "constant", "CloudResources" ], ( InstancePopup, TplPopup, ide_event, constant, CloudResources )->

  InstancePopup.extend {
    content : ()->
      TplPopup.eni {
        name  : @host.get("name")
        items : @models || []
      }
  }
