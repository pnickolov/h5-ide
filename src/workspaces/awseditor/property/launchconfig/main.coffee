####################################
#  Controller for design/property/launchconfig module
####################################


define [ "../base/main",
         "./model",
         "./view",
         "./app_view",
         "../sglist/main",
         "constant",
         "event"
], ( PropertyModule, model, view, app_view, sglist_main, constant, ide_event ) ->

    model.on "KP_DOWNLOADED", (data, option)->
        app_view.updateKPModal(data, option)

    app_view.on "OPEN_AMI", (id)->
        PropertyModule.loadSubPanel "STATIC", id

    view.on "OPEN_AMI", (id)->
        PropertyModule.loadSubPanel "STATIC", id

    LCModule = PropertyModule.extend {

        handleTypes : constant.RESTYPE.LC

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        initStack : () ->
            @model = model
            @model.isApp = false
            @view  = view
            null

        afterLoadStack : () ->
            sglist_main.loadModule @model
            null

        initApp : () ->
            @model = model
            @model.isApp = true
            @view  = app_view
            null

        initAppEdit : () ->
            @model = model
            @model.isApp = true
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null

        afterLoadAppEdit : () ->
            sglist_main.loadModule @model
            null
    }
    null
