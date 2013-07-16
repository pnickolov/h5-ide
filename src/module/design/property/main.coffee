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
                  './module/design/property/sg/main',
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
        ], ( View, model, stack_main, instance_main, sg_main, volume_main, elb_main, az_main, subnet_main, vpc_main, dhcp_main, rtb_main, igw_main, vgw_main, cgw_main, vpn_main, eni_main, acl_main ) ->

            uid  = null
            type = null

            #view
            view  = new View { 'model' : model }
            view.render template

            #show stack property
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, () ->
                console.log 'property:RELOAD_RESOURCE'
                #check re-render
                view.reRender template
                #
                stack_main.loadModule()

            #listen OPEN_PROPERTY
            ide_event.onLongListen ide_event.OPEN_PROPERTY, ( uid ) ->

                uid  = uid
                #type = type

                console.log 'OPEN_PROPERTY, uid = ' + uid

                #show stack property
                if uid is ''
                    stack_main.loadModule()

                #show az property
                if MC.canvas_data.component[ uid ]

                    console.log 'type = ' + MC.canvas_data.component[ uid ].type
                    #components except AvailabilityZone
                    switch MC.canvas_data.component[ uid ].type
                        #show instance property
                        when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance         then instance_main.loadModule uid
                        #show volume/snapshot property
                        when constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume           then volume_main.loadModule uid
                        #show elb property
                        when constant.AWS_RESOURCE_TYPE.AWS_ELB                  then elb_main.loadModule uid
                        #show subnet property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet           then subnet_main.loadModule uid
                        #show vpc property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC              then vpc_main.loadModule uid
                        #show dhcp property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions      then dhcp_main.loadModule uid
                        #show rtb property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable       then rtb_main.loadModule uid
                        #show igw property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway  then igw_main.loadModule uid
                        #show vgw property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway       then vgw_main.loadModule uid
                        #show cgw property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway  then cgw_main.loadModule uid
                        #show vpn property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection    then vpn_main.loadModule uid
                        #show eni property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface then eni_main.loadModule uid
                        #show acl property
                        when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl       then acl_main.loadModule uid
                        #
                        else
                            #
                else

                    #AvailabilityZone
                    if MC.canvas_data.layout.component.group[ uid ] and MC.canvas_data.layout.component.group[ uid ].type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
                        console.log 'type = ' + MC.canvas_data.layout.component.group[ uid ].type
                        az_main.loadModule uid

                #temp
                # setTimeout () ->
                #    view.refresh()
                # , 2000

                null

            #listen OPEN_SG
            ide_event.onLongListen ide_event.OPEN_SG, ( uid_parent ) ->
                console.log 'OPEN_SG'
                sg_main.loadModule( uid_parent )
                #temp
                # setTimeout () ->
                #    view.refresh()
                # , 2000

                null

            #listen OPEN_INSTANCE
            ide_event.onLongListen ide_event.OPEN_INSTANCE, () ->
                console.log 'OPEN_INSTANCE'
                #
                instance_main.loadModule uid, type
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
