#############################
#  View(UI logic) for tabbar
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    TabBarView = Backbone.View.extend {

        el       : $( '#tab-bar' )

        template : Handlebars.compile $( '#tabbar-tmpl' ).html()

        events   :
            'OPEN_TAB'  : 'openTab'
            'CLOSE_TAB' : 'closeTab'

        render   : () ->
            console.log 'tabbar render'
            $( this.el ).html this.template()

        openTab  : ( event, original_tab_id, tab_id ) ->
            console.log 'openTab'
            console.log $( '#tab-bar-' + tab_id ).children().attr 'title'

            if tab_id is 'dashboard'
                this.trigger 'SWITCH_DASHBOARD', 'dashboard'
                return

            if $( '#tab-bar-' + tab_id ).children().attr( 'title' ).split( ' - ' )[1] is 'stack'
                #push event
                 this.trigger 'SWITCH_STACK_TAB', original_tab_id, tab_id
            else
                #push event
                this.trigger 'SWITCH_APP_TAB', original_tab_id, tab_id
            null

        closeTab : ( event, tab_id ) ->
            console.log 'closeTab'
            #push event
            this.trigger 'CLOSE_STACK_TAB',  tab_id
            null
    }

    return TabBarView