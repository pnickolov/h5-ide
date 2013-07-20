####################################
#  Controller for design/property/instance module
####################################

define [ 'jquery',
         'text!/module/design/property/instance/template.html',
         'event'
         'UI.notification'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, instance_expended_id ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-instance-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/instance/view',
                  './module/design/property/instance/model'
        ], ( view, model ) ->

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

            mode.on 'EXCEED_ENI_LIMIT', ( instance_type, eni_number ) ->

                notification 'error', 'Instance Type: '+ instance_type + ' only support at most ' + eni_number + ' Network Interface(including the primary). Please detach extra Network Interface before changing Instance Type'

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule