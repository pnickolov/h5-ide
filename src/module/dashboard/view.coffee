#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    DashboardView = Backbone.View.extend {

        el       : $( '#tab-content-dashboard' )

        template : Handlebars.compile $( '#dashboard-tmpl' ).html()

        render   : () ->
            console.log 'dashboard render'
            $( this.el ).html this.template()
            #event.trigger event.NAVIGATION_COMPLETE
    }

    return DashboardView