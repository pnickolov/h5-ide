####################################
#  Controller for design/property/eni module
####################################

define [ "../base/main",
         "./model",
         "./view",
         "./app_model",
         "./app_view",
         "../sglist/main",
         'event',
         "constant"
], ( PropertyModule, model, view, app_model, app_view, sglist_main, ide_event, constant )->

    ideEvents = {}
    ideEvents[ ide_event.PROPERTY_REFRESH_ENI_IP_LIST ] = () ->
        @model.getIpList()
        @view.refreshIpList()
        null

    EniModule = PropertyModule.extend {

        ideEvents : ideEvents

        handleTypes : [ constant.RESTYPE.ENI, "component_eni_group" ]

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        initStack : () ->
            @model = model
            @model.isAppEdit   = false
            @model.isGroupMode = false
            @view  = view
            null

        afterLoadStack : () ->
            if not @model.attributes.association
                sglist_main.loadModule @model

        initApp : () ->
            @model = app_model
            @model.isGroupMode = @handle is "component_eni_group"
            @view  = app_view
            null

        afterLoadApp : () ->
            if not @model.isGroupMode
                sglist_main.loadModule @model
            null

        initAppEdit : () ->
            @model = model
            @model.isAppEdit = true
            @view  = view
            null

        afterLoadAppEdit : () ->
            sglist_main.loadModule @model
            null
    }
    null
