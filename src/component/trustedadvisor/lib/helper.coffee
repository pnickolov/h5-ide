define [ 'constant', 'MC', 'i18n!nls/lang.js', 'Design', 'underscore' ], ( CONST, MC, lang, Design, _ ) ->

    Helper =
        map:
            protocal:
                '1' : 'icmp'
                '6' : 'tcp'
                '17': 'udp'
                '-1': 'all'
                'tcp': 'tcp'
                'udp': 'udp'
                'icmp': 'icmp'
                'all': 'all'

        protocal:
            get: ( code ) ->
                Helper.map.protocal[ code.toString() ] or code

        component:
            get: ( uid, rework ) ->
                if rework
                    Design.instance().component uid
                else
                    MC.canvas_data.component[ uid ]

        eni:
            getByInstance: ( instance ) ->
                _.filter MC.canvas_data.component, ( component ) ->
                    if component.type is CONST.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
                        if MC.extractID( component.resource.Attachment.InstanceId ) is instance.uid
                            true

        sg:
            get: ( component ) ->
                sgs = []
                # LC
                if component.type is CONST.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
                    for sgId in component.resource.SecurityGroups
                        sgs.push Helper.component.get MC.extractID sgId
                # instance
                else if component.type is CONST.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                    enis = Helper.eni.getByInstance component

                    for eni in enis
                        for sg in eni.resource.GroupSet
                            sgs.push Helper.component.get MC.extractID sg.GroupId
                # ELB
                else if component.type is CONST.AWS_RESOURCE_TYPE.AWS_ELB
                    for sgId in component.resource.SecurityGroups
                        sgs.push Helper.component.get MC.extractID sgId

                _.uniq _.compact sgs

            port: ( sgs ) ->
                info = in: {}, out: {}
                if not _.isArray sgs
                    sgs = [ sgs ]
                for sg in sgs
                    if sg.type isnt CONST.RESTYPE.SG
                        continue

                    for permission in sg.resource.IpPermissionsEgress
                        protocal = Helper.protocal.get permission.IpProtocol
                        info[ 'out' ][ protocal ] or ( info[ 'out' ][ protocal ] = [] )
                        info[ 'out' ][ protocal ].push from: permission.FromPort, to: permission.ToPort

                    for permission in sg.resource.IpPermissions
                        protocal = Helper.protocal.get permission.IpProtocol
                        info[ 'in' ][ protocal ] or ( info[ 'in' ][ protocal ] = [] )
                        info[ 'in' ][ protocal ].push from: permission.FromPort, to: permission.ToPort


                info

            # isInRange: (protocal, port, portData, direction) ->

            #     isInRangeResult = false
            #     _.each portMap[direction], (portAry, proto) ->
            #         if proto is -1
            #         isInRangeResult = true

    Helper
