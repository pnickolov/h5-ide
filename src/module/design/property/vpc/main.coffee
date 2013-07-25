####################################
#  Controller for design/property/vpc module
####################################

define [ 'jquery',
         'text!/module/design/property/vpc/template.html',
         'text!/module/design/property/vpc/app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-vpc-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-vpc-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/vpc/' + view_type,
                  './module/design/property/vpc/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            model.setId uid
            view.model = model
            view.render()

            view.on "CHANGE_NAME", ( newName ) ->
                model.setName newName
                # Update Canvas
                MC.canvas.update uid, "text", "name", newName
                null
        null

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
