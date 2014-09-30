
define [
    'backbone'
    'constant'
    '../template/TplPanel'
    './panels/ResourcePanel'
    './panels/ConfigPanel'
    './panels/PropertyPanel'
    "StateEditorView"

], ( Backbone, constant, PanelTpl, ResourcePanel, ConfigPanel, PropertyPanel, StatePanel )->

    Panels = {
        resource : ResourcePanel
        config   : ConfigPanel
        property : PropertyPanel
        state    : StatePanel
    }

    __defaultArgs = { uid: '', type: 'default' }

    Backbone.View.extend

        events:
            'click .anchor li'          : '__scrollTo'
            'click .option-group-head'  : '__updateRightPanelOption'

        __openArgs: __defaultArgs
        __currentPanel: 'resource'

        initialize: ( options ) ->
            _.extend @, options

            if @workspace.design.mode() is 'app'
                @__currentPanel = 'config'

            @render()

        render: () ->
            @setElement @parent.$el.find(".OEPanelRight")

            @$el.html PanelTpl {}
            @open @__currentPanel

            @

        renderSubPanel: ( subPanel, args ) ->
            args = _.extend { workspace: @workspace, panel: @ }, args

            $(document.activeElement).filter("input, textarea").blur()

            @subPanel?.remove()
            @subPanel = new subPanel( args )

            @$( '.panel-body' ).html @subPanel.render().el

            @__restoreAccordion()

        scrollTo: ( className ) ->
            $container = @$ '.panel-body'
            $target = $( "section.#{className}" )

            top = $container.offset().top
            newTop = $target.offset().top - top + $container.scrollTop()

            $container.animate scrollTop: newTop

        open: ( panelName, args = @__openArgs ) ->
            lastPanel = @__currentPanel
            lastArgs = _.extend {}, @__openArgs
            @__openArgs = args
            @__currentPanel = panelName

            targetPanel = Panels[ panelName ]
            unless targetPanel then return
            if @hidden() then return

            @$el.removeClass( 'hide' )
            @hideFloatPanel() unless lastPanel is @__currentPanel and _.isEqual( lastArgs, args )

            @$el.prop 'class', "OEPanelRight #{panelName}"
            @$el.closest( '#OpsEditor' ).find( '.sidebar-title' ).prop 'class', "sidebar-title #{panelName}"
            @renderSubPanel targetPanel, args

        floatPanelShowCount: 0

        showFloatPanel: ( dom ) ->
            @floatPanelShowCount++
            @$( '.panel-float' ).html dom if dom
            @$( '.panel-float' ).removeClass 'hidden'

            _.defer () =>
                @$( '.panel-body' ).one 'click', @__hideFloatPanel @floatPanelShowCount

        __hideFloatPanel: ( showCount ) ->
            that = @
            () -> if showCount is that.floatPanelShowCount then that.hideFloatPanel()

        hideFloatPanel: () ->
            @$( '.panel-float' ).addClass 'hidden'

        show: ->
            @$el.removeClass 'hidden'
            @

        hide: ->
            @$el.addClass 'hidden'
            $('.sidebar-title').prop 'class', 'sidebar-title'
            @

        shown: -> not @$el.hasClass( 'hidden' )
        hidden: -> not @shown()

        openResource: ( args ) -> @open 'resource', args
        openState   : ( args ) -> @open 'state', args
        openProperty: ( args ) -> @open 'property', args
        openConfig  : ( args ) ->
            @open 'config', args
            @__openArgs = @__defaultArgs

        openCurrent : ( args ) ->
            if @workspace.design.mode() is 'app' and @__currentPanel is 'resource'
                @__currentPanel = 'config'

            @open @__currentPanel, args


        __openOrHidePanel: ( e ) ->
            targetPanelName = $( e.currentTarget ).prop 'class'
            if @__currentPanel is targetPanelName and @shown()
                @hide()
            else
                @show()
                @open targetPanelName, @__openArgs

        __scrollTo: ( e ) ->
            targetClassName = $( e.currentTarget ).data 'scrollTo'
            @scrollTo targetClassName

        __updateRightPanelOption : ( event ) ->
            $toggle = $ event.currentTarget

            if $toggle.is("button") or $toggle.is("a") then return

            hide    = $toggle.hasClass("expand")
            $target = $toggle.next()

            if hide
                $target.css("display", "block").slideUp(200)
            else
                $target.slideDown(200)

            $toggle.toggleClass("expand")
            @__optionStates ?= {}

            # Record panel body only
            unless $toggle.closest( '.panel-body' ).size() then return
            # Record head state
            key = "#{@__currentPanel}_#{@workspace.design.mode()}_#{@__openArgs?.uid}"
            states = _.map @$el.find('.panel-body').find('.option-group-head'), ( el )-> $(el).hasClass("expand")
            @__optionStates[ key ] = states

            false

        __restoreAccordion : ->
            key = "#{@__currentPanel}_#{@workspace.design.mode()}_#{@__openArgs?.uid}"
            unless states = @__optionStates?[ key ] then return

            @$('.option-group-head').each ( index ) ->
                $(@).toggleClass 'expand', states[ index ]

