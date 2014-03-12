define [ 'constant', 'MC', 'i18n!nls/lang.js', 'Design', 'underscore' ], ( CONST, MC, lang, Design, _ ) ->

    Helper =
        map:
            protocal:
                '1' : 'icmp'
                '6' : 'tcp'
                '17': 'udp'

        protocal:
            get: ( code ) ->
                Helper.map.protocal[ code.toString() ] or code


        sg:
            get: ( component ) ->
                sgs = []
                # LC
                if component.type is CONST.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
                    for sgId in component.resource.SecurityGroups
                        sgs.push __getComp MC.extractID sgId
                # instance
                else if component.type is CONST.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                    enis = __getEniByInstance component

                    for eni in enis
                        for sg in eni.resource.GroupSet
                            sgs.push __getComp MC.extractID sg.GroupId

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

                info



    Helper


