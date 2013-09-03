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
            #save
            #if older isnt 'dashboard' then MC.tab[ older ] = { snapshot : null, data : null }
            #test
            #if older isnt 'dashboard' and older isnt null then MC.tab[ older ] = { snapshot : older, data : older }
            if older isnt 'dashboard' and older isnt null then this.trigger 'SAVE_DESIGN_MODULE', older

            if newer is 'dashboard'
                this.trigger 'SWITCH_DASHBOARD'
                return

            if MC.tab[ newer ] is undefined
                console.log 'write newer from MC.tab'
                suffix = 'OPEN_'
            else
                console.log 'read older from MC.tab'
                console.log MC.tab[ newer ]
                suffix = 'OLD_'

            switch type
                when 'new'
                    if suffix is 'OLD_' then event_type = suffix + 'STACK' else event_type = 'NEW_STACK'
                when 'stack'
                    event_type = suffix + 'STACK'
                when 'app'
                    event_type = suffix + 'APP'
                when 'process'
                    event_type = suffix + 'PROCESS'
                else
                    console.log 'no find tab type'

            console.log 'event_type = ' + event_type
            #
            MC.data.current_tab_type = event_type
            #
            this.trigger event_type, newer

            ###
            if MC.tab[ newer ] is undefined
                console.log 'write newer from MC.tab'
                #push event
                if type is 'new'
                    this.trigger 'NEW_STACK',    newer
                else if type is 'stack'
                    this.trigger 'OPEN_STACK',   newer
                else if type is 'app'
                    this.trigger 'OPEN_APP',     newer
                else if type is 'process'
                    this.trigger 'OPEN_PROCESS', newer
            else
                console.log 'read older from MC.tab'
                console.log MC.tab[ newer ]
                #push event
                if type is 'new'
                    this.trigger 'OLD_STACK',   newer
                else if type is 'stack'
                    this.trigger 'OLD_STACK',   newer
                else if type is 'app'
                    this.trigger 'OLD_APP',     newer
                else if type is 'process'
                    this.trigger 'OLD_PROCESS', newer
            ###

            console.log MC.tab

        ###
        delete       : ( newer ) ->
            console.log 'delete'
            delete MC.tab[ newer ]
            console.log MC.tab
        ###

        getStackInfo : ( stack_id ) ->
            console.log 'getStackInfo'
            #get this
            me = this
            stack_model.info { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), this.get( 'stack_region_name' ), [ stack_id ]

        getAppInfo : ( app_id ) ->
            console.log 'getAppInfo'
            #get this
            me = this
            app_model.info { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), this.get( 'app_region_name' ), [ app_id ]

        checkPlatform : ( region_name ) ->
            console.log 'checkPlatform'
            #
            if !MC.data.supported_platforms then return
            #
            support_vpc = false
            #
            _.each MC.data.supported_platforms, ( item ) ->
                if region_name is item.region
                    if item.classic then support_vpc = true else support_vpc = false
                null
            #
            support_vpc

    }

    model = new TabbarModel()

    return model