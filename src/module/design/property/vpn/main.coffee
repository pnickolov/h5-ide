####################################
#  Controller for design/property/vpn module
####################################

define [ '../base/main',
         './model',
         './view',
         'constant',
         'event'
], ( PropertyModule, model, view, constant, ide_event ) ->

    VPNModule = PropertyModule.extend {

        handleTypes : "vgw-vpn>cgw-vpn"

        setupStack : () ->
            me = this
            @view.on 'VPN_IP_UPDATE', (ipset) ->
                me.model.updateIps ipset

        initStack : () ->
            @view  = view
            @model = model


        initApp : () ->
            @view = view
            @model = model


    }
    null
