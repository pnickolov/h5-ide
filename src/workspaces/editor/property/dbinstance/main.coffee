####################################
#  Controller for design/property/dbinstance module
####################################

define [
         "Design"
         "CloudResources"
         "../base/main"
         "./model"
         "./view"
         "./app_view"
         "../sglist/main"
         "constant"
         "event"
], ( Design,
     CloudResources,
     PropertyModule,
     model,
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
            
            @view = view
            @model = model
            @view.resModel = Design.instance().component uid
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

            @view.resModel = resModel
            @view.appModel = (CloudResources(constant.RESTYPE.DBINSTANCE, Design.instance().region()).get resModel.get('appId')) || (CloudResources(constant.RESTYPE.DBSNAP, Design.instance().region()).get resModel.get('snapshotId'))
            null

        initAppEdit : ( uid ) ->

            resModel = Design.instance().component uid
            @view = view
            @model = model
            @view.isAppEdit = true
            @view.resModel = resModel
            @view.appModel = CloudResources(constant.RESTYPE.DBINSTANCE, Design.instance().region()).get resModel.get('appId')
            null

        afterLoadAppEdit : ()->
            sglist_main.loadModule @view.resModel
            null

        afterLoadApp : () ->
            sglist_main.loadModule @view.resModel
            null
    }
    null

    DBInstanceModule