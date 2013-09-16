#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'i18n!nls/lang.js', 'backbone', 'jquery', 'handlebars', 'UI.notification' ], ( ide_event, lang ) ->

    GegionView = Backbone.View.extend {
        time_stamp : new Date().getTime()

        el       : $( '#tab-content-region' )

        #template : Handlebars.compile $( '#region-tmpl' ).html()

        stat_table : Handlebars.compile $( '#region-resource-tables-tmpl' ).html()
        unmanaged_table : Handlebars.compile $( '#region-unmanaged-resource-tables-tmpl' ).html()
        vpc_attrs : Handlebars.compile $( '#vpc-attrs-tmpl' ).html()
        aws_status : Handlebars.compile $( '#aws-status-tmpl' ).html()
        stat_app_count : Handlebars.compile $( '#stat-app-count-tmpl' ).html()
        stat_stack_count : Handlebars.compile $( '#stat-stack-count-tmpl' ).html()
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
            'click #asg-app-name'           : 'clickAsgAppName'

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

            if time_stamp
                this.time_stamp = time_stamp
            this.update_time()

            null

        renderRegionStatInfo : ->
            console.log 'dashboard region stat info render'
            $( this.el ).find( '.region-stat-info' ).html this.stat_info this.model.attributes
            null

        renderRegionStatApp : ->
            console.log 'dashboard region stat app render'
            $( this.el ).find( '#stat-app-count' ).html this.stat_app_count this.model.attributes
            $( this.el ).find( '#region-stat-app' ).html this.stat_app this.model.attributes
            null

        renderRegionStatStack : () ->
            console.log 'dashboard region stat stack render'
            $( this.el ).find( '#stat-stack-count' ).html this.stat_stack_count this.model.attributes
            $( this.el ).find( '#region-stat-stack' ).html this.stat_stack this.model.attributes
            null

        checkCreateStack : ( platforms ) ->
            $button = $("#btn-create-stack")
            if platforms and platforms.length
                $button.removeAttr "disabled"
            else
                $button.attr "disabled", "disabled"
            null

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        returnRefreshClick : ( target ) ->
            console.log 'returnRefreshClick'
            ide_event.trigger ide_event.UPDATE_REGION_RESOURCE, this.region

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

            # check credential
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region run app'
                    modal.close()
                    event.data.target.trigger 'RUN_APP_CLICK', id

            true

        stopAppClick : ( event ) ->
            target = $( this.el )
            id = event.currentTarget.id

            # check credential
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region stop app'
                    event.data.target.trigger 'STOP_APP_CLICK', id
                    modal.close()

            true

        terminateAppClick : ( event ) ->
            target = $( this.el )
            id = event.currentTarget.id

            # check credential
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region terminal app'
                    modal.close()
                    event.data.target.trigger 'TERMINATE_APP_CLICK', id

            true

        #stack
        duplicateStackClick : ( event ) ->
            target = $( this.el )
            region = this.region
            id = event.currentTarget.id
            name = event.currentTarget.name

            # set default name
            new_name = MC.aws.aws.getDuplicateName(name)
            $('#modal-input-value').val(new_name)

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard region duplicate stack'
                new_name = $('#modal-input-value').val()

                #check duplicate stack name
                if not new_name
                    notification 'warning', lang.ide.PROP_MSG_WARN_NO_STACK_NAME
                else if new_name.indexOf(' ') >= 0
                    notification 'warning', 'stack name contains white space.'
                else if not MC.aws.aws.checkStackName null, new_name
                    notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
                else
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
            return false

        clickAppThumbnail : ( event ) ->
            console.log 'dashboard region click app thumbnail'
            console.log $(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region
            ide_event.trigger ide_event.OPEN_APP_TAB, $(event.currentTarget).find('.thumbnail-name').text(), this.region, event.currentTarget.id

        clickStackThumbnail : ( event ) ->
            console.log 'dashboard region click stack thumbnail'
            console.log $(event.currentTarget).find('.thumbnail-name').text(), event.currentTarget.id, this.region
            ide_event.trigger ide_event.OPEN_STACK_TAB, $(event.currentTarget).find('.thumbnail-name').text(), this.region, event.currentTarget.id

        updateThumbnail : ( url ) ->
            console.log 'updateThumbnail, url = ' + url
            _.each $( '#region-stat-stack' ).children(), ( item ) ->
                $item = $ item
                if $item.attr('style').indexOf( url ) isnt -1
                    new_url = 'https://s3.amazonaws.com/madeiracloudthumbnail/' + url + '?time=' + Math.round(+new Date())
                    console.log 'new_url = ' + new_url
                    $item.removeAttr 'style'
                    $item.css 'background-image', 'url(' + new_url + ')'

        clickAsgAppName : ( event ) ->
            me = this
            console.log 'dashboard region click asg app name'

            app_name = $(event.currentTarget).data('option').name
            app_id   = $(event.currentTarget).data('option').id
            ide_event.trigger ide_event.OPEN_APP_TAB, app_name, me.region, app_id

    }

    return GegionView
