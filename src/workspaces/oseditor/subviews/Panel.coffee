
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

  Backbone.View.extend

    events:
        'click .anchor li'       : '__scrollTo'
        'click .sidebar-title a' : '__openPanel'

    initialize: ( options ) ->
        _.extend this, options
        @render()

    render: () ->
        @setElement @parent.$el.find(".OEPanelRight")

        @$el.html PanelTpl {}
        @openPanel 'resource'

        @

    renderSubPanel: ( subPanel ) ->
        @$( '.panel-body' ).html new subPanel().render().el

    scrollTo: ( className ) ->
        $container = @$ '.panel-body'
        $target = $( "section.#{className}" )

        top = $container.offset().top
        newTop = $target.offset().top - top + $container.scrollTop()

        $container.animate scrollTop: newTop

    openPanel: ( panelName ) ->
        targetPanel = Panels[ panelName ]
        unless targetPanel then return

        @$el.removeClass( 'hide' )
        isCurrentPanel = @$el.hasClass panelName
        if isCurrentPanel then return

        @$el.prop 'class', "OEPanelRight #{panelName}"
        @renderSubPanel targetPanel

    __openPanel: ( e ) ->
        targetPanelName = $( e.currentTarget ).prop 'class'
        @openPanel targetPanelName

    __scrollTo: ( e ) ->
        targetClassName = $( e.currentTarget ).data 'scrollTo'
        @scrollTo targetClassName