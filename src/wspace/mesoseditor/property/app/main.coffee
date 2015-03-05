
define [ "Design"
         "../base/main"
         "./model"
         "./view"
         "constant"
         "event"
], ( Design,
     PropertyModule,
     model,
     view,
     constant ) ->

    PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.MRTHAPP ]

        initStack : ( uid )->
            @view = view
            @model = model
            @view.isAppEdit = false
            null

        afterLoadStack : ()->

        initApp : ( uid ) ->

        initAppEdit : ( uid ) ->

    }


