####################################
#  Controller for design/property/instance module
####################################

define [ 'jquery',
         'text!/module/design/property/instance/template.html',
         'text!/module/design/property/instance/app_template.html',
         'text!/module/design/property/instance/ip_list_template.html',
         'event',
         'UI.notification'
], ( $, template, app_template, ip_list_template, ide_event ) ->

    #
    current_view     = null
    current_model    = null
    current_sub_main = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-instance-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-instance-app-tmpl">' + app_template + '</script>'
    ip_list_template = '<script type="text/x-handlebars-template" id="property-ip-list-tmpl">' + ip_list_template + '</script>'
    #load remote html template
    $( 'head' ).append template
    $( 'head' ).append app_template
    $( 'head' ).append ip_list_template

    #private
    loadModule = ( uid, instance_expended_id, current_main, tab_type ) ->

        #
        MC.data.current_sub_main = current_main

        if tab_type is 'OPEN_APP'
            loadAppModule uid, instance_expended_id, current_main
            return

        #
        require [ './module/design/property/instance/view',
                  './module/design/property/instance/model',
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_sub_main = sglist_main

            #
            current_view  = view
            current_model = model
            #

            #view
            view.model    = model

            model.getUID  uid
            model.getName()
            model.getInstanceType()
            model.getAmiDisp()
            model.getAmi()
            model.getComponent()
            model.getKeyPair()
            # model.getSgDisp()
            model.getCheckBox()
            model.getEni()
            #
            view.render()
            # Set title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name

            sglist_main.loadModule model

            model.set 'type', 'stack'

            #
            model.listen()
            #
            model.on 'change:update_instance_title', () ->

                view.render()
                sglist_main.loadModule model

                ide_event.trigger ide_event.RELOAD_PROPERTY

            ide_event.trigger ide_event.RELOAD_PROPERTY

            ide_event.onLongListen ide_event.PROPERTY_REFRESH_ENI_IP_LIST, () ->
                view.refreshIPList()

            view.on 'ATTACH_EIP', ( eip_index, attach ) ->

                model.attachEIP eip_index, attach

            view.on 'ADD_NEW_IP', () ->

                model.addNewIP()

            view.on 'REMOVE_IP', ( index ) ->

                model.removeIP index

            view.on 'SET_IP_LIST', (inputIPAry) ->

                model.setIPList inputIPAry

            view.on 'COUNT_CHANGE', ( val ) ->
                model.setCount val

            model.on 'EXCEED_ENI_LIMIT', ( uid, instance_type, eni_number ) ->

                notification 'error', lang.ide.PROP_WARN_EXCEED_ENI_LIMIT


    loadAppModule = ( uid, instance_expended_id, current_main ) ->

        require [ './module/design/property/instance/app_view',
                  './module/design/property/instance/app_model',
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_sub_main = sglist_main

            #
            current_view  = view
            current_model = model

            view.model    = model

            model.on "KP_DOWNLOADED", (data)-> view.updateKPModal(data)
            view.on "REQUEST_KEYPAIR", (name)-> model.downloadKP(name)
            view.on "OPEN_AMI", (id) ->
                data = model.getAMI id
                ide_event.trigger ide_event.PROPERTY_OPEN_SUBPANEL, {
                    title : id
                    dom   : MC.template.aimSecondaryPanel data
                    id    : 'Ami'
                }

            model.init(uid)

            model.set 'type', 'app'

            view.render()
            # Set title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name

            sglist_main.loadModule model, true

            # update instance state
            ide_event.onLongListen ide_event.UPDATE_APP_RESOURCE, (region, app_id) ->
                console.log 'update instance state, UPDATE_APP_RESOURCE'

                #model.updateState( region, app_id)

                null


    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #
        current_sub_main.unLoadModule()
        ide_event.offListen ide_event.PROPERTY_REFRESH_ENI_IP_LIST

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
