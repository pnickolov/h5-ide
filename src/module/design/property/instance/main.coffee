####################################
#  Controller for design/property/instance module
####################################

define [ "../base/main",
         "./model",
         "./view",
         "./app_model",
         "./app_view",
         "./appedit_model",
         "./appedit_view",
         "../sglist/main",
         "constant",
         "event"
], ( PropertyModule,
     model, view,
     app_model, app_view,
     appedit_model, appedit_view,
     sglist_main, constant, ide_event ) ->

    ideEvents = {}
    ideEvents[ ide_event.PROPERTY_REFRESH_ENI_IP_LIST ] = () ->
        @view.refreshIPList()
        null

    InstanceModule = PropertyModule.extend {

        ideEvents : ideEvents

        handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, 'component_asg_instance' ]

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        setupStack : () ->
            @view.on "OPEN_AMI", (id) ->
                PropertyModule.loadSubPanel "STATIC", id
            null

        initStack : ()->
            @model = model
            @view  = view
            null

        afterLoadStack : ()->
            sglist_main.loadModule @model
            null

        setupApp : () ->
            me = this
            @model.on "KP_DOWNLOADED", (data, option)->
                me.view.updateKPModal(data, option)

            @view.on "REQUEST_KEYPAIR", (name)->
                me.model.downloadKP(name)

            @view.on "OPEN_AMI", (id) ->
                PropertyModule.loadSubPanel "STATIC", id
            null

        initApp : () ->
            @model = app_model
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null

        setupAppEdit : () ->
            @view.on "OPEN_AMI", (id) ->
                PropertyModule.loadSubPanel "STATIC", id
            null

        initAppEdit : () ->
            @model = appedit_model
            @view  = appedit_view
            null

        afterLoadAppEdit : () ->
            sglist_main.loadModule @model
            null

    }
    null
