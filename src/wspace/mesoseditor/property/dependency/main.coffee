
define [ "Design"
         "../base/main"
         "./view"
         "constant"
         "event"
], ( Design,
     PropertyModule,
     view,
     constant ) ->

    PropertyModule.extend {

        handleTypes : [ "MarathonDepIn", "MarathonDepOut" ]

        initStack : ( uid )->

            @view = view
            @model = Design.instance().component uid
            @view.isAppEdit = false
            null

        afterLoadStack : ()->

        initApp : ( uid ) ->

            @view = view
            @model = Design.instance().component uid
            @view.isAppEdit = false
            null

        initAppEdit : ( uid ) ->

            @view = view
            @model = Design.instance().component uid
            @view.isAppEdit = false
            null

    }
