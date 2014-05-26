
define [ "./subviews/WorkspaceView" ], ( WorkspaceView )->

  class WorkspaceManager

    constructor : ()->
      @view = new WorkspaceView()

      @__spaces     = []
      @__spacesById = {}
      @

    spaces : ()-> @__spaces.splice 0

    get : ( id )-> @__spacesById[ id ]

    add : ( workspace )->
      @__spacesById[ workspace.id ] = workspace
      @__spaces.push workspace

      @view.addTab {
        title    : workspace.title()
        id       : workspace.id
        closable : not workspace.isFixed()
        klass    : workspace.tabClass()
      }, -1, workspace.isFixed()

      if @__spaces.length is 1
        @awakeWorkspace( workspace )

      workspace

    awakeWorkspace : ( workspace )->
      workspace.awake()
      @view.activateTab( workspace.id )
      return

    update : ( workspace )->
      @view.updateTab workspace.id, workspace.title(), workspace.tabClass()
      workspace

    remove: ( id, force )->
      if not force and not @__spacesById[ id ].isRemovable()
        return

      @view.removeTab( id )
      space = @__spacesById[id]
      delete @__spacesById[id]
      @__spaces.splice (@__spaces.indexOf space), 1

      space


  WorkspaceManager
