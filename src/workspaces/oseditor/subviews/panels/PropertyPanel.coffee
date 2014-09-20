
define [
    'backbone'
    'constant'
    'Design'
    'CloudResources'
    '../../property/OsPropertyView'
    '../../property/OsPropertyBundle'
    './template/TplPropertyPanel'
    'UI.selection'
], ( Backbone, constant, Design, CloudResources, OsPropertyView, OsPropertyBundle, PropertyPanelTpl, bindSelection )->

  Backbone.View.extend

    events:

      "click .option-group-head" : "updateRightPanelOption"

    initialize: ( options ) ->
        region = options.workspace.design.region()
        @options = options
        @mode    = Design.instance().mode()
        @uid     = options.uid
        @type    = options.type
        @panel   = options.panel

        @model      = Design.instance().component @uid
        if @model and @mode in [ 'app', 'appedit' ] and @model.get( 'appId' )
            @appModel = CloudResources( @type, region )?.get @model.get( 'appId' )

        @viewClass  = OsPropertyView.getClass( @mode, @type ) or OsPropertyView.getClass( @mode, 'default' )


    render: () ->
        design = @options.workspace.design

        propertyView = @propertyView = new @viewClass({
            model           : @model
            appModel        : @appModel or null
            propertyPanel   : @
            panel           : @panel
            mode            : @mode
            modeIsApp       : design.modeIsApp()
            modeIsAppEdit   : design.modeIsAppEdit()
            modeIsStack     : design.modeIsStack()
        })

        bindSelection(@$el, propertyView.selectTpl)

        @setTitle()
        @$el.append propertyView.render().el

        @restoreAccordion(@model?.type, @uid)
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
        @propertyView.remove()
        Backbone.View.prototype.remove.apply @, arguments

    updateRightPanelOption : ( event ) ->
        $toggle = $(event.currentTarget)

        if $toggle.is("button") or $toggle.is("a") then return

        hide    = $toggle.hasClass("expand")
        $target = $toggle.next()

        if hide
            $target.css("display", "block").slideUp(200)
        else
            $target.slideDown(200)

        $toggle.toggleClass("expand")

        if not $toggle.parents(".panel-body").length then return

        @__optionStates = @__optionStates || {}

        # added by song ######################################
        # record head state
        comp = @uid || "Stack"
        status = _.map @$el.find('.panel-body').find('.option-group-head'), ( el )-> $(el).hasClass("expand")
        @__optionStates[ comp ] = status

        comp = Design.instance().component( comp )
        console.log comp
        if comp then @__optionStates[ comp.type ] = status
        # added by song ######################################

        false

    restoreAccordion : ( type, uid )->
        if not @__optionStates then return
        states = @__optionStates[ uid ]
        if not states then states = @__optionStates[ type ]
        if states
            for el, idx in @$el.find('.panel-body').find('.option-group-head')
                $(el).toggleClass("expand", states[idx])

              for uid, states of @__optionStates
                    if not uid or Design.instance().component( uid ) or uid.indexOf("i-") is 0 or uid is "Stack"
                        continue
                        delete @__optionStates[ uid ]
                        return


