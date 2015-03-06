
define [ "Design"
         "../base/main"
         "./view"
         "constant"
         "CloudResources"
         "event"
], ( Design, PropertyModule, view, constant, CloudResources ) ->

    PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.MRTHAPP ]

        initStack : ( uid )->
            @view = view
            @model = Design.instance().component uid
            @view.isAppEdit = false
            null

        initApp : ( uid ) ->
            @view = view
            @model = Design.instance().component uid
            @view.appData = {}
            @view.isAppEdit = false
            null

        initAppEdit : ( uid ) ->

    }
