
####################################
#  Base Class for View of Property Module
####################################

define [ 'constant',
         'i18n!nls/lang.js',
         'backbone',
         'jquery',
         'handlebars',
         'UI.selectbox',
         'UI.notification',
         'UI.multiinputbox'
         'UI.modal',
         'UI.selectbox',
         'MC.validate',
         'UI.parsley',
         'UI.tooltip',
         'UI.sortable',
         'UI.tablist'
], ( constant, lang ) ->

    ###

    -------------------------------
     PropertyView is a base class that every property view should inherit.
    -------------------------------

    ++ Class attributes ( Extra attributes from Backbone.View ) ++

    # model : PropertyModel
        description : This attributes points to the model that is associated with the view.



    ++ Class Protocol ( Should be implemented by user ) ++

    # render :
        description : In this method, user should render its content to `this.$el`. If this method returns a string, it is consider as the title of the property, thus you don't have to call `setTile`.



    ++ Class Method ++
    # forceShow :
        description : Call this method before focusing a input of property panel. This method ensure the property panel is not hidden.

    ###

    PropertyView = Backbone.View.extend {

        setTitle : ( title ) ->
            $( if @_isSub then "#property-second-title" else "#property-title" ).text title
            return

        prependTitle : ( additionalTitle ) ->
            $( if @_isSub then "#property-second-title" else "#property-title" ).prepend additionalTitle
            return

        forceShow : () ->
            $("#OEPanelRight").trigger "FORCE_SHOW"
            null

        disabledAllOperabilityArea : ( disabled ) ->
            if disabled
                if $("#resource-panel").children(".disabled-event-layout").length
                    return
                divTmpl = '<div class="disabled-event-layout"></div>'
                $('#resource-panel').append(divTmpl)
                $('#canvas').append(divTmpl)
                $('#tabbar-wrapper').append(divTmpl)
            else
                $('.disabled-event-layout').remove()

        checkResName : ( $input, type )->
            if not $input.length
                $input = $( $input )

            name = $input.val()

            if not type then type = name

            if name && !MC.validate( 'awsName',  name )
                error = sprintf lang.ide.PARSLEY_THIS_VALUE_SHOULD_BE_A_VALID_TYPE_NAME, type

            if not error and @model.isNameDup( name )
                error = sprintf lang.ide.PARSLEY_TYPE_NAME_CONFLICT, type, name

            if not error and @model.isReservedName( name )
                error = sprintf lang.ide.PARSLEY_TYPE_NAME_CONFLICT, type, name

            if name.indexOf("elbsg-") is 0
                error = lang.ide.PARSLEY_RESOURCE_NAME_ELBSG_RESERVED

            $input.parsley 'custom', ()-> error
            $input.parsley 'validate'

        _load : () ->
            # The module is loaded. Here we re-init the view.

            $panel = $("#property-first-panel").find(".property-details")

            # Remove the old panel, so that the event is removed
            $new_panel = $("<div class='scroll-content property-content property-details'></div>").insertAfter( $panel )
            # Remove children and detach it from DOM
            $panel.empty().remove()

            @setElement $new_panel
            @render()

            @focusImportantInput()
            null

        _loadAsSub : ( subPanelID ) ->

            # In the previous version, we uses "ide_event.PROPERTY_OPEN_SUBPANEL" to open the subpanel.
            # I'm against using ide_event, because it seems like something is decoupled, but it
            # will create dependency hell, for example, you have no idea who will use your ide_event.
            # Instead, we use our own event
            if @__restore
                $("#OEPanelRight").trigger("OPEN_SUBPANEL_IMM")
            else
                $("#OEPanelRight").trigger("OPEN_SUBPANEL")


            # Set the element to Second Panel Wrapper
            # So that subclass can use it to insert there content
            # It's a bit weird, but I don't have better idea at this moment.
            @setElement $("#property-second-panel .property-content")

            @render()

            # Then switch to the wrapper of the content.
            # So that events are bound to the wrapper of the content.
            # this.setElment this.$el.children().eq(0)  # # # Not sure if this is necessary.
            that = this
            setTimeout (()-> that.focusImportantInput()), 200
            null

        _render : () ->
            result = @_originalRender()


            # TODO : Do all the component initialization here
            selectbox.init()


            # If render() returns a string.
            # Assume it is the title of the property panel
            if _.isString result

                # if is sg property, do not set title
                resUID = @model.get 'uid'
                if resUID
                    resComp = Design.instance().component(resUID)
                    if resComp and resComp.type is constant.RESTYPE.SG
                        return null

                # all other property
                @setTitle result

            else
                return result

            null

        focusImportantInput : ()->
            that = this
            $emptyInput = that.$el.find("input[data-empty-remove]").filter ()->
                !this.value.length
            if $emptyInput.length
                setTimeout(() ->
                    that.forceShow()
                    $emptyInput.focus()
                    that.disabledAllOperabilityArea(true)
                , 0)
            null
    }

    PropertyView.extend = ( protoProps, staticProps ) ->

        # If the PropertyView subclass implements render()
        # swizzle it with baseclass _render()
        if protoProps.render
            protoProps._originalRender = protoProps.render
            protoProps.render          = PropertyView.prototype._render

        Backbone.View.extend.call this, protoProps, staticProps

    PropertyView
