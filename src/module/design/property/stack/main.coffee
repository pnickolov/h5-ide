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

            @view.on 'STACK_NAME_CHANGED', ( name ) ->
                MC.canvas_data.name = name
                ide_event.trigger ide_event.UPDATE_DESIGN_TAB, MC.canvas_data.id, name + ' - stack'
                null

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

        afterLoadAppEdit : () ->
            sglist_main.loadModule @model
            null


        renderPropertyPanel : () ->
            @model.getProperty()
            @view.render()
            sglist_main.loadModule @model
    }

    null
