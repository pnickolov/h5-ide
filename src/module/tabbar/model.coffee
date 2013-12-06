#############################
#  View Mode for navigation
#############################

define [ 'MC', 'stack_model', 'app_model', 'backbone', 'event' ], ( MC, stack_model, app_model, ide_event ) ->

    #private
    TabbarModel = Backbone.Model.extend {

        defaults     :
            stack_region_name : null
            app_region_name   : null
            current_platform  : null
            tab_name          : null

        initialize : ->

            me = this

            #####listen STACK_INFO_RETURN
            me.on 'STACK_INFO_RETURN', ( result ) ->
                console.log 'STACK_INFO_RETURN'
                me.trigger 'GET_STACK_COMPLETE', result

            #####listen APP_INFO_RETURN
            me.on 'APP_INFO_RETURN', ( result ) ->
                console.log 'APP_INFO_RETURN'
                me.trigger 'GET_APP_COMPLETE', result

        refresh      : ( older, newer, type ) ->
            console.log 'refresh, older = ' + older + ', newer = ' + newer + ', type = ' + type
            console.log 'Tabbar.current = ' + Tabbar.current

            # save old tab
            if older isnt 'dashboard' and older isnt null
                @trigger 'SAVE_DESIGN_MODULE', older

            # dashboard and return
            if newer is 'dashboard'
                @trigger 'SWITCH_DASHBOARD'
                return

            # process include 'process' and 'appview'
            if Tabbar.current is 'process'

                # when MC.forge.other.getCacheMap( newer ).state is 'OLD' this id is older
                if MC.forge.other.processType( newer ) is 'appview' and MC.forge.other.getCacheMap( newer ).state is 'OLD'
                    suffix = 'OLD_'

                else
                    suffix = 'OPEN_'

            # appview always old tab
            else if Tabbar.current is 'appview'

                suffix = 'OLD_'

            # new tab
            else if MC.tab[ newer ] is undefined
                console.log 'write newer from MC.tab'
                suffix = 'OPEN_'

            # old tab
            else
                console.log 'read older from MC.tab'
                console.log MC.tab[ newer ]
                suffix = 'OLD_'

            switch type
                when 'new'
                    if suffix is 'OLD_' then event_type = suffix + 'STACK' else event_type = 'NEW_STACK'
                when 'stack'
                    event_type = suffix + 'STACK'
                when 'app', 'appview'
                    event_type = suffix + 'APP'
                when 'process'
                    event_type = suffix + 'PROCESS'
                else
                    console.log 'no find tab type'

            console.log 'event_type = ' + event_type

            # set current tab type
            MC.data.current_tab_type = event_type

            # push event
            @trigger event_type, newer

            console.log MC.tab

            null

        getStackInfo : ( stack_id ) ->
            console.log 'getStackInfo'
            me = this
            stack_model.info { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), this.get( 'stack_region_name' ), [ stack_id ]

        getAppInfo : ( app_id ) ->
            console.log 'getAppInfo'
            me = this
            app_model.info { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), this.get( 'app_region_name' ), [ app_id ]

        # return: true|false|null
        checkPlatform : ( region_name ) ->
            console.log 'checkPlatform', region_name

            support_vpc = null

            _.each MC.data.supported_platforms, ( item ) ->
                if region_name is item.region
                    if item.classic then support_vpc = true else support_vpc = false
                null

            support_vpc

    }

    model = new TabbarModel()

    return model