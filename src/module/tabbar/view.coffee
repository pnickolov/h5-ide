#############################
#  View(UI logic) for tabbar
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    TabBarView = Backbone.View.extend {

        el       : $( '#tab-bar' )

        template : Handlebars.compile $( '#tabbar-tmpl' ).html()

        events   :
            'OPEN_TAB'  : 'openTabEvent'
            'CLOSE_TAB' : 'closeTabEvent'

        initialize : ->
            #listen
            $( document ).on 'click', '.new-stack-dialog', this, this.openNewStackDialog

        render   : () ->
            console.log 'tabbar render'
            $( this.el ).html this.template()

        openTabEvent  : ( event, original_tab_id, tab_id ) ->
            console.log 'openTab'
            console.log 'original_tab_id = ' + original_tab_id + ', tab_id = ' + tab_id
            #console.log $( '#tab-bar-' + tab_id ).children().attr 'title'
            #
            if original_tab_id is tab_id then return
            #
            tab_type = tab_id.split( '-' )[0]

            switch tab_type
                when 'dashboard'
                    this.trigger 'SWITCH_DASHBOARD',     original_tab_id, tab_id
                when 'new'
                    this.trigger 'SWITCH_NEW_STACK_TAB', original_tab_id, tab_id, $( '#tab-bar-' + tab_id ).find('a').attr('title')
                when 'stack'
                    this.trigger 'SWITCH_STACK_TAB',     original_tab_id, tab_id
                when 'app'
                    this.trigger 'SWITCH_APP_TAB',       original_tab_id, tab_id
                when 'process'
                    this.trigger 'SWTICH_PROCESS_TAB',   original_tab_id, tab_id
                else
                    console.log 'no find tab type'

            ###
            if tab_id is 'dashboard'
                this.trigger 'SWITCH_DASHBOARD', original_tab_id, tab_id
                return

            if $( '#tab-bar-' + tab_id ).children().attr( 'title' ).split( ' - ' )[0] is 'untitled'
                #NEW_STACK
                this.trigger 'SWITCH_NEW_STACK_TAB', original_tab_id, tab_id, $( '#tab-bar-' + tab_id ).find('a').attr('title')
            else if $( '#tab-bar-' + tab_id ).children().attr( 'title' ).split( ' - ' )[1] is 'stack'
                #OPEN_STACK
                this.trigger 'SWITCH_STACK_TAB', original_tab_id, tab_id
            else if tab_id.split( '-' )[0] is 'process'
                #PROCESS_APP
                this.trigger 'SWTICH_PROCESS_TAB', original_tab_id, tab_id
            else if $( '#tab-bar-' + tab_id ).children().attr( 'title' ).split( ' - ' )[1] is 'app'
                #OPEN_APP
                this.trigger 'SWITCH_APP_TAB', original_tab_id, tab_id
            ###
            null

        closeTabEvent : ( event, tab_id ) ->
            console.log 'closeTab'
            #push event
            this.trigger 'CLOSE_STACK_TAB',  tab_id
            null

        changeIcon : ( tab_id ) ->
            console.log 'changeIcon'
            console.log $( '#tab-bar-' + tab_id ).children().find( 'i' ).attr( 'class' )
            null

        closeTab   : ( tab_id ) ->
            console.log 'closeTab'
            $( '#tab-bar-' + tab_id ).children().last().trigger( 'mousedown' )
            null

        changeDashboardTabname   : ( tab_name ) ->
            console.log 'changeDashboardTabname'
            $( '#tab-bar-dashboard' ).children().html '<i class="icon-dashboard-tabbar icon-tabbar-label"></i>' + tab_name
            null

        openNewStackDialog : ( event ) ->
            console.log 'openNewStackDialog'
            console.log $( event.currentTarget ).attr 'data-supported-platform'
            event.data.trigger 'SELECE_PLATFORM', $( event.currentTarget ).attr 'data-supported-platform'
            null

        updateCurrentTab : ( tab_id, tab_name ) ->
            console.log 'updateCurrentTab'
            original_tab_id = null
            _.each $( '.tabbar-group' ).children(), ( item ) ->
                if $( item ).attr( 'class' ) is 'active'
                    console.log $( item )
                    #
                    $( item ).attr 'id', 'tab-bar-' + tab_id
                    #
                    temp = $( $( item ).find( 'a' )[0] )
                    #
                    original_tab_id = temp.attr 'data-tab-id'
                    #
                    temp.attr 'title',       tab_name
                    temp.attr 'data-tab-id', tab_id
                    temp.attr 'href',        '#tab-content-' + tab_id
                    temp.text tab_name
                    null
            return original_tab_id
    }

    return TabBarView