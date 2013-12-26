####################################
#  Controller for design/property/elb module
####################################

define [ '../base/main',
         './model',
         './view',
         './app_model',
         './app_view',
         "../sglist/main",
         'constant',
         'event'
], ( PropertyModule, model, view, app_model, app_view, sglist_main, constant, ide_event ) ->

    ElbModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_ELB

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        initStack : ()->
            @model = model
            @view  = view
            null

        afterLoadStack : ()->
            # currentCert = @model.getCurrentCert()
            # if currentCert
            #     @view.refreshCertPanel currentCert

            sglist_main.loadModule @model
            null

        initApp : ()->
            @model = app_model
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null

        initAppEdit : ()->
            @model = app_model
            @view  = app_view
            null

        afterLoadAppEdit : ()->
            sglist_main.loadModule model
            null
    }
    null
