#############################
#  View(UI logic) for design/property/cgw
#############################

define [ '../base/view', './template/stack' ], ( PropertyView, template ) ->

  StaticSubView = PropertyView.extend {
    events :
      "click #changeAmi"         : "showChangeAmiPanel"
      "click #confirmChangeAmi"  : "changeAmi"
      "click #cancelChangeAmi"   : "hideChangeAmiPanel"
      "drop  #changeAmiDropZone" : "onDropAmi"

    render : () ->
        @$el.html template @model.attributes
        @model.attributes.name

    showChangeAmiPanel : ()->
      $("#changeAmiPanel").show().siblings(".property-ami-info").hide()
      $("#changeAmiDropZone").children().hide().filter("p").show()
      $("#confirmChangeAmiWrap").hide()
      null

    hideChangeAmiPanel : ()->
      $("#changeAmiPanel").hide().siblings(".property-ami-info").show()
      null

    onDropAmi : ( event, amiId )->
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
      $("#changeAmiDropZone").find("img").attr("src", "./assets/images/ide/ami/" + @model.getAmiPngName( amiId ) + ".png")
      $("#changeAmiDropZone").find(".resource-label").html( @model.getAmiName(amiId) )
      null

    changeAmi : ()->
      amiId = $("#changeAmiPanel").data("amiId")
      @model.changeAmi( amiId )

      @trigger "AMI_CHANGE"

      # @render()
      # @setTitle @model.get("name")

      # # A hack to update first property
      # firstPropertyAmi = $(".property-details #property-ami")
      # firstPropertyAmi.find(".property-ami-icon").attr("src", "./assets/images/ide/ami/" + @model.getAmiPngName( amiId ) + ".png")
      # firstPropertyAmi.find(".property-ami-label").html( @model.get("name") )

      null
  }

  new StaticSubView()
