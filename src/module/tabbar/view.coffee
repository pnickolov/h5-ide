#############################
#  View(UI logic) for tabbar
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    TabBarView = Backbone.View.extend {

        el       : $( '#tab-bar' )

        template : Handlebars.compile $( '#tabbar-tmpl' ).html()

        render   : () ->
            console.log 'tabbar render'
            $( this.el ).html this.template()
            #event.trigger event.NAVIGATION_COMPLETE
    }

    return TabBarView