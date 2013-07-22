####################################
#  Controller for design/property/instance module
####################################

define [ 'jquery',
         'text!/module/design/property/instance/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-instance-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, instance_expended_id, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/instance/view',
                  './module/design/property/instance/model'
        ], ( view, model ) ->


            #
            current_view  = view
            current_model = model
            #
            current_view.delegateEvents view.events

            #view
            view.model    = model
            #model
            #model.setHost uid
            attributes = {
                instance_type : model.getInstanceType uid
                component : MC.canvas_data.component[uid]
                keypair : model.getKerPair uid
                ami_string : model.getAmi uid
                ami_display : model.getAmiDisp uid
                sg_display : model.getSgDisp uid
                checkbox_display: model.getCheckBox uid
                eni_display : model.getEni uid
            }
            #render
            view.render( attributes, instance_expended_id )

            ide_event.trigger ide_event.RELOAD_PROPERTY

            view.on 'RE_RENDER', ( uid ) ->

                attributes = {
                    instance_type : model.getInstanceType uid
                    component : MC.canvas_data.component[uid]
                    keypair : model.getKerPair uid
                    ami_string : model.getAmi uid
                    ami_display : model.getAmiDisp uid
                    sg_display : model.getSgDisp uid
                    checkbox_display: model.getCheckBox uid
                    eni_display : model.getEni uid
                }

                view.render( attributes )

                ide_event.trigger ide_event.RELOAD_PROPERTY

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule