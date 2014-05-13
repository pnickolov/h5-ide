
define [], ()->
  ###
  # === Error Code Defination ===
  # 1. Any network errors will be negative. For example, when server returns 404, the `error` in the promise will be -404.
  ###
  Errors =
    InvalidRpcReturn  : -1 # Occurs when the server's reponse doesn't contain valid data.
    XhrFailure        : -2 # Occurs when jquery cannot handle the request ( e.g. jquery cannot parse the response as JSON )
    InvalidMethodCall : -3 # Occurs when an method is not supposed to be call ( e.g. calling OpsModel.stop() while the model doesn't stands for an app )

    Network404 : -404
    Network500 : -500

    InvalidSession : 19

    ChangeCredConfirm : 325 # Occurs when an user try to change credential with running apps.
    InvalidCred       : 326 # Ocurrs when the aws credential is invalid.

  Errors
