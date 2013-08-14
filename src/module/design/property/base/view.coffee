
####################################
#  Base Class for View of Property Module
####################################

define ['backbone', 'UI.selectbox'], ()->

    PropertyView = Backbone.View.extend {

        setTitle : ( title ) ->
            $("#property-title").html title

        setSecondaryTitle : ( title ) ->
            $("#property-second-title").html title

        _load : () ->
            # The module is loaded. Here we re-init the view.

            title = this.render()

            # Set the element of the view to ".property-details > *:first-child"
            # This will rebind the events to the element.
            # The element will be replaced by another module when the other module loads
            $target = $(".property-details").children().eq(0)
            this.setElement $target

            # If render() returns a string.
            # Assume it is the title of the property panel
            if _.isString title
                this.setTitle title

            # TODO : Do component initialization here
            selectbox.init()

        _loadAsSub : () ->

            # Set the element to Second Panel Wrapper
            # So that subclass can use it to insert there content
            # It's a bit weird, but I don't have better idea at this moment.
            this.setElement $("#property-second-panel .property-content")

            title = this.render()

            # Then switch to the wrapper of the content.
            # So that events are bound to the wrapper of the content.
            this.setElment this.$el.children().eq(0)

            # If render() returns a string.
            # Assume it is the title of the property panel
            title = this.render()
            if _.isString title
                this.setSecondaryTitle title

            # TODO : Do component initialization here
            selectbox.init()

    }


    PropertyView

