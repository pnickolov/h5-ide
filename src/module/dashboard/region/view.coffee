#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    GegionView = Backbone.View.extend {
        time_stamp : new Date().getTime()

        el       : $( '#tab-content-region' )

        template : Handlebars.compile $( '#region-tmpl' ).html()

        events   :
            'click .return-overview'        : 'returnOverviewClick'
            'click .refresh'                : 'returnRefreshClick'
            'modal-shown .run-app'          : 'runAppClick'
            'modal-shown .stop-app'         : 'stopAppClick'
            'modal-shown .terminate-app'    : 'terminateAppClick'
            'modal-shown .duplicate-stack'  : 'duplicateStackClick'
            'modal-shown .delete-stack'     : 'deleteStackClick'
            'click #btn-create-stack'       : 'createStackClick'
            'click .app-thumbnail'          : 'clickAppThumbnail'
            'click .stack-thumbnail'        : 'clickStackThumbnail'

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
            name = event.currentTarget.name

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard region duplicate stack'
                new_name = $('#modal-input-value').val()

                #check duplicate stack name
                if not new_name or new_name == name
                    #output warn message
                    return

                modal.close()
                event.data.target.trigger 'DUPLICATE_STACK_CLICK', id, new_name
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
            ide_event.trigger ide_event.ADD_STACK_TAB, this.region

        clickAppThumbnail : ( event ) ->
            console.log 'dashboard region click app thumbnail'
            console.log $(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region
            ide_event.trigger ide_event.OPEN_APP_TAB, $(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region

        clickStackThumbnail : ( event ) ->
            console.log 'dashboard region click stack thumbnail'
            console.log $(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region
            ide_event.trigger ide_event.OPEN_STACK_TAB, $(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region

    }

    return GegionView