
define [ "Design", "./ComplexResModel" ], ( Design, ComplexResModel )->

  ServergroupModel = ComplexResModel.extend {

    type     : "Framework_Servergroup"
    appIdKey : "InstanceId"

    groupMembers : ()->
      if @__groupMembers then return @__groupMembers
      @__groupMembers = []
      return @__groupMembers

  }, {

    # Return true if the data is added to ServerGroup, otherwise return false
    tryDeserialize : ( data, layoutData, resolve )->
      if data.serverGroupUid and data.serverGroupUid isnt data.uid
        resource = resolve( data.serverGroupUid )
        resource.groupMembers().push {
          id    : data.uid
          appId : data.resource[ appIdKey ]
        }
        return true

      return false
  }

  ServergroupModel

