####################################
#  Controller for design/property/instance module
####################################

define [ 'jquery',
         'text!/module/design/property/instance/template.html',
         'event'
         'UI.notification'
], ( $, template, ide_event ) ->

    #
    current_view     = null
    current_model    = null
    current_sub_main = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-instance-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, instance_expended_id, current_main, tab_type ) ->

        #
        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/instance/' + view_type,
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
            model.getKerPair()
            model.getSgDisp()
            model.getCheckBox()
            model.getEni()
            #
            view.render()
            sglist_main.loadModule model
            #
            model.listen()
            #
            model.on 'change:update_instance_title', () ->

                view.render()
                sglist_main.loadModule model

                ide_event.trigger ide_event.RELOAD_PROPERTY

            ide_event.trigger ide_event.RELOAD_PROPERTY

            view.on 'ATTACH_EIP', ( eip_index, attach ) ->

                model.attachEIP eip_index, attach

            view.on 'ADD_NEW_IP', () ->

                model.addNewIP()

            view.on 'REMOVE_IP', ( index ) ->

                model.removeIP index
            ###
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
            ###

            model.on 'EXCEED_ENI_LIMIT', ( uid, instance_type, eni_number ) ->

                notification 'error', 'Instance Type: '+ instance_type + ' only support at most ' + eni_number + ' Network Interface(including the primary). Please detach extra Network Interface before changing Instance Type'

                view.trigger 'RE_RENDER', uid

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #
        current_sub_main.unLoadModule()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule