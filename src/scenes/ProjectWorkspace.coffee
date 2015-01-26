
# A Workspace is typically a tab.
# Inherit from this class to create custom tabs.

define ["backbone"], ()->

  wsid = 0

  SubWorkspaces = []

  Workspace = Backbone.Model.extend {

    constructor : ( attr, option )->

      console.assert option and option.scene

      attr    = attr || {}
      attr.id = "space_" + (++wsid)

      @scene = option.scene

      Backbone.Model.apply this, arguments

      @scene.addSpace( @ )
      return

    # Returns the index of current tab.
    isAwake : ()-> @scene.getAwakeSpace() is this
    # Set the index of the current tab.
    setIndex : ( idx )-> @scene.moveSpace @, idx
    index : ()-> @scene.spaces().indexOf @

    # Call this method to remove the workspace from the ide.
    isRemoved : ()-> !!@__isRemoved
    remove : ()->
      if @__isRemoved then return
      @__isRemoved = true
      @scene.remove(@, true)

    # Call this method when the url has been changed.
    updateUrl : ()-> @scene.updateSpace( @ )
    # Call this method to update the tab's data.
    updateTab : ()-> @scene.updateSpace @
    # Call this method to activate/awake the workspace
    activate : ()-> @scene.awakeSpace @




    ###
      Methods that should be override
    ###
    # Override this method to perform custom initialization
    initialize : ( attributes )->

    # Override this method to tell the ide if the tab should be fixed.
    isFixed : ()-> false

    # Override this method to tell the ide that this tab is un-saved.
    isModified : ()-> false

    # Override this method to return a class string that can be use to decorate the tab.
    tabClass : ()-> ""

    # Returns a string to show as the tab's title
    title : ()-> ""

    # This method will be called when the tab is switched to.
    # If this method returns a promise, WorkspaceManager will show a loading until
    # the promise is resolved.
    awake : ()-> if @view then @view.$el.show()

    # This method will be called when the tab is switched to something else.
    sleep : ()->
      # Blur any focused input
      # Better than $("input:focus")
      $(document.activeElement).filter("input, textarea").blur()
      if @view then @view.$el.hide()

    # This method will be called when the workspace is remove. One should override this method
    # to do necessary cleanup.
    cleanup : ()->
      if @view
        @view.remove()
      else
        console.warn( "Cannot find @view when workspace is about to remove:", @ )
      return

    # Override this method to check if the tab is closable. Return false to prevent closing.
    isRemovable : ()-> true

    # Override this method so that we can locate a particular workspace.
    # The attribute can be anything
    isWorkingOn : ( attributes )-> false

  }, {

    findSuitableSpace : ( data )->
      for Space in SubWorkspaces
        if Space.canHandle( data )
          return Space

      null

    # This method is used to find out which workspace to be create for a particular piece of data.
    canHandle : ( data )-> false

    extend : ( protoProps, staticProps ) ->

      # Create subclass
      subClass = (window.__detailExtend || Backbone.Model.extend).call( this, protoProps, staticProps )

      SubWorkspaces.push subClass

      subClass

  }

  Workspace
