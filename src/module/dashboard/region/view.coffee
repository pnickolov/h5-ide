#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    GegionView = Backbone.View.extend {
        time_stamp : new Date().getTime()

        el       : $( '#tab-content-region' )

        template : Handlebars.compile $( '#region-tmpl' ).html()

        events   :
            'click .return-overview'          : 'returnOverviewClick'
            'click .refresh'                  : 'returnRefreshClick'

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        returnRefreshClick : ( target ) ->
            console.log 'returnRefreshClick'
            this.trigger 'REFRESH_REGION_BTN', null

        render   : ( time_stamp ) ->
            console.log 'dashboard region render'
            $( this.el ).html this.template this.model.attributes
            if time_stamp
                this.time_stamp = time_stamp
            this.update_time()

        update_time   : () ->
            me = this

            $( '#update-time' ).html MC.intervalDate( me.time_stamp )
            setInterval () ->
                $( '#update-time' ).html MC.intervalDate( me.time_stamp )
            , 60000

            null
    }

    return GegionView