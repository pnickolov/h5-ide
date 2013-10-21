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

        initApp : () ->
            @model = model
            @model.isApp = true
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model, true
            null
    }

    # model.getUID  uid
    # model.getName()
    # model.getInstanceType()
    # model.getAmiDisp()
    # model.getAmi()
    # model.getComponent()
    # model.getKeyPair()
    # # model.getSgDisp()
    # model.getCheckBox()
    # model.listen()

    # # ######################################

    # model.getAppLaunch uid

    # model.on "KP_DOWNLOADED", (data, option)-> view.updateKPModal(data, option)
    # view.on "REQUEST_KEYPAIR", (name)-> model.downloadKP(name)

