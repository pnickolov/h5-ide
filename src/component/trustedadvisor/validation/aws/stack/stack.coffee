define [ 'constant', 'jquery', 'MC','i18n!/nls/lang.js', 'ApiRequest', 'CloudResources', 'TaHelper' ], ( constant, $, MC, lang, ApiRequest, CloudResources, Helper ) ->
    i18n = Helper.i18n.short()

    getAZAryForDefaultVPC = (elbUID) ->

        elbComp = MC.canvas_data.component[elbUID]
        elbInstances = elbComp.resource.Instances
        azNameAry = []

        _.each elbInstances, (instanceRefObj) ->
            instanceRef = instanceRefObj.InstanceId
            instanceUID = MC.extractID(instanceRef)
            instanceAZName = MC.canvas_data.component[instanceUID].resource.Placement.AvailabilityZone
            if !(instanceAZName in azNameAry)
                azNameAry.push(instanceAZName)
            null

        return azNameAry

    _getCompName = (compUID) ->

        compName = ''
        compObj = MC.canvas_data.component[compUID]
        if compObj and compObj.name
            compName = compObj.name
        return compName

    _getCompType = (compUID) ->

        compType = ''
        compObj = MC.canvas_data.component[compUID]
        if compObj and compObj.type
            compType = compObj.type
        return compType

    verify = (callback) ->

        try
            if !callback
                callback = () ->

            validData = MC.canvas_data

            ApiRequest('stack_verify', {
                username: $.cookie( 'usercode' ),
                session_id: $.cookie( 'session_id' ),
                spec: validData
            }).then (result) ->

                checkResult = true
                returnInfo = null
                errInfoStr = ''

                if result isnt true

                    checkResult = false

                    try

                        returnInfo = result
                        returnInfoObj = JSON.parse(returnInfo)

                        # get api call info
                        errCompUID = returnInfoObj.uid

                        errCode = returnInfoObj.code
                        errKey = returnInfoObj.key
                        errMessage = returnInfoObj.message

                        errCompName = _getCompName(errCompUID)
                        errCompType = _getCompType(errCompUID)

                        errInfoStr = sprintf lang.TA.ERROR_STACK_FORMAT_VALID_FAILED, errCompName, errMessage

                        if (errCode is 'EMPTY_VALUE' and
                            errKey is 'InstanceId' and
                            errMessage is 'Key InstanceId can not empty' and
                            errCompType is 'AWS.VPC.NetworkInterface')
                                checkResult = true

                        if (errCode is 'EMPTY_VALUE' and
                            errKey is 'LaunchConfigurationName' and
                            errMessage is 'Key LaunchConfigurationName can not empty' and
                            errCompType is 'AWS.AutoScaling.Group')
                                checkResult = true

                        if (errCode is 'EMPTY_VALUE' and
                            errKey is 'TopicARN' and
                            errMessage is 'Key TopicARN can not empty' and
                            errCompType is 'AWS.AutoScaling.NotificationConfiguration')
                                checkResult = true

                    catch err
                        errInfoStr = lang.TA.ERROR_STACK_FORMAT_VALID_ERROR
                else
                    callback(null)

                if checkResult
                    callback(null)
                else
                    validResultObj = {
                        level: constant.TA.ERROR,
                        info: errInfoStr
                    }
                    callback(validResultObj)
                    console.log(validResultObj)

            , (result) ->

                callback(null)

            # immediately return
            tipInfo = sprintf lang.TA.ERROR_STACK_CHECKING_FORMAT_VALID
            return {
                level: constant.TA.ERROR,
                info: tipInfo
            }
        catch err
            callback(null)

    isHaveNotExistAMIAsync = (callback) ->

        try
            if !callback
                callback = () ->

            # get current all using ami
            tipInfoAry = []
            amiAry = []
            instanceAMIMap = {}
            _.each MC.canvas_data.component, (compObj) ->
                if compObj.type is constant.RESTYPE.INSTANCE or
                    compObj.type is constant.RESTYPE.LC
                        imageId = compObj.resource.ImageId
                        instanceId = ''
                        if compObj.type is constant.RESTYPE.INSTANCE
                            instanceId = compObj.resource.InstanceId
                        else if compObj.type is constant.RESTYPE.LC
                            instanceId = compObj.resource.LaunchConfigurationARN
                        if imageId and (not instanceId)
                            if not instanceAMIMap[imageId]
                                instanceAMIMap[imageId] = []
                                amiAry.push imageId
                            instanceAMIMap[imageId].push(compObj.uid)
                null

            # get ami info from aws
            if amiAry.length
                cr = CloudResources( Design.instance().credentialId(), constant.RESTYPE.AMI, MC.canvas_data.region )

                failure = ()-> callback(null)
                success = (invalidAmiAry)->

                    validIds = _.pluck(invalidAmiAry or [], 'id')
                    invalids = _.difference(amiAry, validIds)

                    for amiId in invalids
                        for instanceUID in instanceAMIMap[ amiId ] || []
                            instanceObj = MC.canvas_data.component[instanceUID]

                            if instanceObj.type is constant.RESTYPE.LC
                                infoTagType = 'lc'
                                infoObjType = lang.PROP.LC_TITLE
                            else
                                infoTagType = "instance"
                                infoObjType = lang.PROP.ELB_INSTANCES

                            tipInfoAry.push({
                                level : constant.TA.ERROR
                                uid   : instanceUID
                                info  : sprintf lang.TA.ERROR_STACK_HAVE_NOT_EXIST_AMI, infoObjType, infoTagType, instanceObj.name, amiId
                            })

                    if tipInfoAry.length
                        callback(tipInfoAry)
                        console.log(tipInfoAry)
                    else
                        callback(null)

                cr.fetchAmis( amiAry, true ).then success, failure
                return

            else
                callback(null)
        catch err
            callback(null)

    isHaveNotExistAMI = () ->

        # get current all using ami
        amiAry = []
        instanceAMIMap = {}
        _.each MC.canvas_data.component, (compObj) ->
            if compObj.type is constant.RESTYPE.INSTANCE or
                compObj.type is constant.RESTYPE.LC
                    imageId = compObj.resource.ImageId
                    instanceId = ''
                    if compObj.type is constant.RESTYPE.INSTANCE
                        instanceId = compObj.resource.InstanceId
                    else if compObj.type is constant.RESTYPE.LC
                        instanceId = compObj.resource.LaunchConfigurationARN
                    if imageId and (not instanceId)
                        if not instanceAMIMap[imageId]
                            instanceAMIMap[imageId] = []
                            amiAry.push imageId
                        instanceAMIMap[imageId].push(compObj.uid)
            null

        tipInfoAry = []

        amiCollection = CloudResources( Design.instance().credentialId(), constant.RESTYPE.AMI, MC.canvas_data.region )

        _.each amiAry, (amiId) ->
            if not amiCollection.get( amiId )
                # not exist in stack
                instanceUIDAry = instanceAMIMap[amiId]
                _.each instanceUIDAry, (instanceUID) ->
                    instanceObj = MC.canvas_data.component[instanceUID]
                    instanceType = instanceObj.type
                    instanceName = instanceObj.name

                    infoObjType = lang.PROP.ELB_INSTANCES
                    infoTagType = 'instance'
                    if instanceType is constant.RESTYPE.LC
                        infoObjType = lang.PROP.LC_TITLE
                        infoTagType = 'lc'
                    tipInfo = sprintf lang.TA.ERROR_STACK_HAVE_NOT_EXIST_AMI, infoObjType, infoTagType, instanceName, amiId
                    tipInfoAry.push({
                        level: constant.TA.ERROR,
                        info: tipInfo,
                        uid: instanceUID
                    })
                    null
            null

        return tipInfoAry


    hasTerminateProtection = (callback, differ) ->
        design = Design.instance()

        if !design.modeIsAppEdit() or !differ
          callback(null)
          return

        removedInstanceIds = []
        _.each differ.removedComps, (comp) ->
            if comp.type is constant.RESTYPE.INSTANCE
                removedInstanceIds.push comp.resource.InstanceId

        if !removedInstanceIds.length
            callback(null)
            return

        design.opsModel().checkTerminateProtection(removedInstanceIds).then (res) ->
            if _.size(res)
                tipvarArray = []
                for id, name of res
                    tipvarArray.push "#{name}(#{id})"
                tipvarStr = tipvarArray.join(', ')

                callback Helper.message.error null, i18n.TERMINATED_PROTECTION_CANNOT_TERMINATE, tipvarStr
            else
                callback(null)

        , (err) ->
            console.log(err);
            callback(null)



    hasTerminateProtection : hasTerminateProtection
    isHaveNotExistAMIAsync : isHaveNotExistAMIAsync
    isHaveNotExistAMI : isHaveNotExistAMI
    verify : verify
