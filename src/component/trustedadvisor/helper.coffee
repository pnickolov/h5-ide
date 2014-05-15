define [ 'constant', 'MC', 'i18n!nls/lang.js', 'Design', 'underscore' ], ( CONST, MC, LANG, Design, _ ) ->

    Inside =
        taReturn: ( type, tip, uid ) ->
            ret =
                level   : CONST.TA[ type ]
                info    : tip
            if uid
                ret.uid = uid
            ret

        genTip: ( args ) ->
            if args.length > 2
                tip = Function.call.apply sprintf, args
            else
                tip = args[ 1 ]
            tip

    Helper =
        map:
            protocal:
                '1' : 'icmp'
                '6' : 'tcp'
                '17': 'udp'
                '-1': 'all'

        protocal:
            get: ( code ) ->
                Helper.map.protocal[ code.toString() ] or code

        i18n:
            short: () ->
                LANG.ide

        component:
            get: ( uid, rework ) ->
                if rework
                    Design.instance().component uid
                else
                    MC.canvas_data.component[ uid ]

        message:
            error: ( uid, tip ) ->
                tip = Inside.genTip arguments
                Inside.taReturn CONST.TA.ERROR, tip, uid

            warning: ( uid, tip ) ->
                tip = Inside.genTip arguments
                Inside.taReturn CONST.TA.WARNING, tip, uid

            notice: ( uid, tip ) ->
                tip = Inside.genTip arguments
                Inside.taReturn CONST.TA.NOTICE, tip, uid


        eni:
            getByInstance: ( instance ) ->
                _.filter MC.canvas_data.component, ( component ) ->
                    if component.type is CONST.RESTYPE.ENI
                        if MC.extractID( component.resource.Attachment.InstanceId ) is instance.uid
                            true

        sg:
            get: ( component ) ->
                sgs = []
                # LC
                if component.type is CONST.RESTYPE.LC
                    for sgId in component.resource.SecurityGroups
                        sgs.push Helper.component.get MC.extractID sgId
                # instance
                else if component.type is CONST.RESTYPE.INSTANCE
                    enis = Helper.eni.getByInstance component

                    for eni in enis
                        for sg in eni.resource.GroupSet
                            sgs.push Helper.component.get MC.extractID sg.GroupId
                # ELB
                else if component.type is CONST.RESTYPE.ELB
                    for sgId in component.resource.SecurityGroups
                        sgs.push Helper.component.get MC.extractID sgId

                _.uniq _.compact sgs

            port: ( sgs ) ->

                info = in: {}, out: {}
                if not _.isArray sgs
                    sgs = [ sgs ]

                build = ( permission, direction ) ->
                    protocal = Helper.protocal.get permission.IpProtocol

                    info[ direction ][ protocal ] = [] if not info[ direction ][ protocal ]

                    theInfo = from: Number(permission.FromPort), to: Number(permission.ToPort), range: permission.IpRanges
                    if _.where( info[ direction ][ protocal ], theInfo ).length is 0
                        info[ direction ][ protocal ].push theInfo

                for sg in sgs
                    if sg.type isnt CONST.RESTYPE.SG
                        continue

                    for permission in sg.resource.IpPermissionsEgress
                        build permission, 'out'

                    for permission in sg.resource.IpPermissions
                        build permission, 'in'



                info

            isInRange: (protocal, port, portData, direction) ->

                isInRangeResult = false

                protocalCode = Helper.protocal.get(protocal.toLowerCase())
                portCode = Number(port)

                _.each portData[direction], (portAry, proto) ->
                    if proto is protocalCode or proto is 'all'
                        _.each portAry, (portObj) ->
                            if portCode >= portObj.from and portCode <= portObj.to
                                isInRangeResult = true
                            null
                    null

                return isInRangeResult

    Helper
