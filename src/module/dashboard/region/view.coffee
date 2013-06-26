#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    GegionView = Backbone.View.extend {
        time_stamp : new Date().getTime()

        el       : $( '#tab-content-region' )

        #template : Handlebars.compile $( '#region-tmpl' ).html()

        stat_table : Handlebars.compile $( '#region-resource-tables-tmpl' ).html()
        unmanaged_table : Handlebars.compile $( '#region-unmanaged-resource-tables-tmpl' ).html()
        vpc_attrs : Handlebars.compile $( '#vpc-attrs-tmpl' ).html()
        aws_status : Handlebars.compile $( '#aws-status-tmpl' ).html()
        stat_app : Handlebars.compile $( '#stat-app-tmpl' ).html()
        stat_stack : Handlebars.compile $( '#stat-stack-tmpl' ).html()

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

        renderVPCAttrs : ->
            console.log 'dashboard region vpc_attrs render'
            $( this.el ).find( '.vpc-attrs-list' ).html this.vpc_attrs this.model.attributes

            null

        renderAWSStatus : ->
            console.log 'dashboard region aws_status render'
            $( this.el ).find( '.aws-status-list' ).html this.aws_status this.model.attributes

            null

        renderRegionResource : ->
            console.log 'dashboard region resource render'
            $( this.el ).find( '.region-resource-tables' ).html this.stat_table this.model.attributes

            null

        renderUnmanagedRegionResource : (time_stamp) ->
            console.log 'dashboard unmanaged region resource render'
            $( this.el ).find( '.region-unmanaged-resource-tables' ).html this.unmanaged_table this.model.attributes
            console.log this.model.attributes

            if time_stamp
                this.time_stamp = time_stamp
            this.update_time()

            null

        renderRegionStatApp : ->
            console.log 'dashboard region stat app render'
            $( this.el ).find( '#region-stat-app' ).html this.stat_app this.model.attributes
            null

        renderRegionStatStack : ->
            console.log 'dashboard region stat stack render'
            $( this.el ).find( '#region-stat-stack' ).html this.stat_stack this.model.attributes
            null

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        returnRefreshClick : ( target ) ->
            console.log 'returnRefreshClick'
            this.trigger 'REFRESH_REGION_BTN', null

        #render   : ( time_stamp ) ->
        #    console.log 'dashboard region render'
        #    $( this.el ).html this.template this.model.attributes
        #    if time_stamp
        #        this.time_stamp = time_stamp
        #    this.update_time()

        render : ( template ) ->

            console.log 'dashboard region render'

            $( this.el ).html template

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
            ide_event.trigger ide_event.OPEN_APP_TAB, $(event.currentTarget).find('.thumbnail-name').text(), this.region, event.currentTarget.id

        clickStackThumbnail : ( event ) ->
            console.log 'dashboard region click stack thumbnail'
            console.log $(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region
            ide_event.trigger ide_event.OPEN_STACK_TAB, $(event.currentTarget).find('.thumbnail-name').text(), this.region, event.currentTarget.id

    }

    return GegionView