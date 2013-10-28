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

        setupStack : () ->
            me = this
            @view.on 'ELB_NAME_CHANGED', ( value ) ->
                me.model.setELBName value
                null

            @view.on 'SCHEME_SELECT_CHANGED', ( value ) ->
                elbComponent = model.setScheme value

                defaultVPC = false
                if MC.aws.aws.checkDefaultVPC()
                    defaultVPC = true

                # Trigger an event to tell canvas that we want an IGW
                if value isnt 'internal' and !defaultVPC
                    ide_event.trigger ide_event.NEED_IGW, elbComponent

                return true

            @view.on 'HEALTH_PROTOCOL_SELECTED', ( value ) ->
                me.model.setHealthProtocol value

            @view.on 'HEALTH_PORT_CHANGED', ( value ) ->
                me.model.setHealthPort value

            @view.on 'HEALTH_PATH_CHANGED', ( value ) ->
                me.model.setHealthPath value

            @view.on 'HEALTH_INTERVAL_CHANGED', ( value ) ->
                me.model.setHealthInterval value

            @view.on 'HEALTH_TIMEOUT_CHANGED', ( value ) ->
                me.model.setHealthTimeout value

            @view.on 'UNHEALTHY_SLIDER_CHANGE', ( value ) ->
                me.model.setHealthUnhealth value

            @view.on 'HEALTHY_SLIDER_CHANGE', ( value ) ->
                me.model.setHealthHealth value

            @view.on 'LISTENER_ITEM_CHANGE', ( value ) ->
                me.model.setListenerAry value

            @view.on 'LISTENER_CERT_CHANGED', ( value ) ->
                me.model.setListenerCert value

            @view.on 'REMOVE_AZ_FROM_ELB', ( value ) ->
                me.model.removeAZFromELB value

            @view.on 'ADD_AZ_TO_ELB', ( value ) ->
                me.model.addAZToELB value

            @view.on 'REFRESH_SG_LIST', () ->
                sglist_main.refresh()
            null

        initStack : ()->
            @model = model
            @view  = view
            null

        afterLoadStack : ()->
            currentCert = @model.getCurrentCert()
            if currentCert
                @view.refreshCertPanel currentCert

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
            # Use Stack model to handle sglist interaction
            model.init( @model.get "componentUid" )
            sglist_main.loadModule model
            null



    }
    null
