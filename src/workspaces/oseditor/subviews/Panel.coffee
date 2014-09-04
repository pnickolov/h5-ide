
define [
    'backbone'
    'constant'
    '../template/TplPanel'
    './panels/ResourcePanel'
    './panels/PropertyPanel'
    './panels/StatePanel'

], ( Backbone, constant, PanelTpl, ResourcePanel, PropertyPanel, StatePanel )->

  Panels = {
    resource: ResourcePanel
    property: PropertyPanel
    state   : StatePanel
  }

  Backbone.View.extend

    events:
        'click .anchor li'       : '__scrollTo'
        'click .sidebar-title a' : '__switchPanel'

    initialize: ( options ) ->
        _.extend this, options
        @render()

    render: () ->
        @setElement @parent.$el.find(".OEPanelRight")

        @$el.html PanelTpl {}
        @renderSubPanel Panels.resource

        @

    renderSubPanel: ( subPanel ) ->
        @$( '.panel-body' ).html new subPanel().render().el

    scrollTo: ( className ) ->
        $container = @$ '.panel-body'
        $target = $( "section.#{className}" )

        top = $container.offset().top
        newTop = $target.offset().top - top + $container.scrollTop()

        $container.animate scrollTop: newTop

    switchPanel: ( panelName ) ->
        targetPanel = Panels[ panelName ]
        unless targetPanel then return

        @$el.removeClass( 'hide' )
        isCurrentPanel = @$el.hasClass panelName
        if isCurrentPanel then return

        @$el.prop 'class', "OEPanelRight #{panelName}"
        @renderSubPanel targetPanel

    __switchPanel: ( e ) ->
        targetPanelName = $( e.currentTarget ).prop 'class'
        @switchPanel targetPanelName



    __scrollTo: ( e ) ->
        targetClassName = $( e.currentTarget ).data 'scrollTo'
        @scrollTo targetClassName