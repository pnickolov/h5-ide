define [ 'constant', 'jquery', 'MC','i18n!/nls/lang.js', 'TaHelper', "CloudResources" ], ( constant, $, MC, lang, Helper, CloudResources ) ->

  i18n = Helper.i18n.short()

  isCGWHaveIPConflict = (callback) ->

    try
      if !callback
        callback = () ->

      # get current stack all cgw
      stackCGWIP = stackCGWName = stackCGWUID = stackCGWId = null
      _.each MC.canvas_data.component, (compObj) ->
        if compObj.type is constant.RESTYPE.CGW
          stackCGWId = compObj.resource.CustomerGatewayId
          stackCGWIP = compObj.resource.IpAddress
          stackCGWName = compObj.name
          stackCGWUID = compObj.uid
        null

      # if have cgw in stack
      if stackCGWIP and stackCGWName and stackCGWUID and not stackCGWId

        cr = CloudResources( Design.instance().credentialId(), constant.RESTYPE.CGW, Design.instance().region() )

        failure = ()-> callback( null )
        success = ()->
          exist = cr.where({"state":"available","ipAddress":stackCGWIP})[0]

          if exist
            error =
              level : constant.TA.ERROR
              info  : sprintf lang.TA.ERROR_CGW_IP_CONFLICT, stackCGWName, stackCGWIP, exist.id, stackCGWIP
            console.log( error )

          callback( error || null )
          null

        cr.fetchForce().then success, failure

        # immediately return
        return {
          level : constant.TA.ERROR,
          info  : sprintf lang.TA.ERROR_CGW_CHECKING_IP_CONFLICT
        }

      else
        callback(null)
    catch err
      callback(null)

  isValidCGWIP = (uid) ->

    cgwComp = MC.canvas_data.component[uid]
    cgwName = cgwComp.name
    cgwIP = cgwComp.resource.IpAddress

    # isInAnyPubIPRange = MC.aws.aws.isValidInIPRange(cgwIP, 'public')
    isInAnyPriIPRange = MC.aws.aws.isValidInIPRange(cgwIP, 'private')

    if isInAnyPriIPRange

      tipInfo = sprintf lang.TA.WARNING_CGW_IP_RANGE_ERROR, cgwName, cgwIP

      return {
        level: constant.TA.WARNING
        info: tipInfo
        uid: uid
      }

    return null

  isAttachVGW = ( uid ) ->
    cgw = Design.instance().component uid
    hasAttachVgw = cgw.connections(constant.RESTYPE.VPN).length

    if hasAttachVgw then return null

    Helper.message.error uid, i18n.ERROR_CGW_MUST_ATTACH_VPN, cgw.get 'name'



  isCGWHaveIPConflict : isCGWHaveIPConflict
  isValidCGWIP    : isValidCGWIP
  isAttachVGW     : isAttachVGW


