
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

    ###

    PropertyView = Backbone.View.extend {

        setTitle : ( title ) ->
            $( if this._isSub then "#property-second-title" else "#property-title" ).html title

        _load : () ->
            # The module is loaded. Here we re-init the view.

            $panel = $("#property-first-panel").find(".property-details")

            if not this._noRender
                # Remove the old panel, so that the event is removed
                $new_panel = $("<div class='property-content property-details'></div>").insertAfter( $panel )
                $panel.remove()

                this.setElement $new_panel
                title = this.render()
            else
                # Recovering old tab, use setElement to bind the event
                this.setElement $panel

            # If render() returns a string.
            # Assume it is the title of the property panel
            if _.isString title
                this.setTitle title

            # TODO : Do all the component initialization here
            selectbox.init()

        _loadAsSub : () ->

            # Set the element to Second Panel Wrapper
            # So that subclass can use it to insert there content
            # It's a bit weird, but I don't have better idea at this moment.
            this.setElement $("#property-second-panel .property-content")

            title = this.render()

            # Then switch to the wrapper of the content.
            # So that events are bound to the wrapper of the content.
            # this.setElment this.$el.children().eq(0)  # # # Not sure if this is necessary.

            # If render() returns a string.
            # Assume it is the title of the property panel
            if _.isString title
                this.title title

            # TODO : Do all the component initialization here
            selectbox.init()
    }

    PropertyView
