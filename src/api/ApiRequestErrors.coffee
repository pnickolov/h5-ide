
define [], ()->
  ###
  # === Error Code Defination ===
  # TODO :
  # The Errors is just some random number at this time. Should define it when the Backend Error Code is defined.
  ###
  Errors =
    InvalidSession : 19

    ChangeCredConfirm : 325 # Occurs when an user try to change credential with running apps.
    InvalidCred       : 326 # Ocurrs when the aws credential is invalid.

  Errors
