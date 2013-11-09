####################################
#  Controller for design/property/instance module
####################################

define [ "../base/main",
         "./app_model",
         "./app_view",
         "../sglist/main",
         "constant",
         "event"
], ( PropertyModule,
     app_model, app_view,
     sglist_main, constant, ide_event ) ->

    ideEvents = {}
    ideEvents[ ide_event.PROPERTY_REFRESH_ENI_IP_LIST ] = () ->
        @model.getEni()
        @view.refreshIPList()
        null

    ServerGroupModule = PropertyModule.extend {

        ideEvents : ideEvents

        handleTypes : 'component_server_group'

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        initApp : ()->
            @model = app_model
            @model.isAppEdit = false
            @view  = app_view
            null

        setupAppEdit : () ->
            @view.on "OPEN_AMI", (id) ->
                PropertyModule.loadSubPanel "STATIC", id
            null

        initAppEdit : ()->
            @model = app_model
            @model.isAppEdit = true
            @view  = app_view
            null

        afterLoadAppEdit : ()->
            sglist_main.loadModule @model
            null
    }
    null
