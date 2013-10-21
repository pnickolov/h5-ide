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
], ( PropertyModule, model, view, app_model, app_view, sglist_main, constant, ide_event ) ->

    ideEvents = {}
    ideEvents[ ide_event.PROPERTY_REFRESH_ENI_IP_LIST ] = () ->
        @view.refreshIPList()
        null

    InstanceModule = PropertyModule.extend {

        ideEvents : ideEvents

        handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, 'component_asg_instance' ]

        onUnloadSubPanel : ( id )->
            if id is "SG"
                sglist_main.loadModule @model
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
                data = me.model.getAMI id
                ide_event.trigger ide_event.PROPERTY_OPEN_SUBPANEL, {
                    title : id
                    dom   : MC.template.aimSecondaryPanel data
                    id    : 'Ami'
                }
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
