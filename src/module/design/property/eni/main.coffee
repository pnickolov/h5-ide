####################################
#  Controller for design/property/eni module
####################################

define [ 'jquery',
         'text!/module/design/property/eni/template.html',
         'text!/module/design/property/eni/app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-eni-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-eni-app-tmpl">' + app_template + '</script>'

    #load remote html template
    $( 'head' ).append( template ).append( app_template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->
        console.log 'eni main, tab_type = ' + tab_type

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/eni/' + view_type,
                  './module/design/property/eni/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.getENIDisplay uid
            #render
            view.render()

            view.on 'SET_ENI_DESC', ( uid, value ) ->

                model.setEniDesc uid, value

            view.on 'SET_ENI_SOURCE_DEST_CHECK', ( uid, check ) ->

                model.setSourceDestCheck uid, check

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
