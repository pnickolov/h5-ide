####################################
#  Controller for design/property/stack module
####################################

define [ '../base/main',
         './model',
         './view',
         './app_view',
         '../sglist/main',
         'event'
], ( PropertyModule, model, view, app_view, sglist_main, ide_event ) ->

    # Listen shared view events here
    app_view.on 'OPEN_ACL', ( uid ) ->
        PropertyModule.loadSubPanel( "ACL", uid )
        null


    # ide_events handlers are called with the scope ( this ) of current property.
    ideEvents = {}

    ideEvents[ ide_event.RESOURCE_QUICKSTART_READY ] = ()->
        @model.getCost()
        @renderPropertyPanel()
        null

    ideEvents[ ide_event.UPDATE_STACK_LIST ] = ( flag )->
        if flag is 'NEW_STACK'
            @model.init()
            @renderPropertyPanel()
        null

    StackModule = PropertyModule.extend {

        ideEvents : ideEvents

        handleTypes : ""

        onUnloadSubPanel : ( id )->

            sglist_main.onUnloadSubPanel id

            if id is "ACL"
                @view.refreshACLList()

        ### # # # # # # # # # # # #
        # For stack mode
        ###

        # After initStack is called, this method will be called to setup connection between
        # model / view. It is called only once.
        setupStack : () ->
            me = @
            @view.on 'SAVE_SUBSCRIPTION', ( data ) ->
                me.model.addSubscription data
                null

            @view.on 'DELETE_SUBSCRIPTION', ( uid ) ->
                me.model.deleteSNS uid
                null

            @view.on 'STACK_NAME_CHANGED', ( name ) ->
                MC.canvas_data.name = name
                ide_event.trigger ide_event.UPDATE_TABBAR, MC.canvas_data.id, name
                null

            @view.on 'DELETE_STACK_SG', ( uid ) ->
                me.model.deleteSecurityGroup uid

            @view.on 'RESET_STACK_SG', ( uid ) ->
                me.model.resetSecurityGroup uid
                me.renderPropertyPanel()

            @model.on 'UPDATE_SNS_LIST', ( sns_list, has_asg ) ->
                # The view might be app view, because app_model is the same as stack_model.
                if me.view.updateSNSList
                    me.view.updateSNSList sns_list, has_asg

            @view.on 'OPEN_ACL', ( uid ) ->
                PropertyModule.loadSubPanel( "ACL", uid )
                null
            null

        # In initStack, all we have to do is to assign this.model / this.view
        initStack : ( uid ) ->
            @model = model
            @model.isApp = false
            @view  = view
            null

        # This method will be called after this property has rendered
        afterLoadStack : () ->
            sglist_main.loadModule @model
            null

        ### # # # # # # # # # # # #
        # For app mode
        ###

        initApp : ( uid ) ->
            @model = model
            @model.isApp = true
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null

        ### # # # # # # # # # #
        ###

        initAppEdit : ()->
            @model = model
            @model.isApp = true
            @view  = app_view
            null


        renderPropertyPanel : () ->
            @model.getProperty()
            @view.render()
            sglist_main.loadModule @model
    }

    null
