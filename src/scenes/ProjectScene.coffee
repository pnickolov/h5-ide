

define ["Scene", "./ProjectView", "./ProjectTpl", "Workspace", "UI.modalplus", "i18n!/nls/lang.js", "UI.notification"], ( Scene, ProjectView, ProjectTpl, Workspace, Modal, lang )->

  SwitchConfirmView = Backbone.View.extend {
    events :
      "click .do-switch" : "switch"

    initialize : ( attr )->
      this.toOpenProject  = attr.project
      this.toOpenOpsModel = attr.opsmodel

      @modal = new Modal {
        template      : ProjectTpl.switchConfirm()
        title         : lang.IDE.SWITCH_WORKSPACE_UNSAVED_CHANGES
        disableClose  : true
        disableFooter : true
        width         : "500px"
      }
      @setElement @modal.tpl

    switch : ()->
      (new ProjectScene(@toOpenProject, @toOpenOpsModel, {slient:true})).activate()
      @modal.close()
      return
  }

  # The ProjectScene work with Workspace objects. It's a Workspace Manager itself.

  FIRST_PROJECT_NOT_LOADED = true

  class ProjectScene extends Scene

    type : "ProjectScene"

    constructor : ( projectId, opsmodelId, options )->
      ss = App.sceneManager.find( projectId )

      if ss
        ss.activate()
        ss.loadSpace( opsmodelId )
        return ss

      options = options || {}
      # Before we can create a new project scene. We need to unload the project
      # scene that is currently being used. If it has modified workspace, we
      # need the user to confirm.
      if not options.slient
        if _.some App.sceneManager.scenes(), ((s)-> s.type is "ProjectScene" && !s.isRemovable())

          # Once we decide not to launch the new project scene immediately, we should
          # revert the url to the activated scene.
          App.sceneManager.activeScene().updateUrl()

          # Prompt a dialog to ask for confirmation.
          new SwitchConfirmView({ project:projectId, opsmodel:opsmodelId })
          return

      # When we decide to create the project scene, we need to remove any other other project scenes.
      # 1. Find all the project scenes ( Notice that, it should be exactly one project scene at a time )
      scenes = App.sceneManager.scenes().filter (m)-> m.type is "ProjectScene"
      # 2. Unload all the workspaces of the scenes ( The whole system is built with shit fundamentally at the very beginning, and we refactored that shit to become a real piece of software. By refactoring, there's limitation of the current system that there can be only one editor at a time. It means if we would want to create a new scene while other scenes exist, those existing scene should close their editors. )
      scene.removeNotFixedSpaces() for scene in scenes
      # 3. Create the new project scene to switch to, before we close other project scenes. ( SceneManager will try to load a default scene if the last scene is being closed. Thus we should first create the scene that we want )
      Scene.call this, { pid : projectId, opsid : opsmodelId }
      # 4. Remove all other project scenes
      scene.remove() for scene in scenes

      return this

    initialize : ( attr )->
      self = @
      @__spaces     = []
      @__awakeSpace = null
      @__spacesById = {}

      if FIRST_PROJECT_NOT_LOADED
        FIRST_PROJECT_NOT_LOADED = false
        if not attr.pid or not App.model.projects().get( attr.pid )
          attr.pid = localStorage.getItem( "lastws" )

      @project = App.model.projects().get( attr.pid ) || App.model.getPrivateProject()
      @view    = new ProjectView { scene : @ }
      @listenTo @view, "wsOrderChanged", ()->   @__updateSpaceOrder()
      @listenTo @view, "wsClicked",      (id)-> @awakeSpace( id )
      @listenTo @view, "wsClosed",       (id)-> @removeSpace( id )

      @listenTo @project, "destroy", @onProjectDestroy

      @activate()
      self.loadDashboard()
      self.loadSpace( attr.opsid )
      return

    becomeActive : ()->
      @view.$el.show()
      @updateUrl()
      @updateTitle()

      localStorage.setItem( "lastws", @project.id )

      # # Remove all other projects
      # for s in App.sceneManager.scenes()
      #   if s.type is "ProjectScene" and s is @
      #     s.remove()
      # return

    isRemovable    : ()-> _.all @__spaces, ( ws )-> !ws.isModified()
    becomeInactive : ()-> Scene.prototype.becomeInactive.call this
    cleanup        : ()-> Scene.prototype.cleanup.call this

    isWorkingOn : ( projectId )-> @project.id is projectId

    title : ()->
      name = @project.get("name")
      if @getAwakeSpace()
        name = @getAwakeSpace().title() + " on " + name
      name

    url   : ()->
      basic = @project.url() + "/"
      if @getAwakeSpace()
        basic += @getAwakeSpace().url()

      basic.replace /\/+$/, ""

    onProjectDestroy : ( p, c, options )->
      if not options.manualAction
        notification "error", sprintf(lang.NOTIFY.INFO_PROJECT_REMOVED, p.get("name"))
      @remove()
      return

    ### -------------------------------
    # Funtions to manage the workspaces.
    ------------------------ ###
    # Load a workspace to work with the specified opsmodel.
    loadSpace : ( opsModelOrId )->
      if not opsModelOrId
        return @loadDashboard()

      attr = {
        opsModel : if _.isString(opsModelOrId) then @project.getOpsModel(opsModelOrId) else opsModelOrId
      }

      if not attr.opsModel then return

      @createSpace(attr)?.activate()
      return

    loadDashboard : ()->
      console.assert(Workspace.findSuitableSpace({type:"Dashboard"}), "Dashboard is not found.")
      @createSpace({type:"Dashboard"}).activate()

    createSpace : ( data )->
      existing = @findSpace(data)
      if existing then return existing

      SpaceClass = Workspace.findSuitableSpace( data )
      if not SpaceClass
        console.warn( "Cannot find suitable workspace to work with the data", data )
        return null

      new SpaceClass( data, {scene:@} )

    spaceParentElement : ()-> @view.$wsparent

    __updateSpaceOrder : ()->
      dict = @__spacesById
      @__spaces = @view.spaceOrder().map (id)-> dict[id]
      return

    updateSpace : ( workspace )->
      if workspace is @__awakeSpace
        @updateUrl()
        @updateTitle()

      @view.updateSpace workspace.id, workspace.title(), workspace.tabClass()
      workspace

    # Returns all the spaces that is within current scene
    spaces : ()-> @__spaces.slice(0)

    getAwakeSpace : ()-> @__awakeSpace
    getSpace      : ( spaceId )-> @__spacesById[ spaceId ]
    findSpace     : ( attribute )-> _.find @__spaces, ( space )-> space.isWorkingOn( attribute )

    moveSpace : ( workspace, idx )->
      @view.moveSpace workspace.id, workspace.isFixed(), idx
      @__updateSpaceOrder()
      return

    # This method is only used by Workspace.
    addSpace : ( workspace )->
      if @__spacesById[ workspace.id ] then return

      @__spacesById[ workspace.id ] = workspace

      @view.addSpace {
        title    : workspace.title()
        id       : workspace.id
        closable : not workspace.isFixed()
        klass    : workspace.tabClass()
      }, -1, workspace.isFixed()

      @__updateSpaceOrder()

      if @__spaces.length is 1
        @awakeSpace( workspace )

      workspace

    awakeSpace : ( workspace )->
      if not workspace then return

      if _.isString(workspace) then workspace = @__spacesById[workspace]

      if @__awakeSpace is workspace then return

      if workspace.isRemoved() then return

      if @__awakeSpace then @__awakeSpace.sleep()

      @__awakeSpace = workspace

      @updateTitle()
      @updateUrl()

      @view.awakeSpace( workspace.id )

      promise = workspace.awake()
      if promise and promise.then and promise.isFulfilled and not promise.isFulfilled()
        promise.then ()=> @view.hideLoading()
        @view.showLoading()
      else
        @view.hideLoading()
      return

    removeSpace : ( workspace, force )->
      if not workspace then return

      if _.isString(workspace) then workspace = @__spacesById[workspace]

      if not force and not workspace.isRemovable() then return

      if workspace.__isRemoved then return
      workspace.__isRemoved = true

      id = workspace.id

      @view.removeSpace( id )
      delete @__spacesById[id]
      @__spaces.splice (@__spaces.indexOf workspace), 1

      workspace.stopListening()
      workspace.cleanup()

      if @__awakeSpace is workspace
        @__awakeSpace = null
        @awakeSpace( @__spaces[ @__spaces.length - 1 ] )

      workspace

    removeAllSpaces : ()->
      for space in @spaces()
        @removeSpace( space, true )
      return

    removeNotFixedSpaces : ( filter )->
      for space in @spaces()
        if not space.isFixed() and ( not filter or filter(space) )
          @removeSpace( space, true )
      return

  Scene.SetDefaultScene ProjectScene

  ProjectScene

