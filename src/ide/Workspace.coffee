
# A Workspace is typically a tab.
# Inherit from this class to create custom tabs.

define ["backbone"], ()->

  class Workspace

    constructor : ( attributes )->
      # Find out if there's any workspace already working on this data.
      for ws in App.workspaces.spaces()
        if ws instanceof this.constructor and ws.isWorkingOn( attributes )
          console.info "Found a workspace that is working on, ", attributes, ws
          return ws

      @id = "space_" + _.uniqueId()
      @initialize attributes
      App.workspaces.add @

      return @

    isAwake : ()-> !!@__awake

    # Returns the index of current tab.
    index : ()-> App.workspaces.spaces().indexOf @

    # Set the index of the current tab.
    setIndex : ( idx )-> App.workspaces.setIndex @, idx

    # Call this method to remove the workspace from the ide.
    remove : ()-> App.workspaces.remove(@, true)

    # Call this method to update the tab's data.
    updateTab : ()-> App.workspaces.update @

    # Call this method to activate/awake the workspace
    activate : ()-> App.workspaces.awakeWorkspace @

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
    sleep : ()-> if @view then @view.$el.hide()

    # This method will be called when the workspace is remove. One should override this method
    # to do necessary cleanup.
    cleanup : ()-> if @view then @view.remove()

    # Override this method to check if the tab is closable. Return false to prevent closing.
    isRemovable : ()-> true

    # Override this method so that we can locate a particular workspace.
    # The attributes should be the same as the initialize(), but can also be anything.
    isWorkingOn : ( attributes )-> false

  _.extend Workspace.prototype, Backbone.Events

  Workspace
