define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo', 'Design' ], ( constant, MC, lang, resultVO, Design ) ->

    __wrap = ( method ) ->
        ( uid ) ->
            if __hasState uid
                method uid
            else
                null

    __getComp = ( uid, rework ) ->
        if rework
            Design.instance().component uid
        else
            MC.canvas_data.component[ uid ]

    __hasState = ( uid ) ->
        if uid
            component = __getComp uid, true
            state = component.get 'state'
            state and state.length
        else
            had = false
            Design.instance().eachComponent ( component ) ->
                if __hasState component.id
                    had = true
                    false
            had

    __hasType = ( type ) ->
        Design.modelClassForType( type ).allObjects().length

    __getEniByInstance = ( instance ) ->
        _.filter MC.canvas_data.component, ( component ) ->
            if component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
                if MC.extractID( component.resource.Attachment.InstanceId ) is instance.uid
                    true

    __getSg = ( component ) ->
        sgs = []
        # LC
        if component.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
            for sgId in component.resource.SecurityGroups
                sgs.push __getComp MC.extractID sgId
        # instance
        else if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
            enis = __getEniByInstance component

            for eni in enis
                for sg in eni.resource.GroupSet
                    sgs.push __getComp MC.extractID sg.GroupId

        _.uniq _.compact sgs

    __isPortTcpAllowed = ( permission, port ) ->
        res = false

        if permission.IpProtocol in [ '-1', '6', 'tcp' ]
            formPort = + permission.FromPort
            toPort = + permission.ToPort
            if  formPort is toPort is port
                res = true
            else if + permission.FromPort <= port and permission.ToPort >= port
                res = true


        res


    __sgsHasOutPort80and443 = ( sgs, strict ) ->
        __80 = __443 = 0

        for sg in sgs
            for permission in sg.resource.IpPermissionsEgress

                if strict and permission.IpRanges is '0.0.0.0/0' or not strict
                    if __isPortTcpAllowed permission, 80
                        __80++
                    if __isPortTcpAllowed permission, 443
                        __443++

        __80 > 0 and __443 > 0

    __getEipByEni = ( eni ) ->
        hasPrimaryEip

    __hasEipOrPublicIp = ( component ) ->
        if component.type is "ExpandedAsg"
            lc = component.get( 'originalAsg' ).get 'lc'
            lc.get( 'publicIp' ) is true
        # LC
        else if component.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
            component.get( 'publicIp' ) is true
        # instance
        else if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
            component.hasPrimaryEip() or component.hasAutoAssignPublicIp()

    __getSubnetRtb = ( component ) ->
        subnet = component.parent()
        if subnet.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
            subnet = subnet.parent()

        subnet.connectionTargets('RTB_Asso')[ 0 ]

    __isRouteIgw = ( component ) ->
        uid = component.uid or component.id
        component = Design.instance().component uid
        rtb = __getSubnetRtb( component )

        rtbConn = rtb.connectionTargets('RTB_Route')
        igw = _.where rtbConn, type: constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
        igw.length > 0

    __isNat = ( component ) ->
        if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
            uid = component.uid
            component = Design.instance().component uid
            rtb = __getSubnetRtb component

            if rtb
                instances = _.where rtb.connectionTargets('RTB_Route'), type: constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                _.some instances, ( instance ) ->
                    __isRouteIgw instance

        false

    __notNat = ( component ) ->
        __hasEipOrPublicIp( component ) and __isRouteIgw( component )


    ### Public ###

    isHasIgw = ( uid ) ->
        if __hasType constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
            return null

        tipInfo = lang.ide.TA_MSG_ERROR_NO_CGW

        # return
        level   : constant.TA.ERROR
        info    : tipInfo
        uid     : uid


    isHasOutPort80and443 = ( uid ) ->
        component = __getComp uid

        sgs = __getSg component
        if __sgsHasOutPort80and443 sgs
            return null

        tipInfo = sprintf lang.ide.TA_MSG_ERROR_NO_OUTBOUND_RULES, component.name

        # return
        level   : constant.TA.ERROR
        info    : tipInfo
        uid     : uid

    isHasOutPort80and443Strict = ( uid ) ->
        component = __getComp uid

        sgs = __getSg component
        if isHasOutPort80and443( uid ) or __sgsHasOutPort80and443 sgs, true
            return null

        tipInfo = sprintf lang.ide.TA_MSG_WARNING_OUTBOUND_NOT_TO_ALL, component.name

        # return
        level   : constant.TA.WARNING
        info    : tipInfo
        uid     : uid

    __isLcConnectedOut = ( uid ) ->
        lc = __getComp uid, true
        lcOld = __getComp uid
        result = []

        asg = lc.parent()
        expandedAsgs = asg.get 'expandedList'


        name = lc.parent().get 'name'
        subnetName = lc.parent().parent().get 'name'

        if not __notNat( lc )
            result.push __genConnectedError name, subnetName, uid

        for asg in expandedAsgs
            if not __notNat( asg )
                name = asg.get( "originalAsg" ).get 'name'
                subnetName = asg.parent().get 'name'
                result.push __genConnectedError name, subnetName, asg.id

        result


    __isInstanceConnectedOut = ( uid ) ->
        component = __getComp uid, true
        componentOld = __getComp uid
        if __notNat( component ) or __isNat( componentOld )
            return null

        #name, subnetName
        component = __getComp uid, true
        name = component.get 'name'
        subnetName = component.parent().get 'name'
        __genConnectedError name, subnetName

    __genConnectedError = ( name, subnetName, uid ) ->
        tipInfo = sprintf lang.ide.TA_MSG_ERROR_NOT_CONNECT_OUT, name, subnetName

        # return
        level   : constant.TA.ERROR
        info    : tipInfo
        uid     : uid

    isConnectedOut = ( uid ) ->
        result = []
        component = __getComp uid
        if component.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
            return __isLcConnectedOut( uid )
        else
            return __isInstanceConnectedOut( uid )







    # public
    isHasIgw                    : __wrap isHasIgw
    isHasOutPort80and443        : __wrap isHasOutPort80and443
    isHasOutPort80and443Strict  : __wrap isHasOutPort80and443Strict
    isConnectedOut              : __wrap isConnectedOut

