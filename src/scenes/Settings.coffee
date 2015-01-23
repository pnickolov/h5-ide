

define ["Scene", "../ide/settings/SettingsView"], ( Scene, SettingsView )->

  class Settings extends Scene

    ###
      Methods that should be override
    ###
    # Override this method to perform custom initialization
    initialize : ( attributes )->
      @view = new SettingsView( attributes, { scene : @ } )
      @activate()

    # Override this method to check if the tab is closable. Return false to prevent closing.
    isRemovable : ()-> true

    # This method will be called when the tab is switched to.
    becomeActive : ()-> Scene.prototype.becomeActive.call this

    # This method will be called when the tab is switched to something else.
    becomeInactive : ()-> Scene.prototype.remove.call this

    # This method will be called when the scene is remove.
    # One should override this method to do necessary cleanup.
    cleanup : ()-> #Scene.prototype.cleanup.call this

    # Override this method so that we can locate a particular scene. The info can be anything.
    isWorkingOn : ( info )-> info is "AppSettings"
