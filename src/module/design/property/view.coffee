#############################
#  View(UI logic) for design/property
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    PropertyView = Backbone.View.extend {

        el         : $ '#property-panel'

        initialize : ->
            #listen
            $( document ).delegate '#hide-property-panel', 'click', this.togglePropertyPanel

        render     : ( template ) ->
            console.log 'property render'
            $( this.el ).html template

        togglePropertyPanel : ( event ) ->
            console.log 'togglePropertyPanel'
            $( '#property-panel' ).toggleClass 'hiden'
            $( event ).children().first().toggleClass('icon-double-angle-left').toggleClass('icon-double-angle-right')
            $( '#canvas-panel' ).toggleClass 'right-hiden'
    }

    return PropertyView