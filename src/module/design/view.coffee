#############################
#  View(UI logic) for design
#############################

define [ 'Design', 'event', './module/design/template', 'constant', 'i18n!nls/lang.js', 'state_status', 'backbone', 'jquery', 'handlebars' ], ( Design, ide_event, template, constant, lang, stateStatusMain ) ->

    DesignView = Backbone.View.extend {

        el          : '#tab-content-design'

        events      :
            'click .btn-ta-valid' : 'statusBarTAClick'
            'click .btn-state' : 'statusBarClick'

        render   : () ->
            console.log 'design render'
            #render
            this.$el.html template()
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

        statusBarClick : ( event ) ->
            stateStatusMain.loadModule()

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

        renderStateBar: ( stateList ) ->
            succeed = failed = 0

            if not _.isArray stateList
                stateList = [ stateList ]

            for state in stateList
                # Show current app only
                if state.app_id isnt MC.common.other.canvasData.data( 'origin' ).id
                    continue
                if state.status
                    for status in state.status
                        if status.result is 'success'
                            succeed++
                        else if status.result is 'failure'
                            failed++

            $stateBar = $ '.statusbar-btn'
            $stateBar
                .find( '.state-success b' )
                .text succeed

            $stateBar
                .find( '.state-failed b' )
                .text failed

        loadStateStatusBar: ->
            # Sub Event
            ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA, @updateStateBar
            ide_event.onLongListen ide_event.UPDATE_STATE_STATUS_DATA, @updateStateBar, @

            ide_event.offListen ide_event.UPDATE_APP_STATE, @updateStateBarWhenStateChanged
            ide_event.onLongListen ide_event.UPDATE_APP_STATE, @updateStateBarWhenStateChanged, @

            #appStoped = Design.instance().get('state') is 'Stopped'
            appStoped = MC.common.other.canvasData.data( 'origin' ).state is 'Stopped'

            $btnState = $( '#main-statusbar .btn-state' )

            if Tabbar.current in ['app', 'appedit']
                if appStoped
                    $btnState.hide()

            if appStoped
                return

            if Tabbar.current is 'appview'
                $btnState.hide()
            else
                $btnState.show()

            stateList = MC.data.websocket.collection.status.find().fetch()
            @renderStateBar stateList


        updateStateBarWhenStateChanged: ( state ) ->
            if state is 'Stopped'
                stateList = []
            else
                stateList = MC.data.websocket.collection.status.find().fetch()

            @renderStateBar stateList

        updateStateBar: ( type, idx, statusData ) ->
            stateList = MC.data.websocket.collection.status.find().fetch()
            @renderStateBar stateList



        unloadStateStatusBar: ->
            $( '#main-statusbar .btn-state' ).hide()
            ide_event.offListen ide_event.UPDATE_STATE_STATUS_DATA

        hideStatusbar :  ->
            console.log 'hideStatusbar'

            # hide
            if Tabbar.current in [ 'app', 'appview' ]
                $( '#main-statusbar .btn-ta-valid' ).hide()
                @loadStateStatusBar()


            else if ( Tabbar.current is 'appedit' )
                $( '#main-statusbar .btn-ta-valid' ).show()
                @loadStateStatusBar()
            # show
            else

                $( '#main-statusbar .btn-ta-valid' ).show()
                @unloadStateStatusBar()

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

                    when constant.APP_STATE.APP_STATE_UPDATING

                        # init obj
                        obj = { 'is_show' : false, 'rate' : 0, 'steps' : 0, 'dones' : 0 }

                        if MC.data.process and MC.data.current_tab_id and MC.data.process[ MC.data.current_tab_id ] and MC.data.process[ MC.data.current_tab_id ].flag_list

                            flag_list = MC.data.process[ MC.data.current_tab_id ].flag_list

                            if flag_list.rate and flag_list.steps and flag_list.dones
                                obj = { 'is_show' : true,  'rate' : flag_list.rate, 'steps' : flag_list.steps, 'dones' : flag_list.dones }

                        $item.html MC.template.appUpdating obj

                    when 'CHANGED_FAIL'

                        # init obj
                        obj = { 'is_show' : false, 'state' : 'update', 'detail' : '', 'update_detail' : true }

                        if MC.data.process and MC.data.current_tab_id and MC.data.process[ MC.data.current_tab_id ] and MC.data.process[ MC.data.current_tab_id ].flag_list

                            flag_list = MC.data.process[ MC.data.current_tab_id ].flag_list

                            if flag_list.flag and lang.ide[ flag_list.flag ] and flag_list.err_detail

                                obj =
                                    'is_show'       : true
                                    'state'         : lang.ide[ flag_list.flag ]
                                    'detail'        : flag_list.err_detail.replace( /\n/g, '</br>' )
                                    'update_detail' : if flag_list.flag is 'UPDATE_APP' then true else false

                        $item.html MC.template.appChangedfail obj

                    when 'UPDATING_SUCCESS'                       then $item.html MC.template.appUpdatedSuccess()
                    else
                        console.log 'current state = ' + state
                        console.log MC.data.process[ MC.data.current_tab_id ]

                # open tab fail( includ app and stack )
                if state is 'OPEN_TAB_FAIL'

                    obj = MC.common.other.searchStackAppById MC.data.current_tab_id
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
                        # MC.common.other.deleteProcess MC.data.current_tab_id

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
            MC.common.other.deleteProcess MC.data.current_tab_id

            null

    }

    return DesignView
