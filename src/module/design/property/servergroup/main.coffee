####################################
#  Controller for design/property/instance module
####################################

define [ "../base/main",
         "./app_model",
         "./app_view",
         "../sglist/main",
         "constant"
], ( PropertyModule,
     app_model, app_view,
     sglist_main, constant ) ->

    ServerGroupModule = PropertyModule.extend {

        handleTypes : [ 'component_server_group' ]

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
