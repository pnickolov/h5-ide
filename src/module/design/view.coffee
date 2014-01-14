#############################
#  View(UI logic) for design
#############################

define [ 'event', 'text!./module/design/template.html', 'constant', 'i18n!nls/lang.js', 'backbone', 'jquery', 'handlebars' ], ( ide_event, template, constant, lang ) ->

    DesignView = Backbone.View.extend {

        el          : '#tab-content-design'

        events      :
            'click .btn-ta-valid' : 'statusBarTAClick'
            'click .btn-state' : 'statusBarStateClick'

        render   : () ->
            console.log 'design render'
            #render
            this.$el.html template
            #push DESIGN_COMPLETE
            this.trigger 'DESIGN_COMPLETE'
            #
            $( '#main-statusbar' ).html MC.template.statusbar()

        listen   : ( model ) ->
            #set this.model
            this.model = model
            #listen model
            this.listenTo this.model, 'change:snapshot',     @writeOldDesignHtml
            this.listenTo ide_event,  'SHOW_DESIGN_OVERLAY', @showDesignOverlay
            this.listenTo ide_event,  'HIDE_DESIGN_OVERLAY', @hideDesignOverlay

        html : ->
            data =
                resource : $( '#resource-panel' ).html()
                #property : $( '#property-panel' ).html()
                canvas   : $( '#canvas-panel'   ).html()
                overlay  : $( '#overlay-panel'  ).html()
            data

        writeOldDesignHtml : ( event ) ->
            console.log 'writeOldDesignHtml'
            return if _.isNumber event.attributes.snapshot
            #
            $( '#canvas-panel' ).one( 'DOMNodeInserted', '.canvas-svg-group', this, _.debounce( this.canvasChange, 200, true ))
            #
            $( '#resource-panel' ).html this.model.get( 'snapshot' ).resource
            $( '#canvas-panel'   ).html this.model.get( 'snapshot' ).canvas
            $( '#overlay-panel'  ).html this.model.get( 'snapshot' ).overlay
            #$( '#property-panel' ).html this.model.get( 'snapshot' ).property
            #
            if $.trim( $( '#overlay-panel'  ).html() ) isnt '' then @showDesignOverlay() else @hideDesignOverlay()
            ###
            this.$el.empty().html this.model.get 'snapshot'
            $( '#property-panel' ).empty()
            ###
            null

        canvasChange : ( event ) ->
            console.log 'canvas:listen DOMNodeInserted'
            console.log MC.data.current_tab_type
            if MC.data.current_tab_type is 'OLD_APP' or MC.data.current_tab_type is 'OLD_STACK'
                ide_event.trigger ide_event.SWITCH_WAITING_BAR
                MC.data.current_tab_type = null
            null

        statusBarTAClick : ( event ) ->
            console.log 'statusbarTAClick'
            btnDom = $(event.currentTarget)
            currentText = 'Validate'
            btnDom.text('Validating...')

            setTimeout () ->
                MC.ta.validAll()
                btnDom.text(currentText)
                #status = _.last $(event.currentTarget).attr( 'class' ).split '-'
                require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) -> trustedadvisor_main.loadModule 'statusbar', null
            , 50

        statusBarStateClick : ( event ) ->
            setTimeout () ->
                require [ 'state_status' ], ( statestatus_main ) -> statestatus_main.loadModule 'success', null
            , 0

        updateStatusbar : ( type, level ) ->
            console.log 'updateStatusbar, level = ' + level + ', type = ' + type
            #
            # $new_status = $( '.icon-statusbar-' + level.toLowerCase() )
            # outerHTML   = $new_status.get( 0 ).outerHTML
            # count       = $new_status.parent().html().replace( outerHTML, '' )
            # if type is 'add'
            #     count   = parseInt( count, 10 ) + 1
            # else if type is 'delete'
            #     count   = parseInt( count, 10 ) - 1
            # #
            # $new_status.parent().html outerHTML + count
            #
            ide_event.trigger ide_event.UPDATE_TA_MODAL
            null

        updateStatusBarSaveTime : () ->
            console.log 'updateStatusBarSaveTime'

            # 1.set current time
            save_time = $.now() / 1000

            # 2.clear interval
            clearInterval @timer

            # 3.set textTime
            $item    = $('.stack-save-time')
            $item.text MC.intervalDate save_time
            $item.attr 'data-tab-id',    MC.data.current_tab_id
            $item.attr 'data-save-time', save_time

            # 4.loop
            @timer = setInterval ( ->

                $item    = $('.stack-save-time')
                if $item.attr( 'data-tab-id' ) is MC.data.current_tab_id
                    $item.text MC.intervalDate $item.attr 'data-save-time'

            ), 500
            #
            null

        hideStatusbar :  ->
            console.log 'hideStatusbar'

            # hide
            if Tabbar.current in [ 'app', 'appview' ]
                $( '#main-statusbar .btn-ta-valid' ).hide()
                $( '#main-statusbar .btn-state' ).show()

            # show
            else
                $( '#main-statusbar .btn-state' ).hide()
                $( '#main-statusbar .btn-ta-valid' ).show()

            if Tabbar.current is 'appedit'
                $( '#canvas' ).css 'bottom', 24

            null

        showDesignOverlay : ( state, id ) ->

            try

                console.log 'showDesignOverlay', state, id

                return if MC.data.current_tab_id isnt id

                # state include:
                # 1. open fail
                # 2. process( starting, stopping, terminating, updating, changed fail )

                $item = $( '#overlay-panel' )

                # 1. add class
                $item.addClass 'design-overlay'

                # 2. switch state
                switch state
                    when 'OPEN_TAB_FAIL'                          then $item.html MC.template.openTabFail()
                    when constant.APP_STATE.APP_STATE_STARTING    then $item.html MC.template.appStarting()
                    when constant.APP_STATE.APP_STATE_STOPPING    then $item.html MC.template.appStopping()
                    when constant.APP_STATE.APP_STATE_TERMINATING then $item.html MC.template.appTerminating()
                    when constant.APP_STATE.APP_STATE_UPDATING    then $item.html MC.template.appUpdating { 'rate' : MC.data.process[ MC.data.current_tab_id ].flag_list.rate, 'steps' : MC.data.process[ MC.data.current_tab_id ].flag_list.steps, 'dones' : MC.data.process[ MC.data.current_tab_id ].flag_list.dones }
                    when 'CHANGED_FAIL'                           then $item.html MC.template.appChangedfail { 'state' : lang.ide[ MC.data.process[ MC.data.current_tab_id ].flag_list.flag ] , 'detail' : MC.data.process[ MC.data.current_tab_id ].flag_list.err_detail.replace( /\n/g, '</br>' ), 'update_detail' : if MC.data.process[ MC.data.current_tab_id ].flag_list.flag is 'UPDATE_APP' then true else false  }
                    when 'UPDATING_SUCCESS'                       then $item.html MC.template.appUpdatedSuccess()
                    else
                        console.log 'current state = ' + state
                        console.log MC.data.process[ MC.data.current_tab_id ]

                # open tab fail( includ app and stack )
                if state is 'OPEN_TAB_FAIL'

                    obj = MC.forge.other.searchStackAppById MC.data.current_tab_id
                    #
                    if Tabbar.current is 'new'
                        event_type = 'RELOAD_NEW_STACK'
                    else if obj
                        event_type = if MC.data.current_tab_id.split('-')[0] is 'app' then 'RELOAD_APP' else 'RELOAD_STACK'
                        MC.open_failed_list[ MC.data.current_tab_id ] = $.extend true, {}, obj
                    else
                        console.error 'app or stack not find, current id is ' + MC.data.current_tab_id
                    #
                    $( '#btn-fail-reload' ).one 'click', ( event ) ->
                        if Tabbar.current is 'new'
                            #ide_event.trigger event_type, MC.open_failed_list[ MC.data.current_tab_id ].id, MC.open_failed_list[ MC.data.current_tab_id ].region, MC.open_failed_list[ MC.data.current_tab_id ].platform
                            ide_event.trigger ide_event.OPEN_DESIGN_TAB, event_type, MC.open_failed_list[ MC.data.current_tab_id ].platform, MC.open_failed_list[ MC.data.current_tab_id ].region, MC.open_failed_list[ MC.data.current_tab_id ].id
                        else if MC.open_failed_list[ MC.data.current_tab_id ]
                            #ide_event.trigger event_type, MC.open_failed_list[ MC.data.current_tab_id ].id, MC.open_failed_list[ MC.data.current_tab_id ].region
                            ide_event.trigger ide_event.OPEN_DESIGN_TAB, event_type, null, MC.open_failed_list[ MC.data.current_tab_id ].region, MC.open_failed_list[ MC.data.current_tab_id ].id
                        else
                            console.error 'not click, current not id'
                        #
                        null

                # app changed fail
                else if state is 'CHANGED_FAIL'
                    $( '#btn-changedfail' ).one 'click', ( event ) ->

                        # hide overlay
                        # ide_event.trigger ide_event.APPEDIT_UPDATE_ERROR
                        ide_event.trigger ide_event.HIDE_DESIGN_OVERLAY

                        # delete MC.process and MC.data.process
                        # delete MC.process[ MC.data.current_tab_id ]
                        # delete MC.data.process[ MC.data.current_tab_id ]
                        # MC.forge.other.deleteProcess MC.data.current_tab_id

                        null

                # app update success
                else if state is 'UPDATING_SUCCESS'
                    $( '#btn-updated-success' ).one 'click', ( event ) ->

                        ide_event.trigger ide_event.APPEDIT_2_APP, MC.data.process[ MC.data.current_tab_id ].id, MC.data.process[ MC.data.current_tab_id ].region

                        # delete MC.process and MC.data.process by toolbar/view.coffee

                        null

                # app updating( pending and processing )
                else if state is constant.APP_STATE.APP_STATE_UPDATING

                    if MC.data.process[ MC.data.current_tab_id ].flag_list.is_pending

                        $( '.overlay-content-wrap' ).find( '.progress' ).hide()
                        $( '.overlay-content-wrap' ).find( '.process-info' ).hide()

                    else if MC.data.process[ MC.data.current_tab_id ].flag_list.is_inprocess

                        $( '.overlay-content-wrap' ).find( '.loading-spinner' ).hide()
                        $( '.overlay-content-wrap' ).find( '.progress' ).show()
                        $( '.overlay-content-wrap' ).find( '.process-info' ).show()

            catch error
                  console.log 'design:view:showDesignOverlay error'
                  console.log 'showDesignOverlay, state = ' + state
                  console.log "error message: #{ error }"

            null

        hideDesignOverlay : ->
            console.log 'hideDesignOverlay'

            $item = $( '#overlay-panel' )

            # 1. remove class
            $item.removeClass 'design-overlay'

            # 2. remove html
            $item.empty() if $.trim( $item.html() ) isnt ''

            # 3. delete MC.process and MC.data.process
            # delete MC.process[ MC.data.current_tab_id ]
            # delete MC.data.process[ MC.data.current_tab_id ]
            MC.forge.other.deleteProcess MC.data.current_tab_id

            null

    }

    return DesignView
