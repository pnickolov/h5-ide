#############################
#  View(UI logic) for design/property/cgw
#############################

define [ '../base/view', './template/stack' ], ( PropertyView, template ) ->

  StaticSubView = PropertyView.extend {
    events :
      "click #changeAmi"        : "showChangeAmiPanel"
      "click #confirmChangeAmi" : "changeAmi"
      "click #cancelChangeAmi"  : "hideChangeAmiPanel"

    render : () ->
        @$el.html template @model.attributes
        @model.attributes.name

        self = @
        $("#changeAmiDropZone").on "addItem_drop", ( evt, data )-> self.onDropAmi( data )
        return

    showChangeAmiPanel : ()->
      $("#changeAmiPanel").show().siblings(".property-ami-info").hide()
      $("#changeAmiDropZone").children().hide().filter("p").show()
      $("#confirmChangeAmiWrap").hide()
      null

    hideChangeAmiPanel : ()->
      $("#changeAmiPanel").hide().siblings(".property-ami-info").show()
      null

    onDropAmi : ( data )->
      amiId = data.dataTransfer.imageId
      if not amiId then return

      $("#changeAmiPanel").data("amiId", amiId)
      $("#confirmChangeAmiWrap").show()

      canChangeAmi = @model.canChangeAmi( amiId )
      if canChangeAmi is true
        $("#changeAmiWarning").hide()
        $("#confirmChangeAmi").show()
      else
        $("#changeAmiWarning").html(canChangeAmi).show()
        $("#confirmChangeAmi").hide()

      $("#changeAmiDropZone").children().show().filter("p").hide()
      $("#changeAmiDropZone").find("img").attr("src", "/assets/images/ide/ami/" + @model.getAmiPngName( amiId ) + ".png")
      $("#changeAmiDropZone").find(".resource-label").html( @model.getAmiName(amiId) )
      null

    changeAmi : ()->
      amiId = $("#changeAmiPanel").data("amiId")
      @model.changeAmi( amiId )

      @trigger "AMI_CHANGE"
      null
  }

  new StaticSubView()
