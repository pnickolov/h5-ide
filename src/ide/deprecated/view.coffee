#############################
#  View(UI logic) for Main
#############################

define [ 'event',
         'i18n!nls/lang.js',
         'UI.notification',
         'UI.tour',
         'backbone', 'jquery', 'handlebars', 'underscore' ], ( ide_event, lang ) ->

    MainView = Backbone.View.extend {

        delay    : null

        open_fail: false

        initialize : ->
            $(window).on 'beforeunload', @beforeunloadEvent
            $(document).on 'keydown', @globalKeyEvent

            # for stack store open
            $(window).on 'focus', () ->
                if window.App and App.openSampleStack
                    App.openSampleStack()

        toggleWaiting : () ->
            console.log 'toggleWaiting'
            $( '#waiting-bar-wrapper' ).removeClass 'waiting-bar'
            #
            @hideStatubar()

        beforeunloadEvent : ->
            return

            # ie 10 not check
            if MC.browser is 'msie' and MC.browserVersion is 10
                return

            if not ( window.App and App.user and App.user.get( "session" ) )
                return

            #if _.isEqual( MC.canvas_data, MC.data.origin_canvas_data )
            #    return undefined
            #else
            #    return lang.ide.BEFOREUNLOAD_MESSAGE

            has_refresh = true
            checked_tab_id = null

            # new design flow
            if not true

                # old design flow +++++++++++++++++++++++++++
                #data        = $.extend true, {}, MC.canvas_data
                #origin_data = $.extend true, {}, MC.data.origin_canvas_data

                #if _.isEqual data, origin_data
                # old design flow +++++++++++++++++++++++++++

                # new design flow
                    #has_refresh = true
                    console.log 'current equal #1'
                else
                    has_refresh = false

                # set current tab id

                # old design flow
                #checked_tab_id = MC.canvas_data.id

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

    new MainView()
