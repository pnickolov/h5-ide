#############################
#  View Mode for navigation
#############################

define [ 'MC', 'backbone' ], ( MC ) ->

    #private
    TabbarModel = Backbone.Model.extend {

        refresh : ( old, current ) ->
            console.log 'refresh'
            #save
            #if old isnt 'dashboard' then MC.tab[ old ] = { snapshot : null, data : null }
            #test
            if old isnt 'dashboard' then MC.tab[ old ] = { snapshot : old, data : old }

            if MC.tab[ current ] is undefined
                #call service
                console.log 'call new stack'
            else
                #read from MC.tab[ current ]
                console.log 'read old stack from MC.tab'
                console.log MC.tab[ current ]

            console.log MC.tab

        delete : ( current ) ->
            console.log 'delete'
            delete MC.tab[ current ]
            console.log MC.tab

    }

    model = new TabbarModel()

    return model