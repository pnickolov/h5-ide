
define [ "./subviews/WorkspaceView", "underscore" ], ( WorkspaceView )->

  class WorkspaceManager

    constructor : ()->
      @view = new WorkspaceView()

      self = @
      @view.on "orderChanged", (order)-> self.__updateOrder(order)
      @view.on "click",        (id)-> self.awakeWorkspace( id )
      @view.on "close",        (id)-> self.remove( id )

      @__spaces     = []
      @__spacesById = {}
      @__awakeSpace = null

      return @

    __updateOrder : (order)->
      self = @
      @__spaces = order.map (id)-> self.__spacesById[id]
      return

    spaces : ()-> @__spaces.slice 0

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
      if not workspace then return

      if _.isString(workspace) then workspace = @__spacesById[workspace]

      if @__awakeSpace then @__awakeSpace.sleep()

      @__awakeSpace = workspace

      @view.activateTab( workspace.id )

      promise = workspace.awake()
      if promise and promise.then and promise.isFulfilled and not promise.isFulfilled()
        promise.then ()=> @view.hideLoading()
        @view.showLoading()
      else
        @view.hideLoading()
      return

    update : ( workspace )->
      if not workspace then return

      @view.updateTab workspace.id, workspace.title(), workspace.tabClass()
      workspace

    remove: ( workspace, force )->
      if not workspace then return

      if _.isString(workspace) then workspace = @__spacesById[workspace]

      if not force and not workspace.isRemovable()
        return

      id = workspace.id

      @view.removeTab( id )
      delete @__spacesById[id]
      @__spaces.splice (@__spaces.indexOf workspace), 1

      if @__awakeSpace is workspace
        @__awakeSpace = null
        @awakeWorkspace( @__spaces[ @__spaces.length - 1 ] )

      workspace.cleanup()

      workspace

    find : ( attribute )-> _.find @__spaces, ( space )-> space.isWorkingOn( attribute )


  WorkspaceManager
