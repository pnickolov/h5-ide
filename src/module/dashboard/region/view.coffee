#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    GegionView = Backbone.View.extend {

        el       : $( '#tab-content-region' )

        template : Handlebars.compile $( '#region-tmpl' ).html()

        events   :
            'click .return-overview'          : 'returnOverviewClick'

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        render   : () ->
            console.log 'dashboard region render'
            $( this.el ).html this.template this.model.attributes

        runAppClick : ( event ) ->
            console.log 'dashboard region run app'
            #ide_event.trigger ide_event.OPEN_APP_TAB, app_name, region_name, app_id

        stopAppClick : ( ) ->
            console.log 'dashboard region stop app'

        terminateAppClick : ( ) ->
            console.log 'dashboard region terminal app'
            #ide_event.trigger ide_event.TERMINATE_APP_TAB, app_name, region_name, app_id

        duplicateStackClick : ( ) ->
            console.log 'dashboard region duplicate stack'

        deleteStackClick : ( ) ->
            console.log 'dashboard region delete stack'

        createStackClick : ( ) ->
            console.log 'dashboard region create stack'
            #ide_event.trigger ide_event.ADD_STACK_TAB, region_name

    }

    return GegionView