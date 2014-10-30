
define [
    'backbone'
    'constant'
    'Design'
    'CloudResources'
    '../../property/OsPropertyView'
    '../../property/OsPropertyBundle'
    '../../property/validation/ValidationBase'
    '../../property/validation/ValidationBundle'
    './template/TplPropertyPanel'
    'UI.selection'
    'ConnectionModel'


], ( Backbone, constant, Design, CloudResources, OsPropertyView, OsPropertyBundle, ValidationBase, ValidationBundle, PropertyPanelTpl, bindSelection, ConnectionModel )->

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

        if @model then @viewClass = OsPropertyView.getClass( @mode, @type )
        @viewClass ?= OsPropertyView.getClass( @mode, 'default' )

        @validationClass = ValidationBase.getClass( @type )

    resourceInexist: ->
        if @mode is 'stack' then return false
        if @appModel then return false
        if @model instanceof ConnectionModel then return false

        true

    render: () ->

        design = @options.workspace.design
        classOptions =
            model           : @model
            appModel        : @appModel or null
            propertyPanel   : @
            panel           : @panel
            workspace       : @options.workspace

        propertyView = @propertyView = new @viewClass classOptions

        if @validationClass
            validationInstance = new @validationClass classOptions
        else
            validationInstance = null

        bindSelection @$el, propertyView.selectTpl, _.extend view: propertyView, validationInstance
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

        if @propertyView and @propertyView.selectTpl
            bindSelection.unbind @$el, @propertyView.selectTpl
        @propertyView?.remove()
        Backbone.View.prototype.remove.apply @, arguments
