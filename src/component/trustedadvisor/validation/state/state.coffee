define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo', 'Design' ], ( constant, MC, lang, resultVO, Design ) ->

    __wrap = ( method ) ->
        ( uid ) ->
            if __hasState uid
                method uid
            else
                null

    __getComp = ( uid ) ->
        component = MC.canvas_data.component[ uid ]

    __hasState = ( uid ) ->
        if uid
            component = __getComp uid
            component.state and component.state.length
        else
            _.some MC.canvas_data.component, ( component ) ->
                component.state and component.state.length

    __hasType = ( type ) ->
        _.some MC.canvas_data.component, ( component ) ->
            component.type is type

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





    # public
    isHasIgw                    : __wrap isHasIgw
    isHasOutPort80and443        : __wrap isHasOutPort80and443
    isHasOutPort80and443Strict  : __wrap isHasOutPort80and443Strict


