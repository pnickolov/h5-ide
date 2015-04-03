####################################
#  Controller for design/property/stack module
####################################

define [ '../base/main',
         './model',
         './view',
         '../sglist/main',
         'event',
         "Design"
], ( PropertyModule, model, view, sglist_main, ide_event, Design ) ->

    view.on 'OPEN_ACL', ( uid ) ->
        PropertyModule.loadSubPanel( "ACL", uid )
        null


    # ide_events handlers are called with the scope ( this ) of current property.
    StackModule = PropertyModule.extend {

        handleTypes : [ "Stack", "default" ]

        onUnloadSubPanel : ( id )->

            sglist_main.onUnloadSubPanel id

            if id is "ACL"
                @model.getNetworkACL()
                @view.refreshACLList()

        ### # # # # # # # # # # # #
        # For stack mode
        ###

        # In initStack, all we have to do is to assign this.model / this.view
        initStack : ( uid ) ->
            @model = model
            @model.isApp = false
            @model.isAppEdit = false
            @model.isStack = true
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
            @model.isAppEdit = false
            @model.isStack = false
            @view  = view

            opsModel = Design.instance().opsModel()
            if opsModel.isMesos()
                @view.listenTo opsModel.getMesosData(), 'change', view.renderMesosData

            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null

        ### # # # # # # # # # #
        ###

        initAppEdit : ()->
            @model = model
            @model.isApp = false
            @model.isAppEdit = true
            @model.isStack = false
            @view  = view
            null

        afterLoadAppEdit : () ->
            sglist_main.loadModule @model
            null
    }

    null
