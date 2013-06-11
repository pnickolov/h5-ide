#############################
#  View(UI logic) for design/property
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    PropertyView = Backbone.View.extend {

        el       : $( '#property-panel' )

        template : Handlebars.compile $( '#property-tmpl' ).html()

        render   : () ->
            console.log 'property render'
            $( this.el ).html this.template()
            #event.trigger event.DESIGN_COMPLETE
    }

    return PropertyView