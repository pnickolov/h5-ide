####################################
#  Controller for design/property/sgrule module
####################################

define [ 'jquery',
         'text!/module/design/property/sgrule/template.html',
         'text!/module/design/property/sgrule/app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-sgrule-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-sgrule-app-tmpl">' + app_template + '</script>'

    #load remote html template
    $( 'head' ).append( template )
    $( 'head' ).append( app_template )

    #private
    loadModule = ( uid, type, current_main, tab_type ) ->

        #
        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/sgrule/model', './module/design/property/sgrule/' + view_type ], ( model, view ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model = model
            #render
            view.render()

            view.on "EDIT_RULE", () ->
                # TODO : Show SG Rule Popup
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
