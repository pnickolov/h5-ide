
####################################
#  Base Class for View of Property Module
####################################

define [ 'backbone',
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
         'UI.slider'
], ()->

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
            $( if @_isSub then "#property-second-title" else "#property-title" ).html title
            null

        forceShow : () ->
            PropertyView.event.trigger PropertyView.event.FORCE_SHOW
            null

        _load : () ->
            # The module is loaded. Here we re-init the view.

            $panel = $("#property-first-panel").find(".property-details")

            if not @_noRender
                # Remove the old panel, so that the event is removed
                $new_panel = $("<div class='scroll-content property-content property-details'></div>").insertAfter( $panel )
                $panel.remove()

                @setElement $new_panel
                @render()
            else
                # Recovering old tab, use setElement to bind the event
                @setElement $panel
            null

        _loadAsSub : ( subPanelID ) ->

            # In the previous version, we uses "ide_event.PROPERTY_OPEN_SUBPANEL" to open the subpanel.
            # I'm against using ide_event, because it seems like something is decoupled, but it
            # will create dependency hell, for example, you have no idea who will use your ide_event.
            # Instead, we use our own event
            PropertyView.event.trigger PropertyView.event.OPEN_SUBPANEL, subPanelID

            # Set the element to Second Panel Wrapper
            # So that subclass can use it to insert there content
            # It's a bit weird, but I don't have better idea at this moment.
            @setElement $("#property-second-panel .property-content")

            title = @render()

            # Then switch to the wrapper of the content.
            # So that events are bound to the wrapper of the content.
            # this.setElment this.$el.children().eq(0)  # # # Not sure if this is necessary.
            null

        _render : () ->
            result = @_originalRender()


            # TODO : Do all the component initialization here
            selectbox.init()


            # If render() returns a string.
            # Assume it is the title of the property panel
            if _.isString result
                @setTitle result
            else
                return result

            null
    }

    # The event object is used to communicate with design/property/view
    # So that we don't have a reference to desing/property/view, avoiding
    # a strong dependency on it.
    PropertyView.event = _.extend {}, Backbone.Events
    PropertyView.event.FORCE_SHOW    = "forceshow"
    PropertyView.event.OPEN_SUBPANEL = "opensubpanel"

    PropertyView.extend = ( protoProps, staticProps ) ->

        # If the PropertyView subclass implements render()
        # swizzle it with baseclass _render()
        if protoProps.render
            protoProps._originalRender = protoProps.render
            protoProps.render          = PropertyView.prototype._render

        Backbone.View.extend.call this, protoProps, staticProps

    PropertyView
