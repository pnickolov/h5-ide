#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    GegionView = Backbone.View.extend {
        time_stamp : 0

        el       : $( '#tab-content-region' )

        template : Handlebars.compile $( '#region-tmpl' ).html()

        events   :
            'click .return-overview'          : 'returnOverviewClick'

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        render   : ( time_stamp ) ->
            console.log 'dashboard region render'
            $( this.el ).html this.template()
            if time_stamp
                this.time_stamp = time_stamp
            this.update_time time_stamp

        update_time   : ( time_stamp ) ->
            $( '#update-time' ).html MC.intervalDate( time_stamp )
            setInterval () ->
                $( '#update-time' ).html MC.intervalDate( time_stamp )
            , 60000

            null
    }

    return GegionView