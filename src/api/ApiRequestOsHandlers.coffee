
define [ "./ApiRequestHandlers" ], ( Handlers )->

  ###
  # === Global Error Handlers ===
  # These handlers are used to handle specific errors for any ajax call
  ###
  Handlers.OsHandlers = OsHandlers = {}

  # OsHandlers[ 401 ] = ( error, apiName, apiParameters, ApiRequest )->
  #   # 401 means the credential is not correct
  #   console.info "Openstack token expires, requesting a new one.", apiName, apiParameters

  #   ApiRequest("os_v2_auth",{}).then ()-> ApiRequest( apiName, apiParameters )

  Handlers
