####################################
#  Controller for design/property/sgrule module
####################################

define [ 'jquery',
         'text!/module/design/property/sgrule/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-sgrule-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append( template )

    #private
    loadModule = ( uid, type, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/sgrule/model', './module/design/property/sgrule/view', './component/sgrule/main' ], ( model, view, sgrule_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model = model

            model.setLineId uid
            #render
            view.render()

            view.on "EDIT_RULE", ( line_id ) ->
                # TODO : Show SG Rule Popup
                sgrule_main.loadModule( line_id )

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
