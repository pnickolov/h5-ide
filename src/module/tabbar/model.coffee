#############################
#  View Mode for navigation
#############################

define [ 'MC', 'stack_model', 'backbone' ], ( MC, stack_model ) ->

    #private
    TabbarModel = Backbone.Model.extend {

        defaults     :
            stack_region_name : null

        refresh      : ( old, current ) ->
            console.log 'refresh'
            #save
            #if old isnt 'dashboard' then MC.tab[ old ] = { snapshot : null, data : null }
            #test
            if old isnt 'dashboard' then MC.tab[ old ] = { snapshot : old, data : old }

            if MC.tab[ current ] is undefined
                #call service
                console.log 'call new stack'
                console.log this.get 'stack_region_name'
                #push new_stack event
                this.trigger 'NEW_STACK', current
            else
                #read from MC.tab[ current ]
                console.log 'read old stack from MC.tab'
                console.log MC.tab[ current ]
                #push old_stack event
                this.trigger 'OLD_STACK', null

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

    }

    model = new TabbarModel()

    return model