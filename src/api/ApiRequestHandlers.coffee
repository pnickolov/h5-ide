
define [ "./ApiRequestErrors" ], ( Errors )->

  ###
  # === Global Error Handlers ===
  # These handlers are used to handle specific errors for any ajax call
  ###
  AwsHandlers = {}
  Handlers = {
    AwsHandlers : AwsHandlers
  }

  Handlers[ Errors.GlobalErrorSession ] = ( error )->
    # We cannot recover the api request, if the server asks us to provide new session.
    # All we can do is ask the user to re-valid the session.
    App.acquireSession()
    # Need to re-throw the error, since we still need to the api request-er to know
    # the api has failed.
    throw error

  AwsHandlers[ 401 ] = ( error )->
    # 401 means the credential is not correct
    App.askForAwsCredential()
    throw error

  Handlers
