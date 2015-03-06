
define [ "Design"
         "../base/main"
         "./view"
         "constant"
         "event"
], ( Design, PropertyModule, view, constant ) ->

    PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.MRTHGROUP ]

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
