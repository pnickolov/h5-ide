####################################
#  Controller for design/property/eni module
####################################

define [ 'jquery',
         'text!/module/design/property/eni/template.html',
         'text!/module/design/property/eni/app_template.html',
         'text!/module/design/property/eni/ip_list_template.html',
         'event'
], ( $, template, app_template, ip_list_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-eni-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-eni-app-tmpl">' + app_template + '</script>'
    ip_list_template = '<script type="text/x-handlebars-template" id="property-eni-ip-list-tmpl">' + ip_list_template + '</script>'

    #load remote html template
    $( 'head' ).append( template ).append( app_template )
    $( 'head' ).append( template ).append( ip_list_template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->
        console.log 'eni main, tab_type = ' + tab_type

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP'
            loadAppModule uid
            return

        #
        require [ './module/design/property/eni/view',
                  './module/design/property/eni/model',
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.set 'uid', uid

            model.getENIDisplay uid
            #render
            view.render()
            # Set title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.eni_display.name

            ide_event.onLongListen ide_event.PROPERTY_REFRESH_ENI_IP_LIST, () ->
                view.refreshIPList()

            if not model.attributes.association
                sglist_main.loadModule model

            view.on 'SET_ENI_DESC', ( uid, value ) ->

                model.setEniDesc uid, value

            view.on 'SET_ENI_SOURCE_DEST_CHECK', ( uid, check ) ->

                model.setSourceDestCheck uid, check

            view.on 'ADD_NEW_IP', ( uid ) ->

                model.addNewIP uid

            view.on 'ATTACH_EIP', ( uid, index, attach ) ->

                model.attachEIP uid, index, attach

            view.on 'REMOVE_IP', ( uid, index ) ->

                model.removeIP uid, index

            view.on 'SET_IP_LIST', (inputIPAry) ->

                model.setIPList inputIPAry


    loadAppModule = ( uid ) ->
        require [ './module/design/property/eni/app_view',
                  './module/design/property/eni/app_model'
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.init uid
            view.render()

            # Set title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name

            sglist_main.loadModule model, true

    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        ide_event.offListen ide_event.PROPERTY_REFRESH_ENI_IP_LIST
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
