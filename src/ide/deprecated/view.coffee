#############################
#  View(UI logic) for Main
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'common_handle',
         'UI.notification',
         'UI.tour',
         'backbone', 'jquery', 'handlebars', 'underscore' ], ( ide_event, lang, common_handle ) ->

    MainView = Backbone.View.extend {

        el       : $ '#main'

        delay    : null

        open_fail: false

        initialize : ->
            $(window).on 'beforeunload', @beforeunloadEvent
            $(document).on 'keydown', @globalKeyEvent

            # for stack store open
            $(window).on 'focus', () ->
                if window.App and App.openSampleStack
                    App.openSampleStack()

        showMain : ->

            that = @

            console.log 'showMain'
            #
            @toggleWaiting() if $( '#waiting-bar-wrapper' ).hasClass 'waiting-bar'
            #
            clearTimeout @delay if @delay
            #
            MC.data.loading_wrapper_html = $( '#loading-bar-wrapper' ).html() if !MC.data.loading_wrapper_html
            #
            return if $( '#loading-bar-wrapper' ).html().trim() is ''
            #
            target = $('#loading-bar-wrapper').find( 'div' )
            target.fadeOut 'normal', () ->
                target.remove()
                $( '#wrapper' ).removeClass 'main-content'
            #
            delete MC.open_failed_list[ MC.data.current_tab_id ] if not @open_fail
            @open_fail = false
            #
            null

        showLoading : ( tab_id, is_transparent ) ->
            console.log 'showLoading, tab_id = ' + tab_id + ' , is_transparent = ' + is_transparent
            $( '#loading-bar-wrapper' ).html if !is_transparent then MC.data.loading_wrapper_html else MC.template.loadingTransparent()
            #
            me = this
            #
            @delay = setTimeout () ->
                console.log 'setTimeout close loading'
                if $( '#loading-bar-wrapper' ).html().trim() isnt ''
                    me.open_fail = true
                    ide_event.trigger ide_event.SWITCH_MAIN
                    #ide_event.trigger ide_event.CLOSE_DESIGN_TAB, tab_id if tab_id
                    #notification 'error', lang.ide.IDE_MSG_ERR_OPEN_TAB, true
                    ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, 'OPEN_TAB_FAIL', tab_id
            , 1000 * 30
            #
            null

        toggleWaiting : () ->
            console.log 'toggleWaiting'
            $( '#waiting-bar-wrapper' ).removeClass 'waiting-bar'
            #
            @hideStatubar()

        showDashbaordTab : () ->
            console.log 'showDashbaordTab'
            console.log 'MC.data.dashboard_type = ' + MC.data.dashboard_type
            if MC.data.dashboard_type is 'OVERVIEW_TAB' then this.showOverviewTab() else this.showRegionTab()
            #
            @hideStatubar()

        showOverviewTab : () ->
            console.log 'showOverviewTab'
            #
            $( '#tab-content-dashboard' ).addClass  'active'
            $( '#tab-content-region' ).removeClass  'active'
            $( '#tab-content-design' ).removeClass  'active'
            $( '#tab-content-process' ).removeClass 'active'
            #

        showRegionTab : () ->
            console.log 'showRegionTab'
            #
            $( '#tab-content-region' ).addClass       'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-design' ).removeClass    'active'
            $( '#tab-content-process' ).removeClass   'active'
            #

        showTab : () ->
            console.log 'showTab'
            #
            $( '#tab-content-design' ).addClass       'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-region' ).removeClass    'active'
            $( '#tab-content-process' ).removeClass   'active'
            #
            @hideStatubar()
            #
            null

        showProcessTab : () ->
            console.log 'showProcessTab'
            #
            $( '#tab-content-process' ).addClass      'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-region' ).removeClass    'active'
            $( '#tab-content-design' ).removeClass    'active'
            #
            @hideStatubar()

        beforeunloadEvent : ->

            # temp when proces tab return
            #if Tabbar.current is 'process'
            #    return

            # ie 10 not check
            if MC.browser is 'msie' and MC.browserVersion is 10
                return

            if not ( App and App.user and App.user.get( "session" ) )
                return

            #return if MC.data.current_tab_id in [ 'dashboard', undefined ]
            #return if MC.data.current_tab_id.split( '-' )[0] in [ 'process' ]

            #if _.isEqual( MC.canvas_data, MC.data.origin_canvas_data )
            #    return undefined
            #else
            #    return lang.ide.BEFOREUNLOAD_MESSAGE

            has_refresh = true
            checked_tab_id = null

            #if Tabbar.current is 'dashboard'
            #    _.each MC.tab, ( item, id ) ->
            #        if not _.isEqual( item.data, item.origin_data ) and id.split('-') isnt 'appview'
            #            has_refresh = false
            #            null
            #else
            #
            #    # MC.tab is {}
            #    if not MC.tab[ MC.data.current_tab_id ]
            #
            #        if not _.isEqual( MC.canvas_data, MC.data.origin_canvas_data ) and MC.canvas_data.id and MC.canvas_data.id isnt 'appview'
            #            has_refresh = false
            #
            #    # MC.tab isnt {}
            #    _.each MC.tab, ( item, id ) ->
            #        console.log 'sdfasdfasdf', id, item
            #        if not _.isEqual( item.data, item.origin_data ) and id.split('-') isnt 'appview'
            #            has_refresh = false
            #            null

            # when current tab not 'dashboard' 'appview' 'process' and MC.canvas_data not {} MC.data.origin_canvas_data not {}

            # old design flow
            #if not _.isEmpty( MC.canvas_data ) and not _.isEmpty( MC.data.origin_canvas_data ) and Tabbar.current not in [ 'dashboard', 'appview', 'process' ]

            # new design flow
            if not _.isEmpty( MC.common.other.canvasData.data() ) and not _.isEmpty( MC.common.other.canvasData.origin() ) and Tabbar.current not in [ 'dashboard', 'appview', 'process' ]

                # old design flow +++++++++++++++++++++++++++
                #data        = $.extend true, {}, MC.canvas_data
                #origin_data = $.extend true, {}, MC.data.origin_canvas_data

                #if _.isEqual data, origin_data
                # old design flow +++++++++++++++++++++++++++

                # new design flow
                if not MC.common.other.canvasData.isModified()

                    #has_refresh = true
                    console.log 'current equal #1'
                else
                    has_refresh = false

                # set current tab id

                # old design flow
                #checked_tab_id = MC.canvas_data.id

                # new design flow
                checked_tab_id = MC.common.other.canvasData.get 'id'

            else
                #has_refresh = true
                console.log 'current equal #2'

            # loop MC.tab
            _.each MC.tab, ( item, id ) ->
                console.log 'beforeunload current tab item', id, item

                # when id is 'appview' allow refresh
                if id.split('-')[0] is 'appview'
                    #has_refresh = true
                    console.log 'current equal #3'

                # when id isnt 'appview' check refresh
                else

                    # current item data and origin_data
                    if not _.isEqual( item.data, item.origin_data ) and id isnt checked_tab_id
                        has_refresh = false

                    else
                        #has_refresh = true
                        console.log 'current equal #4'

                has_refresh

            console.log 'If I can refresh', has_refresh
            #return lang.ide.BEFOREUNLOAD_MESSAGE

            if has_refresh
                return undefined
            else
                return lang.ide.BEFOREUNLOAD_MESSAGE

        hideStatubar : ->
            console.log 'hideStatubar'
            if $.trim( $( '#status-bar-modal' ).html() )
                $( '#status-bar-modal' ).empty()
                $( '#status-bar-modal' ).hide()
                ide_event.trigger ide_event.UNLOAD_TA_MODAL

        globalKeyEvent: (event) ->

            nodeName = event.target.nodeName.toLowerCase()

            # Disable borwser go back [backspace]
            if event.which is 8 and nodeName isnt 'input' and nodeName isnt 'textarea' and event.target.contentEditable isnt 'true'
                return false

            # Open short key cheat sheet [/ || ?]
            if event.which is 191 and nodeName isnt 'input' and nodeName isnt 'textarea' and event.target.contentEditable isnt 'true'
                modal MC.template.shortkey(), true
                return false

    }

    view = new MainView()

    return view
