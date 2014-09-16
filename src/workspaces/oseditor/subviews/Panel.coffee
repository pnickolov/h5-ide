
define [
    'backbone'
    'constant'
    '../template/TplPanel'
    './panels/ResourcePanel'
    './panels/ConfigPanel'
    './panels/PropertyPanel'
    './panels/StatePanel'

], ( Backbone, constant, PanelTpl, ResourcePanel, ConfigPanel, PropertyPanel, StatePanel )->

  Panels = {
    resource : ResourcePanel
    config   : ConfigPanel
    property : PropertyPanel
    state    : StatePanel
  }

  __defaultArgs = { uid: '', type: 'default' }
  __openArgs = __defaultArgs
  __currentPanel = 'resource'

  Backbone.View.extend

    events:
        'click .anchor li'       : '__scrollTo'

    initialize: ( options ) ->
        window.Panel = @
        _.extend @, options
        @render()

    render: () ->
        @setElement @parent.$el.find(".OEPanelRight")

        @$el.html PanelTpl {}
        @open 'resource'

        @

    renderSubPanel: ( subPanel, args ) ->
        args = _.extend { workspace: @workspace, panel: @ }, args
        $(document.activeElement).filter("input, textarea").blur()
        @$( '.panel-body' ).html new subPanel( args ).render().el

    scrollTo: ( className ) ->
        $container = @$ '.panel-body'
        $target = $( "section.#{className}" )

        top = $container.offset().top
        newTop = $target.offset().top - top + $container.scrollTop()

        $container.animate scrollTop: newTop

    open: ( panelName, args = __openArgs ) ->
        __openArgs = args
        __currentPanel = panelName

        targetPanel = Panels[ panelName ]
        unless targetPanel then return
        if @hidden() then return

        @$el.removeClass( 'hide' )
        @hideFloatPanel()

        @$el.prop 'class', "OEPanelRight #{panelName}"
        $('.sidebar-title').prop 'class', "sidebar-title #{panelName}"
        @renderSubPanel targetPanel, args

    showFloatPanel: ( dom, data ) ->
        @$( '.panel-float' ).html dom if dom
        @$( '.panel-float' ).removeClass 'hidden'

    hideFloatPanel: () -> @$( '.panel-float' ).addClass 'hidden'

    show: ->
        @$el.removeClass 'hidden'
        @

    hide: ->
        @$el.addClass 'hidden'
        $('.sidebar-title').prop 'class', 'sidebar-title'
        @

    shown: -> not @$el.hasClass( 'hidden' )
    hidden: -> not @shown()

    openResource: ( args ) -> @open 'property', args
    openProperty: ( args ) -> @open 'property', args
    openState   : ( args ) -> @open 'state', args
    openCurrent : ( args ) -> @open __currentPanel, args
    openConfig  : ( args ) ->
        @open 'config', args
        __openArgs = __defaultArgs


    __openOrHidePanel: ( e ) ->
        targetPanelName = $( e.currentTarget ).prop 'class'
        if __currentPanel is targetPanelName and @shown()
            @hide()
        else
            @show()
            @open targetPanelName, __openArgs

    __scrollTo: ( e ) ->
        targetClassName = $( e.currentTarget ).data 'scrollTo'
        @scrollTo targetClassName
