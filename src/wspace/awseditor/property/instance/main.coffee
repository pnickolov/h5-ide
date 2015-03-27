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

        initStack : ( uid )->
            @model = model
            @view  = view
            @view.resModel = Design.instance().component uid

            null

        afterLoadStack : ()->
            sglist_main.loadModule @model
            null

        setupApp : () ->
            me = this

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
