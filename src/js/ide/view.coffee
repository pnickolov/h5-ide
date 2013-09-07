#############################
#  View(UI logic) for Main
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'UI.notification',
         'backbone', 'jquery', 'handlebars', 'underscore' ], ( ide_event, lang ) ->

    MainView = Backbone.View.extend {

        el       : $ '#main'

        delay    : null

        initialize : ->

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
            $( '.loading-wrapper' ).fadeOut 'normal', () ->
                $( '.loading-wrapper' ).remove()
                $( '#wrapper' ).removeClass 'main-content'

        showLoading : ( tab_id ) ->
            console.log 'showLoading, tab_id = ' + tab_id
            $( '#loading-bar-wrapper' ).html MC.data.loading_wrapper_html
            #
            @delay = setTimeout () ->
                console.log 'setTimeout close loading'
                if $( '#loading-bar-wrapper' ).html().trim() isnt ''
                    ide_event.trigger ide_event.SWITCH_MAIN
                    ide_event.trigger ide_event.STACK_DELETE, null, tab_id
                    notification 'error', lang.ide.IDE_MSG_ERR_OPEN_TAB, true
            , 1000 * 30
            null

        toggleWaiting : () ->
            console.log 'toggleWaiting'
            $( '#waiting-bar-wrapper' ).toggleClass 'waiting-bar'

        showDashbaordTab : () ->
            console.log 'showDashbaordTab'
            console.log 'MC.data.dashboard_type = ' + MC.data.dashboard_type
            if MC.data.dashboard_type is 'OVERVIEW_TAB' then this.showOverviewTab() else this.showRegionTab()

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

        showProcessTab : () ->
            console.log 'showProcessTab'
            #
            $( '#tab-content-process' ).addClass      'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-region' ).removeClass    'active'
            $( '#tab-content-design' ).removeClass    'active'
            #

        disconnectedMessage : ( type ) ->
            console.log 'disconnectedMessage'
            #
            return if $( '#disconnected-notification-wrapper' ).html() and type is 'show'
            #
            if type is 'show'
                $( '#disconnected-notification-wrapper' ).html MC.template.disconnectedNotification()
            else
                $( '#disconnected-notification-wrapper' ).empty()
    }

    view = new MainView()

    return view
