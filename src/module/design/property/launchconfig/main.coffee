####################################
#  Controller for design/property/launchconfig module
####################################


define [ "../base/main",
         "./model",
         "./view",
         "./app_view",
         "constant",
         "event"
], ( PropertyModule, model, view, app_view, constant, ide_event ) ->

    LCModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

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
            @model.setup()
            @model.on "KP_DOWNLOADED", (data, option)->
                me.view.updateKPModal(data, option)

            @view.on "REQUEST_KEYPAIR", (name)->
                me.model.downloadKP(name)
            null

        initApp : () ->
            @model = model
            @model.isApp = true
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model, true
            null
    }

    # model.getInstanceType()
    # model.getAmiDisp()
    # model.getAmi()

    # # ######################################

    # model.getAppLaunch uid

