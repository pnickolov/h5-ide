
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

    # common:  1*
    GlobalErrorInit       : 100 # Sorry, we are suffering from some technical issue, please try again later
    GlobalErrorApi        : 101 # Invalid API Parameters
    GlobalErrorSession    : 102 # Invalid session, please login again
    GlobalErrorDb         : 103 # DB operation failed
    GlobalErrorRegion     : 104 # Region mismatched
    GlobalErrorId         : 105 # Id mismatched
    GlobalErrorUsername   : 106 # Username mismatched
    GlobalErrorIntercom   : 107 # Failed to generate intercom secret hash
    GlobalErrorUnknown    : 109 #
    UserInvalidUser       : 110 # Invalid username or password
    UserInvalidUsername   : 111 # Invalid username {0}
    UserErrorUser         : 112 # user {0} missing {1}
    UserBlockedUser       : 113 # User {0} blocked
    UserRemovedUser       : 114 # User {0} removed
    UserNoUser            : 115 # User {0} not existed
    UserInvalidEmail      : 116 # Invalid email {0}
    SessionInvalidSessio  : 120 # Invalid session {0}/{1}
    SessionInvalidId      : 121 # Invalid session {0}
    SessionFailedCreate   : 122 # Can not create session {0} - {1}
    SessionFailedUpdate   : 123 # Can not update session {0} - {1}
    SessionFailedDelete   : 124 # Can not delete session {0} - {1}
    SessionFailedGet      : 125 # Can not get session {0}
    SessionErrorSession   : 126 # Mismatched username {0} and session id {1}
    SessionNotConnected   : 127 # Cannot connect with session manager
    RequestErrorRequest   : 130 # Cannot submit request
    RequestInvalidId      : 131 # Invalid request id {0}
    RequestNoPending      : 132 # Request {0} is no longer pending
    RequestErrorEmail     : 133 # Submit email request failed
    RequestOnProcess      : 134 # Request is processing and please submit request later
    IdConstrain           : 134 # Request is processing and please submit request later

    # forge:  2*
    AppInvalidFormat      : 210 # Missing parameter {0}
    AppNotStop            : 211 # Invalid parameter: stack is not stoppable but the lease action is set to Stop
    AppBeingOperated      : 212 # App {0} is being operated
    AppNotRename          : 213 # Can not rename app {0}
    AppInvalidId          : 214 # Invalid app id {0}
    AppInvalidState       : 214 # Invalid app state {0}
    AppIsRunning          : 215 # {0} is currently running
    AppIsStopped          : 216 # {0} is currently stopped
    AppNotStoppable       : 217 # {0} is not stoppable
    FavoriteId            : 217 # {0} is not stoppable
    GuestErrorGuest       : 230 # Guest {0} missing {1}
    GuestInvalidId        : 231 # Invalid guest id {0}
    GuestInvalidState     : 232 # Invalid guest state {0}
    GuestGuestEnd         : 233 # Sorry, this invitation has finished
    GuestGuestFailed      : 234 # Sorry, we are unable to launch the application for you, please contact with our support team
    GuestGuestThank       : 245 # Thank you for using VisualOps!
    GuestGuestBusy        : 246 # On inviting guest {0}
    OpsbackendId          : 246 # On inviting guest {0}
    OpsbackendRemoveStat  : 240 # Remove app {0}, instance {1} status failed
    OpsbackendErrorStatu  : 241 # Update statues and logs failed
    StackInvalidFormat    : 250 # Missing parameter {0}
    StackNotStop          : 251 # Invalid parameter: stack is not stoppable but the lease action is set to Stop
    StackRepeatedStack    : 252 # Repeated stack {0}
    StackInvalidId        : 253 # Invalid stack id {0}
    StackIsRemoved        : 254 # Stack {0} is already removed
    StackIsDisabled       : 255 # Stack {0} is already disabled
    StackVerifyFailed     : 256 # Verify stack {0} exception {1}
    StateErrorModule      : 260 # The version of this stack is no longer supported, please contact with our support for details

    # handler:  3*
    RequestNotSend        : 300 # Send request failed
    UserInvalidKey        : 320 # invalid key {0}
    UserInvalidUpdateTim  : 321 # mismatched update time
    UserExpiredActivatio  : 322 # This activation has expired
    UserInvalidOperation  : 323 # Unsupported operation {0}
    UserExistedUser       : 324 # Existed username or email
    UserExistedApp        : 325 # {0} app exists
    UserInvalidCredentia  : 326 # Invalid credential

    # aws:  4*
    AwsErrorApi           : 400 # Sorry, AWS is suffering from some technical issue, please try again later
    AwsInvalidAws         : 401 # Invalid aws data format
    AwsExceededResource   : 402 # Too many resources
    AwsErrorAws           : 403 # {0} exception {1}
    AwsErrorParams        : 404 # Invalid request params, {0} - {1}
    AwsErrorExternal      : 405 # External error, {0} - {1}
    AwsInvalidKeypair     : 406 # Cannot find keypair {0}
    AwsErrorEmail         : 407 # Send email from {0} to {1} failed
    AwsNoAmi              : 408 # No {0} amis left
    AwsErrorUnknown       : 409 # Unknown AWS error

  Errors
