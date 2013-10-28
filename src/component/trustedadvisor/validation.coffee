#############################
#  validation
#############################

define [ 'constant', 'event', './validation/main', './validation/result_vo',
         'jquery', 'underscore'
], ( constant, ide_event, validation_main, resultVO ) ->

    #privte
    validComp = ( type ) ->

        try

            #test
            MC.ta.resultVO = resultVO

            temp     = type.split '.'
            filename = temp[ 0 ]
            method   = temp[ 1 ]
            func     = validation_main[ filename ][ method ]

            if _.isFunction func

                args = Array.prototype.slice.call arguments, 1
                result = func.apply validation_main[ filename ], args

                if !result
                    resultVO.del type
                    true
                else
                    resultVO.add type, result.level, result.info, result.uid
                    false
                return result
            else
                console.log 'func not found'

        catch error
            console.log "validComp error #{ error }"

    validAll = ->

        try

            allComps = MC.canvas_data.component

            # independent validation
            _.each allComps, (compObj, uid) ->
                compType = compObj.type
                compUID = uid

                if compType is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                    validComp('instance.isEBSOptimizedForAttachedProvisionedVolume', compUID)
                else if compType is constant.AWS_RESOURCE_TYPE.AWS_ELB
                    validComp('elb.isHaveIGWForInternetELB', compUID)
                    validComp('elb.isHaveInstanceAttached', compUID)
                    validComp('elb.isAttachELBToMultiAZ', compUID)
                    validComp('elb.isRedirectPortHttpsToHttp', compUID)

                null

            # global validation
            validComp('vpc.isVPCAbleConnectToOutside')

            return MC.ta.list

        catch error
            console.log "validAll error #{ error }"

    #public
    validComp : validComp
    validAll  : validAll