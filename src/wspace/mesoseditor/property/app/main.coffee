
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

        handleTypes : [ constant.RESTYPE.MRTHAPP ]

        initStack : ( uid )->
            @view = view
            @model = Design.instance().component uid
            @view.isAppEdit = false
            null

        afterLoadStack : ()->

        initApp : ( uid ) ->

        initAppEdit : ( uid ) ->

    }


