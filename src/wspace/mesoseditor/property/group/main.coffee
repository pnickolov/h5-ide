
define [ "Design"
         "../base/main"
         "./view"
         "constant"
         "CloudResources"
         "event"
], ( Design, PropertyModule, view, constant, CloudResources ) ->

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
            @view.appJSON = CloudResources(Design.instance().credentialId(), constant.RESTYPE.MRTHGROUP, Design.instance().get('id') ).toJSON()
            @view.mode = 'app'
            null

        initAppEdit : ( uid ) ->

            @view = view
            @model = Design.instance().component uid
            @view.appJSON = CloudResources(Design.instance().credentialId(), constant.RESTYPE.MRTHGROUP, Design.instance().get('id') ).toJSON()
            @view.mode = 'appedit'
            null

    }
