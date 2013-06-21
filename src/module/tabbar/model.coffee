#############################
#  View Mode for navigation
#############################

define [ 'MC', 'stack_model', 'app_model', 'backbone' ], ( MC, stack_model, app_model ) ->

    #private
    TabbarModel = Backbone.Model.extend {

        defaults     :
            stack_region_name : null
            app_region_name   : null

        refresh      : ( old, current, type ) ->
            console.log 'refresh'
            #save
            #if old isnt 'dashboard' then MC.tab[ old ] = { snapshot : null, data : null }
            #test
            if old isnt 'dashboard' and old isnt null then MC.tab[ old ] = { snapshot : old, data : old }

            if MC.tab[ current ] is undefined
                #call service
                console.log 'call new|open stack'
                #push event
                if type is 'new'
                    this.trigger 'NEW_STACK',  current
                else if type is 'stack'
                    this.trigger 'OPEN_STACK', current
                else if type is 'app'
                    this.trigger 'OPEN_APP',   current
                else if type is 'dashboard'
                    this.trigger 'SWITCH_DASHBOARD', null
            else
                #read from MC.tab[ current ]
                console.log 'read old stack from MC.tab'
                console.log MC.tab[ current ]
                #push event
                if type is 'new'
                    this.trigger 'OLD_STACK', current
                else if type is 'stack'
                    this.trigger 'OLD_STACK', current
                else if type is 'app'
                    this.trigger 'OLD_APP',   current

            console.log MC.tab

        delete       : ( current ) ->
            console.log 'delete'
            delete MC.tab[ current ]
            console.log MC.tab

        getStackInfo : ( stack_id ) ->
            console.log 'getStackInfo'
            #get this
            me = this
            stack_model.once 'STACK_INFO_RETURN', ( result ) ->
                console.log 'STACK_INFO_RETURN'
                console.log result
                me.trigger 'GET_STACK_COMPLETE', result
            stack_model.info { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), this.get( 'stack_region_name' ), [ stack_id ]

        getAppInfo : ( app_id ) ->
            console.log 'getAppInfo'
            #get this
            me = this
            app_model.once 'APP_INFO_RETURN', ( result ) ->
                console.log 'APP_INFO_RETURN'
                console.log result
                me.trigger 'GET_APP_COMPLETE', result
            app_model.info { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), this.get( 'app_region_name' ), [ app_id ]

    }

    model = new TabbarModel()

    return model