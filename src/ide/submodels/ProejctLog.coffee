
###
----------------------------
  The collection for stack / app
----------------------------

  This collection will trigger an "update" event when the list ( containing all visible items ) is changed.

###

define [ "constant", "backbone" ], ( constant )->

  ProjectLog = Backbone.Model.extend {

    constructor : ( attr, opt )->
      cate = attr.action.split(".")

      Backbone.Model.call {
        id       : attr.id
        usercode : attr.username

        type    : cate[1]
        action  : cate[2]
        success : attr.result is 0
        detail  : attr.detail

        target   : attr.target
        targetId : attr.target_id

        time     : attr.time
        duration : attr.duration
      }, opt

  }, {
    TYPE : {
      APP        : "App"
      APPSTATE   : "AppState"
      STACK      : "Stack"
      PROJECT    : "Project"
      MEMBER     : "Member"
      PAYMENT    : "Payment"
      CREDENTIAL : "Credential"
      TOKEN      : "Token"
    }
    ACTION : {
      CREATE    : "Create"
      UDPATE    : "Update"
      RENAME    : "Rename"
      REMOVE    : "Remove"
      SAVE      : "Save"

      TERMINATE : "Terminate"
      START     : "Start"
      STOP      : "Stop"
      REBOOT    : "Reboot"
      SAVEAS    : "SaveAs"
      CLONE     : "Clone"
      NOTIFY    : "Notify"
      RENDER    : "Render"
      GETKEY    : "GetKey"
      IMPORT    : "Import"

      RUN       : "Run"

      INVITE    : "Invite"

      ADD       : "Add"

    }
  }

  AuditType = {}
  AudtiType[ ProjectLog.TYPE.PROJECT ] = true
  AudtiType[ ProjectLog.TYPE.MEMBER ] = true
  AudtiType[ ProjectLog.TYPE.PAYMENT ] = true
  AudtiType[ ProjectLog.TYPE.CREDENTIAL ] = true
  AudtiType[ ProjectLog.TYPE.TOKEN ] = true
  historyFilter = ( model )-> !AuditType[model.get("type")]
  auditFilter   = ( model )-> AuditType[model.get("type")]

  ProjectLog.Collection = Backbone.Collection.extend {
    model : ProjectLog

    # Returns history of the project
    history : ()-> @filter historyFilter
    # Returns audits of the project
    audit : ()-> @filter auditFilter
  }

  ProjectLog

