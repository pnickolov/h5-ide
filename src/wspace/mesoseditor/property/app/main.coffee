
define [ "Design"
         "../base/main"
         "./view"
         "./app_view"
         "constant"
         "CloudResources"
         "event"
], ( Design, PropertyModule, view, appView, constant, CloudResources ) ->

    PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.MRTHAPP ]

        initStack : ( uid )->
            @view = view
            @model = Design.instance().component uid
            @view.isAppEdit = false
            null

        initApp : ( uid ) ->
            @view = appView
            @model = Design.instance().component uid
            path = @model.path()
            @view.appData = CloudResources( Design.instance().credentialId(), constant.RESTYPE.MRTHAPP, Design.instance().serialize().id ).filter (model)->
              model.get("id") is path
            @view.isAppEdit = false
            null

        initAppEdit : ( uid ) ->
            @view = view
            @view.isAppEdit = true
            @view.model = Design.instance().component uid
            path = @view.model.path()
            @view.appData = CloudResources( Design.instance().credentialId(), constant.RESTYPE.MRTHAPP, Design.instance().serialize().id ).filter (model)->
              model.get("id") is path
            null

    }
