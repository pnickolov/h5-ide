
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
            @view.mode = 'stack'
            null

        afterLoadStack : ()->

        initApp : ( uid ) ->

            @view = view
            @model = Design.instance().component uid
            @view.mode = 'app'
            null

        initAppEdit : ( uid ) ->

            @view = view
            @model = Design.instance().component uid
            @view.mode = 'appedit'
            null

    }
