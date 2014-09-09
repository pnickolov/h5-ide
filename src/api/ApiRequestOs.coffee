
define ["ApiRequestDefs", "api/ApiRequestErrors", "api/ApiRequestHandlers", "api/ApiBundle", "MC" ], ( ApiDefination, ApiErrors, ApiHandlers )->
  ###
  # === ApiRequest ===
  #
  # Paramters :
  #   apiName       : (String) The name of the api, see ApiRequestDefs
  #   apiParameters : An object to be send with the api request.
  #         If an api has its parameters map, the `apiParameters` will be converted from OBJECT to ARRAY
  #         If an api has no param map, the apiParameters is considered as the first and only one paramter
  #         to be send with the api.
  ###
  OneParaArray = [""]
  EmptyArray   = []
  EmptyObject  = {}

  RequestData =
    jsonrpc : '2.0'
    id      : "1"
    method  : ''
    params  : {}

  # Helpers
  logAndThrow = ( obj )->
    ### env:dev ###
    console.error obj
    ### env:dev:end ###
    throw obj

  # Request Handlers
  AjaxSuccessHandler = (res)->
    if not res or not res.result or not res.result[0] or not res.result[1]
      logAndThrow McError( ApiErrors.InvalidRpcReturn , "Invalid JsonRpc Return Data")

    # Try parse AWS Return result if we have correct return.
    awsresult = res.result[1]
    if awsresult and _.isArray(awsresult)

      if awsresult[0] is 200
        return awsresult[1]
      else
        error = McError( res.result[0], "Service Error", res.result[1] )
        error.awsError  = awsresult[0]
        error.awsResult = awsresult[1]

        logAndThrow error

    res.result[1]

  AjaxErrorHandler = (jqXHR, textStatus, error)->
    if !error and jqXHR.status != 200
      logAndThrow McError(-jqXHR.status, "Network Error")

    logAndThrow McError( ApiErrors.XhrFailure, textStatus, error)
    return

  Abort = ()-> this.ajax.abort(); return



  ###
   ApiRequest Defination
  ###
  ApiRequest = ( apiName, apiParameters )->
    ApiDef = ApiDefination.Defs[ apiName ]
    apiParameters = apiParameters || EmptyObject

    if not ApiDef
      console.error "Cannot find defination of the api:", apiName
      return

    if ApiDef.type isnt "openstack"
      console.error "Cannot send non-openstack request(#{apiName}) by using `ApiRequestOst`"
      return

    RequestData.method = ApiDef.method || ""
    if ApiDef.params
      RequestData.params = p = []
      for i in ApiDef.params
        if apiParameters.hasOwnProperty( i )
          p.push apiParameters[i]
        else
          p.push ApiDefination.AutoFill(i)

    else if apiParameters
      OneParaArray[0] = apiParameters
      RequestData.params = OneParaArray
    else
      RequestData.params = EmptyArray

    ajax = $.ajax {
      url      : MC.API_HOST + ApiDef.url
      dataType : "json"
      type     : "POST"
      jsonp    : false
      data     : JSON.stringify RequestData
    }

    # Generic hanlder for the ajax request.
    request = Q(ajax).then(AjaxSuccessHandler, AjaxErrorHandler)

    # Pass result to parser if defined.
    if ApiDefination.Parsers[ apiName ]
      request = request.then( ApiDefination.Parsers[apiName] )

    request.abort = Abort
    request.ajax  = ajax
    request


  ApiRequest.Errors = ApiErrors

  ApiRequest
