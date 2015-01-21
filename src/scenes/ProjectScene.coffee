

define ["Scene", "./ProjectView"], ( Scene, ProjectView )->

  # The ProjectScene work with Workspace objects. It's a Workspace Manager itself.

  class ProjectScene extends Scene

    type : "ProjectScene"

    constructor : ( projectId, opsmodelId )->
      ss = App.sceneManager.find( projectId )

      if ss
        ss.activate()
        ss.loadWorkspace( opsmodelId )
        return ss

      return Scene.call this, { pid : projectId, opsid : opsmodelId }

    initialize : ( attr )->
      @__spaces = []

      @project  = App.model.projects().get( attr.pid ) || App.model.getPrivateProject()
      @view     = new ProjectView { scene : @ }
      @activate()

    becomeActive : ()->
      # # Remove all other projects
      # for s in App.sceneManager.scenes()
      #   if s.type is "ProjectScene" and s is @
      #     s.remove()
      # return

    isRemovable    : ()-> @__spaces.some ( ws )-> ws.isModified()
    becomeInactive : ()-> Scene.prototype.becomeInactive.call this
    cleanup        : ()-> Scene.prototype.cleanup.call this

    isWorkingOn : ( projectId )-> @project.id is projectId



    ### -------------------------------
    # Funtions to manage the workspaces.
    ------------------------ ###

    # Returns all the spaces that is within current scene
    spaces : ()-> @__spaces.slice(0)

    findSpace : ( attribute )-> _.find @__spaces, ( space )-> space.isWorkingOn( attribute )

    removeSpace : ()->


    removeAllSpaces : ()->
      for space in @spaces()
        space.remove( space, true )
      return

    removeNotFixedSpaces : ( filter )->
      for space in @spaces()
        if not space.isFixed() and ( not filter or filter(space) )
          @removeSpace( space, true )
      return

