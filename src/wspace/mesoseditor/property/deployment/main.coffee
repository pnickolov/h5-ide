
define [ "Design"
         "../base/main"
         "./view"
         "constant"
         "event"
], ( Design, PropertyModule, view, constant ) ->

    PropertyModule.extend {

        handleTypes : [ "Stack", "default" ]

        initStack : ( uid )->

            @view = view
            @model = Design.instance()
            @view.mode = 'stack'
            null

        afterLoadStack : ()->

        initApp : ( uid ) ->

            @view = view
            @model = Design.instance()
            @view.mode = 'app'
            null

        initAppEdit : ( uid ) ->

            @view = view
            @model = Design.instance()
            @view.mode = 'appedit'
            null

    }
