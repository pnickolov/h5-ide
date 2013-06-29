#############################
#  View(UI logic) for design/property
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    PropertyView = Backbone.View.extend {

        el       : $( '#property-panel' )

        template : Handlebars.compile $( '#property-tmpl' ).html()

        initialize : ->
            #listen
            $( document ).delegate '#hide-property-panel', 'click', this.togglePropertyPanel

        render   : () ->
            console.log 'property render'
            $( this.el ).html this.template()
            #event.trigger event.DESIGN_COMPLETE

        togglePropertyPanel : ( event ) ->
        	#
            property_panel = $ '#property-panel'
            property_panel.toggleClass 'hiden'
            #
            $( event ).children().first().toggleClass('icon-double-angle-left').toggleClass('icon-double-angle-right')
            #
            main_middle = $ '#canvas-panel'
            main_middle.toggleClass 'right-hiden'
            #
            canvasPanelResize()
    }

    return PropertyView