
# A Scene is used to represent the whole window at a time.
# It's best to add the view's dom to "div#scenes"

define ["backbone"], ()->

  sid = 0

  class Scene

    constructor : ()->
      @id = "scene_" + (++sid)
      @initialize.apply @, arguments
      App.sceneManager.add @

      return @

    isActive : ()-> App.sceneManager.activeScene() is @
    isRemoved : ()-> !!@__isRemoved
    # Call this method to remove the scene when the scene is nolonger being used.
    remove : ()->
      if @__isRemoved then return
      @__isRemoved = true
      App.sceneManager.remove(@, true)
      null

    # Call this method to activate the scene
    activate : ()-> App.sceneManager.activate @
    setUrl   : ( url )->   if @isActive() then Router.navigate( @url(), {replace:true} ); return
    setTitle : ( title )-> if @isActive() then document.title = title; return


    ###
      Methods that should be override
    ###
    # Override this method to perform custom initialization
    initialize : ( attributes )-> @activate()

    # Override this method to check if the tab is closable. Return false to prevent closing.
    isRemovable : ()-> true

    # This method will be called when the tab is switched to.
    becomeActive : ()-> if @view then @view.$el.show()

    # This method will be called when the tab is switched to something else.
    becomeInactive : ()->
      # Blur any focused input
      # Better than $("input:focus")
      $(document.activeElement).filter("input, textarea").blur()
      if @view then @view.$el.hide()

    # This method will be called when the scene is remove.
    # One should override this method to do necessary cleanup.
    cleanup : ()->
      @stopListening()

      if @view
        @view.remove()
      else
        console.warn( "Cannot find @view when scene is about to remove:", @ )
      return

    # Override this method so that we can locate a particular scene. The info can be anything.
    isWorkingOn : ( info )-> false

  _.extend Scene.prototype, Backbone.Events

  Scene
