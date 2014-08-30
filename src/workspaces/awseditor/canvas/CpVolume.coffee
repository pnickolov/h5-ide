
define [ "CanvasPopup", "./TplPopup", "event", "constant", "CloudResources" ], ( CanvasPopup, TplPopup, ide_event, constant, CloudResources )->

  CanvasPopup.extend {

    type : "VolumePopup" # Only one popup of each type allowed.
    events :
      "mousedown li" : "clickVolume"

    closeOnBlur : true

    initialize : ()->
      CanvasPopup.prototype.initialize.apply this, arguments

      if @host
        @listenTo @host, "change:volumeList", @render

      # Watch Changes of volume name
      data = @models || []
      if data[0] and data[0].get
        for volume in @models
          @listenTo volume, "change:name", @updateVolume
          @listenTo volume, "change:volumeSize", @updateVolume

      if @selectAtBegin
        @clickVolume { currentTarget : @$el.find('[data-id=' + @selectAtBegin.id + ']')[0] }
      return

    migrate : ( oldPopup )->
      id = oldPopup.$el.find(".selected").attr("data-id")
      @$el.find('[data-id="' + id + '"]').addClass("selected")
      return

    updateVolume : ( volume )->
      $vol = @$el.find('[data-id=' + volume.id + ']')
      $vol.children(".vpp-name").text( volume.get("name") )
      $vol.children(".vpp-size").text( volume.get("volumeSize") + "GB" )
      return

    content : ()->
      data = @models || []

      if data[0] and data[0].get
        data = []
        for volume in @models
          appId = volume.get("appId")

          data.push {
            id       : volume.get("id")
            appId    : appId
            name     : volume.get("name")
            size     : volume.get("volumeSize")
            snapshot : volume.get("snapshotId")
          }

          if appId
            appData = CloudResources( volume.type, volume.design().region() ).get appId
            _.last( data ).state = appData?.get('state') or 'unknown'


      TplPopup.volume data

    clickVolume : ( evt )->
      $vol = $( evt.currentTarget ).addClass("selected")
      volId = $vol.attr("data-id")
      @canvas.selectVolume( volId )

      if @selected
        $( @selected ).removeClass("selected")

      @selected = evt.currentTarget

      ide_event.trigger ide_event.OPEN_PROPERTY, constant.RESTYPE.VOL, volId

      if not @canvas.design.modeIsApp() and evt.which is 1
        $vol.dnd( evt, {
          dropTargets  : @canvas.$el
          dataTransfer : { id : volId }
          eventPrefix  : "addVol_"
        })

      false

    remove : ()->
      @canvas.selectVolume( null )
      CanvasPopup.prototype.remove.call this
      return
  }
