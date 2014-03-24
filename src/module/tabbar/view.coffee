#############################
#  View(UI logic) for tabbar
#############################

define [ 'event',
         './module/tabbar/template',
         'backbone', 'jquery', 'handlebars', 'UI.tabbar'
], ( ide_event, tmpl ) ->

    TabBarView = Backbone.View.extend {

        el       : $( '#tab-bar' )

        template : tmpl

        events   :
            'OPEN_TAB'              : 'openTabEvent'
            'CLOSE_TAB'             : 'closeTabEvent'
            'CLOSE_TAB_RESTRICTION' : 'closeTabRestrictionEvent'

        initialize : ->

            #$( document.body ).on 'click', '.new-stack-dialog',          this, @openNewStackDialog
            $( document.body ).on 'click', '#reload-account-attributes', this, @reloadAccountAttributes
            $( document.body ).on 'click', '#close-tab-confirm',         this, @closeTabConfirmEvent

            @listenTo ide_event, 'UPDATE_DESIGN_TAB_ICON', @updateTabIcon

        render   : () ->
            console.log 'tabbar render'
            $( this.el ).html this.template()

        reloadAccountAttributes: () ->
             window.location.reload()

        #############################
        #  OPEN_TAB
        #############################

        openTabEvent  : ( event, original_tab_id, tab_id ) ->
            console.log 'openTabEvent'
            console.log 'original_tab_id = ' + original_tab_id + ', tab_id = ' + tab_id

            if original_tab_id is tab_id
                return

            # set current tab id
            MC.common.other.setCurrentTabId tab_id

            # get tab_type
            tab_type = tab_id.split( '-' )[0]

            switch tab_type
                when 'dashboard'
                    this.trigger 'SWITCH_DASHBOARD',     original_tab_id, tab_id
                when 'new'
                    this.trigger 'SWITCH_NEW_STACK_TAB', original_tab_id, tab_id, $( '#tab-bar-' + tab_id ).find('a').attr('title')
                when 'stack', 'import'
                    this.trigger 'SWITCH_STACK_TAB',     original_tab_id, tab_id
                when 'app', 'appview'
                    this.trigger 'SWITCH_APP_TAB',       original_tab_id, tab_id
                when 'process'
                    this.trigger 'SWTICH_PROCESS_TAB',   original_tab_id, tab_id
                else
                    console.log 'no find tab type'

            null

        #############################
        #  update
        #############################

        updateCurrentTab : ( tab_id, tab_name ) ->
            console.log 'updateCurrentTab', tab_id, tab_name

            original_tab_id = null

            _.each $( '.tabbar-group' ).children(), ( item ) ->
                if $( item ).attr( 'class' ) is 'active'
                    console.log $( item )

                    # update temp html tag property
                    $( item ).attr 'id', 'tab-bar-' + tab_id
                    temp = $( $( item ).find( 'a' )[0] )

                    # get origin tab id
                    original_tab_id = temp.attr 'data-tab-id'

                    # reset
                    temp.attr 'title',       tab_name
                    temp.attr 'data-tab-id', tab_id
                    temp.attr 'href',        '#tab-content-' + tab_id
                    temp.html temp.find( 'i' ).get( 0 ).outerHTML + tab_name

                    # set Tabbar.current
                    ide_event.trigger ide_event.UPDATE_DESIGN_TAB_TYPE, tab_id, tab_id.split( '-' )[0]

                    null

            original_tab_id

        updateTabIcon : ( type, tab_id ) ->
            console.log 'updateTabIcon, type = ' + type + ', tab_id = ' + tab_id

            _.each $( '.tabbar-group' ).children(), ( item ) ->

                $item = $ item

                if $item.attr( 'id' ) is 'tab-bar-' + tab_id

                    switch type
                        when 'stack'
                            classname = 'icon-stack-tabbar'

                        when 'visualization'
                            classname = 'icon-' + type + '-tabbar'

                        else
                            # app xxxx
                            classname = 'icon-app-' + type.toLowerCase()

                    #if type is 'stack' then classname = 'icon-stack-tabbar' else classname = 'icon-app-' + type.toLowerCase()
                    $item.find( 'i' ).removeClass()
                    $item.find( 'i' ).addClass 'icon-tabbar-label ' + classname

        updateTabCloseState : ( tab_id ) ->
            console.log 'updateTabCloseState, tab_id = ' + tab_id
            close_target = $( '#tab-bar-' + tab_id ).children( '.icon-close' )
            close_target.removeClass 'close-restriction'
            close_target.addClass    'close-tab'
            close_target.addClass    'auto-close'

        #############################
        #  close
        #############################

        closeTabEvent : ( event, tab_id ) ->
            console.log 'closeTabEvent'
            ide_event.trigger ide_event.DELETE_TAB_DATA, tab_id
            null

        # restriction close tab
        closeTabRestrictionEvent : ( event, target, tab_name, tab_id ) ->
            console.log 'closeTabRestrictionEvent', tab_name, tab_id

            # process direct close
            if tab_id.split( '-' )[0] in [ 'process', 'appview' ] or ( tab_id is MC.data.current_tab_id and Tabbar.current is 'app' )
                @directCloseTab tab_id
                return

            # old design flow +++++++++++++++++++++++++++
            # stack app check _.isEqual
            #if MC.data.current_tab_id is tab_id
            #    data        = $.extend true, {}, MC.canvas_data
            #    origin_data = $.extend true, {}, MC.data.origin_canvas_data
            #else
            #    data        = $.extend true, {}, MC.tab[ tab_id ].data
            #    origin_data = $.extend true, {}, MC.tab[ tab_id ].origin_data
            #
            #if _.isEqual( data, origin_data )
            #    @directCloseTab tab_id
            #else
            #    modal MC.template.closeTabRestriction { 'tab_name' : tab_name, 'tab_id' : tab_id }, true
            # old design flow +++++++++++++++++++++++++++

            # new design flow +++++++++++++++++++++++++++
            is_changed = true
            if MC.data.current_tab_id is tab_id
                is_changed = MC.common.other.canvasData.isModified()
            else
                is_changed  = MC.tab[ tab_id ].design_model.isModified()

            if not is_changed
                @directCloseTab tab_id
            else
                modal MC.template.closeTabRestriction { 'tab_name' : tab_name, 'tab_id' : tab_id }, true
            # new design flow +++++++++++++++++++++++++++

            null

        closeTabConfirmEvent : ( event ) ->
            console.log 'closeTabConfirmEvent, tab_id = ' + $( event.currentTarget ).attr 'data-tab-id'
            event.data.directCloseTab $( event.currentTarget ).attr 'data-tab-id'
            modal.close()

        # direct close tab
        directCloseTab : ( tab_id ) ->
            console.log 'directCloseTab', tab_id

            # update tab close state
            @updateTabCloseState tab_id

            # close design tab
            _.delay () ->
                ide_event.trigger ide_event.CLOSE_DESIGN_TAB, tab_id
            , 150

            null

        closeTab   : ( tab_id ) ->
            console.log 'closeTab', tab_id

            if $( '#tab-bar-' + tab_id ).length is 0
                return

            $target = $ $('#tab-bar-' + tab_id).find('a')[1]

            # if class include 'close-restriction' call updateTabCloseState
            if $target.attr( 'class' ).indexOf( 'close-restriction' ) isnt -1
                # update tab close state
                @updateTabCloseState tab_id

            # close design tab
            _.delay () ->
                $target.trigger 'click'
            , 150

            null

        #############################
        #  other
        #############################

        changeDashboardTabname   : ( tab_name ) ->
            console.log 'changeDashboardTabname'
            $( '#tab-bar-dashboard' ).children().html '<i class="icon-dashboard icon-tabbar-label"></i>' + tab_name
            null

        openNewStackDialog : () ->
            console.log 'openNewStackDialog'
            #console.log $( event.currentTarget ).attr 'data-supported-platform'
            #event.data.trigger 'SELECE_PLATFORM', $( event.currentTarget ).attr 'data-supported-platform'

            @trigger 'SELECE_PLATFORM', 'ec2-vpc'

            null

    }

    return TabBarView
