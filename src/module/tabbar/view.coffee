#############################
#  View(UI logic) for tabbar
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    TabBarView = Backbone.View.extend {

        el       : $( '#tab-bar' )

        template : Handlebars.compile $( '#tabbar-tmpl' ).html()

        events   :
            'click #tab-bar-dashboard a' : 'openDashboardTabClick'
            #'click .tab-bar-truncate'      : 'openStackClick'

        render   : () ->
            console.log 'tabbar render'
            $( this.el ).html this.template()

        openDashboardTabClick : () ->
            console.log 'openDashboardTabClick'
            ide_event.trigger ide_event.OPEN_DASHBOARD, 'dashboard'

        openStackClick : ( event ) ->
            console.log 'openStackClick'
            #ide_event.trigger ide_event.OPEN_STACK_TAB, event.target.title
    }

    return TabBarView