#############################
#  View(UI logic) for Main
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'forge_handle',
         'UI.notification',
         'backbone', 'jquery', 'handlebars', 'underscore' ], ( ide_event, lang, forge_handle ) ->

    MainView = Backbone.View.extend {

        el       : $ '#main'

        delay    : null

        open_fail: false

        initialize : ->
            $( window ).on 'beforeunload', @_beforeunloadEvent

        showMain : ->
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
            $( '#waiting-bar-wrapper' ).toggleClass 'waiting-bar'
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

        disconnectedMessage : ( type ) ->
            $(".disconnected-notification").toggle( type is 'show' )
            null

        _beforeunloadEvent : ->

            # temp when proces tab return
            if Tabbar.current is 'process'
                return

            return if MC.browser is 'msie' and MC.browserVersion is 10

            #return if MC.data.current_tab_id in [ 'dashboard', undefined ]
            return if !forge_handle.cookie.getCookieByName( 'userid' )
            #return if MC.data.current_tab_id.split( '-' )[0] in [ 'process' ]

            #if _.isEqual( MC.canvas_data, MC.data.origin_canvas_data )
            #    return undefined
            #else
            #    return lang.ide.BEFOREUNLOAD_MESSAGE

            has_refresh = true

            if Tabbar.current is 'dashboard'
                _.each MC.tab, ( item ) ->
                    if not _.isEqual( item.data, item.origin_data )
                        has_refresh = false
                        null
            else

                if not MC.tab[ MC.data.current_tab_id ]
                    if not _.isEqual( MC.canvas_data, MC.data.origin_canvas_data )
                        has_refresh = false

                _.each MC.tab, ( item ) ->
                    if not _.isEqual( item.data, item.origin_data )
                        has_refresh = false
                        null

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
    }

    view = new MainView()

    return view
