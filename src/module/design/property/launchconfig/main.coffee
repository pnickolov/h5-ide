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

    LCModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

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

        setupStack : () ->
            me = this
            @model.on "KP_DOWNLOADED", (data, option)->
                me.view.updateKPModal(data, option)

            @view.on "REQUEST_KEYPAIR", (name)->
                me.model.downloadKP(name)

            @view.on "OPEN_AMI", (id)->
                PropertyModule.loadSubPanel "STATIC", id
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
