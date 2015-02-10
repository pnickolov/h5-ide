

define [ "ApiRequest", "Scene", "i18n!/nls/lang.js", "backbone", "UI.notification" ], ( ApiRequest, Scene, lang )->

  SSView = Backbone.View.extend {
    initialize : ()-> @setElement $("<div class='global-loading'></div>").appendTo("#scenes")
  }


  class StackStore extends Scene

    constructor : ( attr )->
      ss = App.sceneManager.find( attr.id )
      if ss
        ss.activate()
        return ss

      return Scene.call this, attr

    ###
      Methods that should be override
    ###
    # Override this method to perform custom initialization
    initialize : ( attributes )->
      @id = attributes.id
      @view = new SSView()

      @activate()

      self = @
      ApiRequest('stackstore_fetch_stackstore', { sub_path: "master/stack/#{@id}/#{@id}.json" }).then ( res ) ->
        try
          j = JSON.parse( res )
          delete j.id
          delete j.signature
        catch e
          j = null
          self.onParseError()

        if j then self.onParseSuccess( j )
      , ()->
        self.onLoadError()

    title : ()-> "Fetching Sample Stack"
    url   : ()-> "store/#{@id}"
    isWorkingOn : ( info )-> info is @id

    onParseSuccess : ( j )->
      App.loadUrl( App.model.getPrivateProject().createStackByJson( j ).url() )
      @remove()

    onLoadError : ()->
      notification "error", lang.NOTIFY.LOAD_SAMPLE_FAIL
      @remove()

    onParseError : ()->
      notification "error", lang.NOTIFY.PARSE_SAMPLE_FAIL
      @remove()
