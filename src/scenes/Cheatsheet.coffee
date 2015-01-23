

define ["./CheatsheetTpl", "Scene", "i18n!/nls/lang.js" ], ( CheatsheetTpl, Scene, lang )->

  CSView = Backbone.View.extend {

    events :
      "click"                    : "clickBg"
      "click .icon-close-circle" : "clickBtn"

    initialize : ()-> @setElement $(CheatsheetTpl()).appendTo("#scenes")

    clickBg : ( evt )->
      if $( evt.target ).hasClass("cheatsheet")
        @trigger "close"
      return

    clickBtn : ()-> @trigger "close"
  }


  class Cheatsheet extends Scene

    # The cheatsheet never activate itself.
    constructor : ( attr )->
      ss = App.sceneManager.find( "Cheatsheet" )
      if ss then return ss
      return Scene.call this, attr

    initialize : ()->
      @view = new CSView()
      @listenTo @view, "close", @remove
      return

    url   : ()-> "/cheatsheet"
    isWorkingOn : ( info )-> info is "Cheatsheet"

    cleanup : ()->
      Scene.prototype.cleanup.call this
      # This is a hack to allow Cheetsheet to be overlay
      # Once the cheetsheet is removed, we should update the url, since the current activated
      # scene haven't changed.
      App.sceneManager.activeScene().updateUrl()
      return
