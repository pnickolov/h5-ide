
define [
    'backbone'
    'constant'
    'Design'
    'CloudResources'
    '../../property/OsPropertyView'
    '../../property/OsPropertyBundle'
    './template/TplPropertyPanel'
    'UI.selection'
    'ConnectionModel'

], ( Backbone, constant, Design, CloudResources, OsPropertyView, OsPropertyBundle, PropertyPanelTpl, bindSelection, ConnectionModel )->

  Backbone.View.extend

    initialize: ( options ) ->

        region = options.workspace.design.region()
        @options = options
        @uid     = options.uid
        @type    = options.type
        @panel   = options.panel
        @model   = Design.instance().component @uid

        @mode    = options.workspace.design.mode()
        @mode    = 'stack' if @mode is 'appedit' and not @model?.get( 'appId' )

        if @model and @mode in [ 'app', 'appedit' ] and @model?.get( 'appId' )
            @appModel = CloudResources( @type, region )?.get @model?.get( 'appId' )

        @viewClass  = OsPropertyView.getClass( @mode, @type ) or OsPropertyView.getClass( @mode, 'default' )

    resourceInexist: ->
        if @mode is 'stack' then return false
        if @appModel then return false
        if @model?.type is constant.RESTYPE.OSEXTNET then return false
        if @model instanceof ConnectionModel then return false

        true

    render: () ->

        design = @options.workspace.design

        propertyView = @propertyView = new @viewClass({
            model           : @model
            appModel        : @appModel or null
            propertyPanel   : @
            panel           : @panel
            workspace       : @options.workspace
        })

        bindSelection(@$el, propertyView.selectTpl)

        @setTitle()

        if @resourceInexist()
            @$el.append PropertyPanelTpl.empty()
        else
            @$el.append propertyView.render().el

        @panel.parent?.$el.attr('data-mode', @mode)

        @

    setTitle: ( title = @propertyView.getTitle() ) ->
        unless title then return
        $title = @$ 'h1'
        if $title.size()
            $title.eq(0).text title
        else
            @$el.html PropertyPanelTpl.title { title: title }

    showFloatPanel: -> @panel.showFloatPanel.apply @panel, arguments
    hideFloatPanel: -> @panel.hideFloatPanel.apply @panel, arguments

    remove: ->
        @propertyView?.remove()
        Backbone.View.prototype.remove.apply @, arguments
