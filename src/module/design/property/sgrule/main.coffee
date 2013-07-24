####################################
#  Controller for design/property/sgrule module
####################################

define [ 'jquery',
         'text!/module/design/property/sgrule/create_template.html', 
         'text!/module/design/property/sgrule/create_list_template.html',
         'text!/module/design/property/sgrule/template.html',
         'event'
], ( $, create_template, create_list_template, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-sgrule-tmpl">' + template + '</script>'
    create_list_template = '<script type="text/x-handlebars-template" id="property-sgrule-create-list-tmpl">' + create_list_template + '</script>'
    create_template = '<script type="text/x-handlebars-template" id="property-sgrule-create-tmpl">' + create_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( create_template ).append( create_list_template )

    showCreateSGRuleModal = ( outward_id, inward_id ) ->

        require [ './module/design/property/sgrule/create_view', 
                  './module/design/property/sgrule/model' ], ( create_view, model ) ->





    #private
    loadModule = ( uid, type, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/sgrule/model', './module/design/property/sgrule/view', './module/design/property/sgrule/create_view' ], ( model, view, create_view ) ->

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
                create_view.model = model
                create_view.render()
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
