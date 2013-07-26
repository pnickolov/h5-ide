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

            uid      = null
            tab_type = null
            MC.data.current_sub_main = null

            #view
            view  = new View { 'model' : model }
            view.render template

            #show stack property
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name, type ) ->
                console.log 'property:RELOAD_RESOURCE'
                #check re-render
                view.reRender template
                #
                tab_type = type
                #
                stack_main.loadModule stack_main

            #listen OPEN_PROPERTY
            ide_event.onLongListen ide_event.OPEN_PROPERTY, ( type, uid, instance_expended_id ) ->

                #
                MC.data.last_open_property = { 'type' : type, 'uid' : uid, 'instance_expended_id' : instance_expended_id }

                if MC.data.current_sub_main then MC.data.current_sub_main.unLoadModule()

                if type == 'component'

                    #select component

                    uid  = uid

                    console.log 'OPEN_PROPERTY, uid = ' + uid

                    #show stack property
                    if uid is ''
                        stack_main.loadModule stack_main

                    #show az property
                    if MC.canvas_data.component[ uid ]

                        console.log 'type = ' + MC.canvas_data.component[ uid ].type
                        #components except AvailabilityZone
                        switch MC.canvas_data.component[ uid ].type
                            #show instance property
                            when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance         then instance_main.loadModule uid, instance_expended_id, instance_main
                            #show volume/snapshot property
                            when constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume           then volume_main.loadModule uid, volume_main
                            #show elb property
                            when constant.AWS_RESOURCE_TYPE.AWS_ELB                  then elb_main.loadModule uid, elb_main, tab_type
                            #show subnet property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet           then subnet_main.loadModule uid, subnet_main
                            #show vpc property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC              then vpc_main.loadModule uid, vpc_main
                            #show dhcp property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions      then dhcp_main.loadModule uid, dhcp_main
                            #show rtb property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable       then rtb_main.loadModule uid, 'component', rtb_main
                            #show igw property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway  then igw_main.loadModule uid, igw_main
                            #show vgw property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway       then vgw_main.loadModule uid, vgw_main
                            #show cgw property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway  then cgw_main.loadModule uid, cgw_main
                            #show vpn property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection    then vpn_main.loadModule uid, null, vpn_main
                            #show eni property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface then eni_main.loadModule uid, eni_main
                            #show acl property
                            when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl       then acl_main.loadModule uid, acl_main

                            #
                            else
                                #
                    else

                        #AvailabilityZone
                        if MC.canvas_data.layout.component.group[ uid ] and MC.canvas_data.layout.component.group[ uid ].type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
                            console.log 'type = ' + MC.canvas_data.layout.component.group[ uid ].type
                            az_main.loadModule uid, az_main

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

                                        rtb_main.loadModule value.uid, 'component', rtb_main

                                        return false

                            else if '|instance-sg-in>instance-sg-out|instance-sg-out>instance-sg-in|'.indexOf( key ) >0
                                #select line between instance and instance
                                sgrule_main.loadModule uid, 'line', sgrule_main, tab_type

                            else if '|vgw-vpn>cgw-vpn|cgw-vpn>vgw-vpn|'.indexOf( key ) > 0
                                #select line between vgw and  cgw
                                vpn_main.loadModule line_option, 'line', vpn_main


                #temp
                # setTimeout () ->
                #    view.refresh()
                # , 2000

                null

            #listen OPEN_SG
            ide_event.onLongListen ide_event.OPEN_SG, ( uid_parent, expended_accordion_id ) ->
                console.log 'OPEN_SG'
                sg_main.loadModule( uid_parent, expended_accordion_id, sg_main )
                #temp
                # setTimeout () ->
                #    view.refresh()
                # , 2000

                null

            #listen OPEN_ACL
            ide_event.onLongListen ide_event.OPEN_ACL, ( uid_parent, expended_accordion_id, acl_uid ) ->
                console.log 'OPEN_ACL'
                acl_main.loadModule( uid_parent, expended_accordion_id, acl_uid )

                null

            #listen OPEN_INSTANCE
            ide_event.onLongListen ide_event.OPEN_INSTANCE, (expended_accordion_id) ->
                console.log 'OPEN_INSTANCE'
                #
                instance_main.loadModule uid, expended_accordion_id, instance_main
                #temp
                # setTimeout () ->
                #    view.refresh()
                # , 2000

                null

            ide_event.onLongListen ide_event.RELOAD_PROPERTY, () ->

                view.refresh()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
