
define [ "./ApiRequestErrors" ], ( Errors )->

  ###
  # === Global Error Handlers ===
  # These handlers are used to handle specific errors for any ajax call
  ###
  AwsHandlers = {}
  Handlers = {
    AwsHandlers : AwsHandlers
  }

  # Handlers[ Errors.InvalidSession ] = ( res )->

  AwsHandlers[ 401 ] = ( error )->
    # 401 means the credential is not correct
    App.askForAwsCredential()
    throw error

  Handlers
