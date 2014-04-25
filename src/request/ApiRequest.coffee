
define ["request/ApiRequestDefs", "MC" ], ( ApiDefination )->

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

  AjaxHandler = (res)->
    if not res or not res.result or res.result.length != 2
      throw {
        error : -1
        msg   : "Invalid JsonRpc Return Data"
      }

    if res.result[0] isnt 0
      # We can do aditional global handling for some specific error here.
      # For example, Invalid Session.
      throw {
        error  : res.result[0]
        msg    : "Service Error"
        result : res.result[1]
      }

    res.result[1]

  NetworkErrorHandler = (jqXHR, textStatus, error)->
    if !error and jqXHR.status != 200
      throw {
        error : -jqXHR.status
        msg   : "Network Error"
      }

    throw {
      error  : -2
      msg    : textStatus
      result : error
    }
    return

  Abort = ()-> this.ajax.abort(); return


  ApiRequest = ( apiName, apiParameters )->
    ApiDef = ApiDefination[ apiName ]
    apiParameters = apiParameters || EmptyObject

    if not ApiDef
      console.error "Cannot find defination of the api:", apiName
      return

    RequestData.method = ApiDef.method || ""
    if ApiDef.params
      RequestData.params = p = []
      for i in ApiDef.params
        p.push apiParameters[i] || ApiDef.autoFill(i)
    else if apiParameters
      OneParaArray[0] = apiParameters
      RequestData.params = OneParaArray
    else
      RequestData.params = EmptyArray

    ajax = $.ajax {
      url      : MC.API_HOST + ApiDef.url
      dataType : "json"
      type     : "POST"
      data     : JSON.stringify RequestData
    }

    # Generic hanlder for the ajax request.
    request = Q(ajax).then(AjaxHandler, NetworkErrorHandler)

    # Pass result to parser if defined.
    if ApiDefination.Parsers[ apiName ]
      request = request.then( ApiDefination.Parsers[ apiName] )

    request.abort = Abort
    request.ajax  = ajax
    request

  ApiRequest
