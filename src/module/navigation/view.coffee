#############################
#  View(UI logic) for navigation
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    NavigationView = Backbone.View.extend {

        el       : $( '#navigation' )

        template : Handlebars.compile $( '#navigation-tmpl' ).html()

        render   : () ->
            console.log 'navigation render'
            $( this.el ).html this.template()
            event.trigger event.NAVIGATION_COMPLETE
    }

    return NavigationView