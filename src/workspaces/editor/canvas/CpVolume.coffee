
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
          data.push {
            id       : volume.get("id")
            name     : volume.get("name")
            size     : volume.get("volumeSize")
            snapshot : volume.get("snapshotId")
          }

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

    remove : ()->
      @canvas.selectVolume( null )
      CanvasPopup.prototype.remove.call this
      return
  }
