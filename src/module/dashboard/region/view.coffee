#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    GegionView = Backbone.View.extend {

        el       : $( '#tab-content-region' )

        template : Handlebars.compile $( '#region-tmpl' ).html()

        events   :
            'click .return-overview'        : 'returnOverviewClick'
            'modal-shown .run-app'          : 'runAppClick'
            'modal-shown .stop-app'         : 'stopAppClick'
            'modal-shown .terminate-app'    : 'terminateAppClick'
            'modal-shown .duplicate-stack'  : 'duplicateStackClick'
            'modal-shown .delete-stack'     : 'deleteStackClick'

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        render   : () ->
            console.log 'dashboard region render'
            $( this.el ).html this.template this.model.attributes

        #app
        runAppClick : ( event ) ->
            target = $( this.el )
            id = event.currentTarget.id

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard region run app'
                modal.close()
                event.data.target.trigger 'RUN_APP_CLICK', id
            true

        stopAppClick : ( event ) ->
            target = $( this.el )
            id = event.currentTarget.id

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard region stop app'
                event.data.target.trigger 'STOP_APP_CLICK', id
                modal.close()
            true

        terminateAppClick : ( event ) ->
            target = $( this.el )
            id = event.currentTarget.id

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard region terminal app'
                modal.close()
                event.data.target.trigger 'TERMINATE_APP_CLICK', id
            true

        #stack
        duplicateStackClick : ( event ) ->
            target = $( this.el )
            id = event.currentTarget.id

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard region duplicate stack'
                modal.close()
                event.data.target.trigger 'DUPLICATE_STACK_CLICK', id, "new_name"
            true

        deleteStackClick : ( event ) ->
            target = $( this.el )
            id = event.currentTarget.id

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard region delete stack'
                modal.close()
                event.data.target.trigger 'DELETE_STACK_CLICK', id
            true

        createStackClick : ( event ) ->
            console.log 'dashboard region create stack'
            ide_event.trigger ide_event.ADD_STACK_TAB, region_name

    }

    return GegionView