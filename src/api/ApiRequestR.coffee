
define ["ApiRequestRDefs", "api/ApiRequestErrors", "MC" ], ( ApiDefination, ApiErrors )->
  ###
  # === Restful ApiRequest ===
  #
  # Paramters :
  #   apiName       : (String) The name of the api, see ApiRequestDefs
  #   apiParameters : An object to be send with the api request.
  #         If an api has its parameters map, the `apiParameters` will be converted from OBJECT to ARRAY
  #         If an api has no param map, the apiParameters is considered as the first and only one paramter
  #         to be send with the api.
  ###
  EmptyObject  = {}

  # Helpers
  logAndThrow = ( obj )->
    ### env:dev ###
    console.error obj
    ### env:dev:end ###
    throw obj

  # Request Handlers
  AjaxErrorHandler = (jqXHR, textStatus, error)->
    if !error and jqXHR.status != 200
      logAndThrow McError(-jqXHR.status, "Network Error")

    logAndThrow McError( ApiErrors.XhrFailure, textStatus, error)
    return

  Abort = ()-> this.ajax.abort(); return


  ###
   Restful ApiRequest Defination
  ###
  ApiRequestRestful = ( apiName, apiParameters )->
    ApiDef        = ApiDefination[ apiName ]
    apiParameters = apiParameters || EmptyObject

    if not ApiDef
      console.error "Cannot find defination of the api:", apiName
      return

    url = ApiDef.url + App.user.get("usercode") + "/" + App.user.get("session")

    if ApiDef.params
      p = []
      for i in ApiDef.params
        if apiParameters.hasOwnProperty( i )
          p.push apiParameters[i]

      if p.length
        url += "/" + p.join("/")

    ajax = $.ajax {
      url      : MC.API_HOST + url
      dataType : "json"
      type     : ApiDef.method || "GET"
      jsonp    : false
    }

    # Generic hanlder for the ajax request.
    request = Q(ajax).fail(AjaxErrorHandler)
    request.abort = Abort
    request.ajax  = ajax
    request


  ApiRequestRestful.Errors = ApiErrors

  ApiRequestRestful
