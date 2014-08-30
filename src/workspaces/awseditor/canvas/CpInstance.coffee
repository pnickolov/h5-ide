
define [ "CanvasPopup", "./TplPopup", "./CpVolume", "event", "constant", "CloudResources" ], ( CanvasPopup, TplPopup, VolumePopup, ide_event, constant, CloudResources )->

  CanvasPopup.extend {

    type       : "InstancePopup" # Only one popup of each type allowed.
    attachType : "overlay" # "float" || "overlay"
    className  : "canvas-pp instance"

    events :
      "click .instance-pph-close" : "remove"
      "click li"                  : "selectItem"
      "click .vpp-ins-vol"        : "showVolume"

    initialize : ()->
      CanvasPopup.prototype.initialize.apply this, arguments
      @selectItem( { currentTarget : @$el.find("li")[0] })
      return

    content : ()->
      TplPopup.instance {
        name  : @host.get("name")
        items : @models || []
      }

    selectItem : ( evt )->
      @canvas.deselectItem( true )

      @$el.find(".selected").removeClass("selected")

      ide_event.trigger ide_event.OPEN_PROPERTY, constant.RESTYPE.INSTANCE, $( evt.currentTarget ).addClass("selected").attr("data-id")
      false

    remove : ()->
      if @volPopup then @volPopup.remove()
      CanvasPopup.prototype.remove.apply this, arguments

    showVolume : ( evt )->
      region = @canvas.design.region()
      $ins = $( evt.currentTarget ).closest(".vpp-instance")
      ins  = CloudResources( constant.RESTYPE.INSTANCE, region ).get( $ins.attr("data-id") )

      if not ins then return

      ins = ins.attributes

      volCln = CloudResources( constant.RESTYPE.VOL, region )

      vols = []
      for bdm in ins.blockDeviceMapping
        if bdm.deviceName isnt ins.rootDeviceName
          volumeId = bdm.ebs?.volumeId
          if not volumeId then continue

          vol = volCln.get(volumeId)
          if not vol then continue

          vols.push {
            id       : vol.id
            appId    : vol.id
            name     : bdm.deviceName
            snapshot : vol.get("snapshotId")
            size     : vol.get("size")
            state    : vol.get('state') or 'unknown'
          }

      @volPopup = new VolumePopup {
        attachment : $ins[0]
        models     : vols
        canvas     : @canvas
      }
      false
  }
