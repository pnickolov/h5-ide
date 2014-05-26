
# A Workspace is typically a tab.
# Inherit from this class to create custom tabs.

define ["backbone"], ()->

  class Workspace

    constructor : ( attributes )->
      @id = "space_" + _.uniqueId()
      @initialize attributes
      App.workspaces.add @
      @

    isAwake : ()-> !!@__awake

    # Returns the index of current tab.
    index : ()->

    # Set the index of the current tab.
    setIndex : ( idx )->

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

    # Override this method to return a class string that can be use to decorate the tab.
    tabClass : ()-> ""

    # Returns a string to show as the tab's title
    title : ()-> ""

    # This method will be called when the tab is switched to.
    # If this method returns a promise, WorkspaceManager will show a loading until
    # the promise is resolved.
    awake : ()-> console.info "awake", this

    # This method will be called when the tab is switched to something else.
    sleep : ()-> console.info "sleep", this

    # Override this method to check if the tab is closable. Return false to prevent closing.
    isRemovable : ()-> true

  _.extend Workspace.prototype, Backbone.Events

  Workspace
