####################################
#  Controller for design/property module
####################################
define [ 'jquery',
         'text!/module/design/property/template.html',
         'event',
         'constant',
         'MC'
], ( $, template, ide_event, constant, MC ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="property-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#property-panel'

        #compile partial template
        #MC.IDEcompile 'design-property', template_data, { '.accordion-item-data' : 'accordion-item-tmpl' }

        #
        require [ './module/design/property/view',
                  './module/design/property/model',
                  './module/design/property/stack/main',
                  './module/design/property/instance/main',
                  './module/design/property/sg/main', './module/design/property/sgrule/main',
                  './module/design/property/volume/main',
                  './module/design/property/elb/main',
                  './module/design/property/az/main',
                  './module/design/property/subnet/main',
                  './module/design/property/vpc/main',
                  './module/design/property/dhcp/main',
                  './module/design/property/rtb/main',
                  './module/design/property/igw/main',
                  './module/design/property/vgw/main',
                  './module/design/property/cgw/main',
                  './module/design/property/vpn/main',
                  './module/design/property/eni/main',
                  './module/design/property/acl/main'
        ], ( View, model, stack_main, instance_main, sg_main, sgrule_main, volume_main, elb_main, az_main, subnet_main, vpc_main, dhcp_main, rtb_main, igw_main, vgw_main, cgw_main, vpn_main, eni_main, acl_main ) ->

            current_uid = null
            tab_type = null
            MC.data.current_sub_main = null

            #view
            view  = new View { 'model' : model }
            view.render template

            #show stack property
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name, type ) ->
                console.log 'property:RELOAD_RESOURCE, type = ' + type
                #check re-render
                view.reRender template
                #
                tab_type = type
                #
                stack_main.loadModule stack_main
                null

            #listen OPEN_PROPERTY
            ide_event.onLongListen ide_event.OPEN_PROPERTY, ( type, uid, instance_expended_id, back_dom, bak_tab_type ) ->
                #
                MC.data.last_open_property = { 'event_type' : ide_event.OPEN_PROPERTY, 'type' : type, 'uid' : uid, 'instance_expended_id' : instance_expended_id }
                #
                if bak_tab_type then tab_type = bak_tab_type

                if MC.data.current_sub_main then MC.data.current_sub_main.unLoadModule()

                current_uid  = uid
                console.log 'OPEN_PROPERTY, uid = ' + uid

                if type == 'component'

                    #show stack property
                    if uid is ''
                        stack_main.loadModule stack_main

                    #show az property
                    if MC.canvas_data.component[ uid ]

                        console.log 'type = ' + MC.canvas_data.component[ uid ].type
                        #components except AvailabilityZone
                        switch MC.canvas_data.component[ uid ].type
                            #show instance property
                            when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance         then instance_main.loadModule uid, instance_expended_id, instance_main, tab_type
                            #show volume/snapshot property
                            when constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume           then volume_main.loadModule uid, volume_main, tab_type
                            #show elb property
                            when constant.AWS_RESOURCE_TYPE.AWS_ELB                  then elb_main.loadModule uid, elb_main, tab_type
                            #show subnet property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet           then subnet_main.loadModule uid, subnet_main, tab_type
                            #show vpc property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC              then vpc_main.loadModule uid, vpc_main, tab_type
                            #show dhcp property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions      then dhcp_main.loadModule uid, dhcp_main
                            #show rtb property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable       then rtb_main.loadModule uid, rtb_main, tab_type
                            #show igw property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway  then igw_main.loadModule uid, igw_main
                            #show vgw property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway       then vgw_main.loadModule uid, vgw_main
                            #show cgw property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway  then cgw_main.loadModule uid, cgw_main, tab_type
                            #show vpn property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection    then vpn_main.loadModule uid, null, vpn_main
                            #show eni property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface then eni_main.loadModule uid, eni_main, tab_type
                            # Acl Property is not loaded in such a way.

                            #
                            else
                                #
                    else

                        #AvailabilityZone
                        if MC.canvas_data.layout.component.group[ uid ] and MC.canvas_data.layout.component.group[ uid ].type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
                            console.log 'type = ' + MC.canvas_data.layout.component.group[ uid ].type
                            az_main.loadModule uid, az_main, tab_type

                else

                    #select line
                    if MC.canvas_data.layout.connection[uid]

                        line_option = MC.canvas.lineTarget uid

                        if line_option.length == 2

                            console.info line_option[0].uid + ',' + line_option[0].port + " | " + line_option[1].uid + ',' + line_option[1].port

                            key = line_option[0].port + '>' + line_option[1].port


                            if key.indexOf( 'rtb' ) >= 0
                                #select line between instance and routetable
                                $.each line_option, ( idx, value ) ->

                                    if value.port.indexOf('rtb') >=0

                                        #rtb_main.loadModule value.uid, 'component', rtb_main
                                        rtb_main.loadModule value.uid, rtb_main, tab_type

                                        return false

                            else if key.indexOf('sg') >=0

                                #select line between instance and instance
                                sgrule_main.loadModule uid, 'line', sgrule_main, tab_type

                            else if '|vgw-vpn>cgw-vpn|cgw-vpn>vgw-vpn|'.indexOf( key ) > 0
                                #select line between vgw and  cgw
                                vpn_main.loadModule line_option, 'line', vpn_main

                #
                if back_dom then ide_event.trigger ide_event.UPDATE_PROPERTY, back_dom
                null

            #listen OPEN_SG
            ide_event.onLongListen ide_event.OPEN_SG, ( uid_parent, expended_accordion_id, back_dom, bak_tab_type ) ->
                console.log 'OPEN_SG'
                #
                if MC.data.current_sub_main then MC.data.current_sub_main.unLoadModule()
                #
                MC.data.last_open_property = { 'event_type' : ide_event.OPEN_SG, 'uid_parent' : uid_parent, 'expended_accordion_id' : expended_accordion_id }
                #
                if bak_tab_type then tab_type = bak_tab_type
                #
                sg_main.loadModule( uid_parent, expended_accordion_id, sg_main, tab_type )
                #
                if back_dom then ide_event.trigger ide_event.UPDATE_PROPERTY, back_dom
                null

            ide_event.onLongListen ide_event.SHOW_SG_LIST, ( line_id )->

                sgrule_main.loadModule uid, 'delete'

            #listen OPEN_ACL
            ide_event.onLongListen ide_event.OPEN_ACL, ( uid_parent, expended_accordion_id, acl_uid, return_type, back_dom, bak_tab_type ) ->
                console.log 'OPEN_ACL, return_type = ' + return_type
                #
                if MC.data.current_sub_main then MC.data.current_sub_main.unLoadModule()
                #
                MC.data.last_open_property = { 'event_type' : ide_event.OPEN_ACL, 'uid' : uid_parent, 'expended_accordion_id' : expended_accordion_id, 'acl_uid' : acl_uid, 'return_type' : return_type }
                #
                if bak_tab_type then tab_type = bak_tab_type
                #
                acl_main.loadModule( uid_parent, expended_accordion_id, acl_uid, return_type, tab_type )
                #
                if back_dom then ide_event.trigger ide_event.UPDATE_PROPERTY, back_dom
                null

            #listen OPEN_INSTANCE
            ide_event.onLongListen ide_event.OPEN_INSTANCE, ( expended_accordion_id, back_dom, bak_tab_type ) ->
                console.log 'OPEN_INSTANCE'
                #
                if MC.data.current_sub_main then MC.data.current_sub_main.unLoadModule()
                #
                MC.data.last_open_property = { 'event_type' : ide_event.OPEN_INSTANCE, 'expended_accordion_id' : expended_accordion_id }
                #
                if bak_tab_type then tab_type = bak_tab_type
                #
                instance_main.loadModule current_uid, expended_accordion_id, instance_main
                #
                if back_dom then ide_event.trigger ide_event.UPDATE_PROPERTY, back_dom
                null

            ide_event.onLongListen ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL, ( return_type, back_dom, bak_tab_type ) ->
                console.log 'RETURN_SUBNET_PROPERTY_FROM_ACL, return_type = ' + return_type
                #
                if MC.data.current_sub_main then MC.data.current_sub_main.unLoadModule()
                #
                MC.data.last_open_property = { 'event_type' : ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL, 'return_type' : return_type }
                #
                if bak_tab_type then tab_type = bak_tab_type
                #
                if !current_uid and return_type isnt 'stack' then current_uid = return_type.split(':')[1]
                #
                if return_type is 'stack' then stack_main.loadModule stack_main else subnet_main.loadModule current_uid, subnet_main, tab_type
                #
                if back_dom then ide_event.trigger ide_event.UPDATE_PROPERTY, back_dom

            ide_event.onLongListen ide_event.RELOAD_PROPERTY, () ->

                view.refresh()

            ide_event.onLongListen ide_event.UPDATE_PROPERTY, ( back_dom ) ->
                console.log 'UPDATE_PROPERTY'
                setTimeout () ->
                    view.updateHtml back_dom
                , 500


    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
