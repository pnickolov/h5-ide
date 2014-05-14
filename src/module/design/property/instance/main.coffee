####################################
#  Controller for design/property/instance module
####################################

define [ "../base/main",
         "./model",
         "./view",
         "./app_model",
         "./app_view",
         "../sglist/main",
         "constant",
         "event"
], ( PropertyModule,
     model, view,
     app_model, app_view,
     sglist_main, constant, ide_event ) ->

    ideEvents = {}
    ideEvents[ ide_event.PROPERTY_REFRESH_ENI_IP_LIST ] = () ->
        if @model.getEni
            @model.getEni()
        if @view.refreshIPList
            @view.refreshIPList()
        null

    # ideEvents[ ide_event.PROPERTY_DISABLE_USER_DATA_INPUT ] = (flag) ->
    #     @view.disableUserDataInput(flag)
    #     null

    InstanceModule = PropertyModule.extend {

        ideEvents : ideEvents

        handleTypes : [ constant.RESTYPE.INSTANCE, 'component_asg_instance' ]

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

            @model.on "PASSWORD_STATE", ( data ) ->
                me.view.updateKPModal 'check', data

            @model.on "PASSWORD_GOT", ( data ) ->
                me.view.updateKPModal 'got', data

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
    }
    null
