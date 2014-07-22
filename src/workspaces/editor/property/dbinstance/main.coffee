####################################
#  Controller for design/property/dbinstance module
####################################

define [
         "Design"
         "CloudResources"
         "../base/main"
         "./view"
         "./app_view"
         "../sglist/main"
         "constant"
         "event"
], ( Design,
     CloudResources,
     PropertyModule,
     view,
     app_view,
     sglist_main, constant ) ->

    DBInstanceModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.DBINSTANCE ]

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        setupStack : () ->
            null

        initStack : ( uid )->
            @model = Design.instance().component uid
            @view  = view
            @view.isAppEdit = false
            null

        afterLoadStack : ()->
            sglist_main.loadModule @model
            null

        setupApp : () ->
            null

        initApp : ( uid ) ->
            resModel = Design.instance().component uid
            if resModel.serialize().component.resource.ReadReplicaSourceDBInstanceIdentifier
              uid = resModel.serialize().component.resource.ReadReplicaSourceDBInstanceIdentifier.split(".")[0].split('{').pop()
              resModel = Design.instance().component uid
              console.log(resModel, uid)
            @model = (CloudResources(constant.RESTYPE.DBINSTANCE, Design.instance().region()).get resModel.get('appId')) || (CloudResources(constant.RESTYPE.DBSNAP, Design.instance().region()).get resModel.get('snapshotId'))
            @view  = app_view
            console.log @model
            @view.resModel = resModel
            null

        initAppEdit : ( uid ) ->
            @model = Design.instance().component uid
            @view  = view
            @view.isAppEdit = true
            @view.appModel = CloudResources(constant.RESTYPE.DBINSTANCE, Design.instance().region()).get @model.get('appId')
            null

        afterLoadAppEdit : ()->
            sglist_main.loadModule @model
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null
    }
    null

    DBInstanceModule