#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    GegionView = Backbone.View.extend {

        el       : $( '#tab-content-region' )

        template : Handlebars.compile $( '#region-tmpl' ).html()

        events   :
            'click .return-overview'        : 'returnOverviewClick'
            'click .icon-play'              : 'runAppClick'
            'click .icon-stop'              : 'stopAppClick'
            'click .icon-close'             : 'terminateAppClick'
            'click .icon-redo'              : 'duplicateStackClick'
            'click .icon-trashcan'          : 'deleteStackClick'

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        render   : () ->
            console.log 'dashboard region render'
            $( this.el ).html this.template this.model.attributes

        #app
        runAppClick : ( event ) ->
            console.log 'dashboard region run app'
            this.trigger 'RUN_APP_CLICK', event.currentTarget.id

        stopAppClick : ( event ) ->
            console.log 'dashboard region stop app'
            this.trigger 'STOP_APP_CLICK', event.currentTarget.id

        terminateAppClick : ( event ) ->
            #terminal confirm dialog
            console.log 'dashboard region terminal app'
            this.trigger 'TERMINATE_APP_CLICK', event.currentTarget.id

        #stack
        duplicateStackClick : ( event ) ->
            console.log 'dashboard region duplicate stack'
            #duplicate confirm dialog
            this.trigger 'DUPLICATE_STACK_CLICK', event.currentTarget.id, "new_name"

        deleteStackClick : ( event ) ->
            console.log 'dashboard region delete stack'
            #delete confirm dialog
            this.trigger 'DELETE_STACK_CLICK', event.currentTarget.id

        createStackClick : ( event ) ->
            console.log 'dashboard region create stack'
            ide_event.trigger ide_event.ADD_STACK_TAB, region_name

    }

    return GegionView