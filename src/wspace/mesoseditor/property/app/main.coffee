
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
            @view.jsonData = CloudResources( Design.instance().credentialId(), constant.RESTYPE.MRTHAPP, Design.instance().serialize().id )
            @view.appData = {}
            @view.isAppEdit = false
            null

        initAppEdit : ( uid ) ->
            @view = view
            @view.model = Design.instance().component uid
            @view.appData = {}
            @view.isAppEdit = true
            null

    }
